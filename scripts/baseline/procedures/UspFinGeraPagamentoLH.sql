-- ============================================================
-- BASELINE: dbo.UspFinGeraPagamentoLH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraPagamentoLH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinGeraPagamentoLH]    (
    @CodPeriodoPagamento int,
	@avulso int = null -- codigo espelho,
)
as
begin

	set nocount on

	set @avulso = case when @avulso = 0 then null else @avulso end

	--declare @CodPeriodoPagamento int = 637

	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1
	begin

		declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @CodPeriodoPagamento)
		declare @DataInicial date = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
		declare @DataFinal date = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)
		declare @IdTransportadora int = (select cli_id_logistics from tb_clientes where cli_cd_codigo_cliente=@CodigoCliente)
		declare @Operacao int = (select 
									lst_cd_lista 
								from 
									tb_lista with(nolock)
								where 
									lst_nm_lista = 'Operações Marketplace' 
									and lst_ds_valor = 'LH' 
									and lst_cd_cliente = @CodigoCliente
								)
		declare @IdCliTransportadora int = (select 
												lst_cd_lista 
											from 
												tb_lista (NOLOCK)
											where 
												lst_nm_lista = 'Clientes transportadoras'
												and lst_ds_label = 'Mercado Livre'
												and lst_cd_cliente = @CodigoCliente
											)
		 declare @DataPrevistaPagamento date = (  
      
			  select pgp_dt_prevista_pagamento  
			  from [tb_pgto_periodo] as a (NOLOCK)  
			  where pgp_cd_periodo  = @CodPeriodoPagamento
     
			 )

		declare @UsuarioCriacao int = 7

		if @avulso is not null
		begin

			update 
				a
			set
				 mtn_vl_nfs = ppr_vl_total
				,mtn_nome_motorista = ppr_nome_motorista
				,mtn_cd_motorista = ppr_cd_motorista
			from 
				tb_pag_espelhos as a (NOLOCK)
				inner join (
					select
						ppr_cd_pgto_espelho
						,ppr_nome_motorista
						,ppr_cd_motorista
						,sum(ppr_vl_total) as ppr_vl_total
					FROM 
						[tb_pgto_periodo_rota] AS a (NOLOCK)
					where 
						ppr_cd_pgto_espelho = @avulso
						and ppr_cd_periodo  = @CodPeriodoPagamento
						and ppr_fl_desconto = 0
						and ppr_in_excluido = 0
					group by 
						ppr_cd_pgto_espelho,
						ppr_nome_motorista,
						ppr_cd_motorista
				) as b
					on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho
			where
				a.mtn_cd_operacao = @Operacao

		end
		else 
		begin


			drop table if exists #tb_pgto_periodo_rota_edit
			select 
				*
				into #tb_pgto_periodo_rota_edit
			from 
				(
					select
						*
						,row_number() over(partition by edit_rota order by edit_dh_criacao desc) as ordem
					from 
						tb_pgto_periodo_rota_edit (NOLOCK)
					where 
						edit_cd_periodo =  @CodPeriodoPagamento
				) t
		
		
			--Rotas que serão realizadas os cálculos
			drop table if exists #rotas
			select
				@CodigoCliente CodigoCliente
				,@CodPeriodoPagamento ppr_cd_periodo
				,r.IdRota ppr_cd_rota
				,r.IdTransportadora
				,r.DataReferencia ppr_data_referencia
				,r.RosteringId
				,r.CodigoRota 
				,r.Status 
				,r.SubStatus
				,r.NomeMotorista ppr_nome_motorista
				,r.Placa ppr_ds_placa
				,isnull(e.edit_Tipo_Veiculo,r.TipoVeiculo) ppr_ds_tipo_veiculo
				,r.ServiceCenterOrigem
				,isnull(e.edit_Service_Center,r.ServiceCenterDestino) ppr_base_principal
				,isnull(e.edit_Service_Center,r.ServiceCenterDestino) svc_espelho --quando a transportadora tiver um único espelho precisa fazer update para ser igual pra todos os motoristas
				,r.UsuarioDA ppr_cd_motorista
				,e.edit_Faixa_KM ppr_cd_faixa_km --apenas informativo caso tenha sido alterado na tela, pois não é utilizado
				,case when e.edit_zerar_pagamento = 1 then 1 else 0 end ppr_in_zerar_rota
				into #rotas
			from
				vw_ml_lh_rotas r
				left join #tb_pgto_periodo_rota_edit e with(nolock) on r.IdRota = e.edit_rota
			where
				r.IdTransportadora = @IdTransportadora
				and r.DataReferencia between @DataInicial and @DataFinal
				and r.Status not in ('canceled', 'pending','Cancelado','Pendente')
				and r.NomeMotorista is not null
				and r.NomeMotorista <> ''


			--Alterar para parametro (comenta para poder validar com todas as rotas coletadas)
			IF(@CodigoCliente = 11)
			BEGIN
				--apaga rotas que não tiveram UsuarioDA
				delete #rotas where ppr_cd_motorista is null

				--apaga rotas de motoristas que não estão ativos
				delete
					r
				from
					#rotas r
					join tb_usuario u with(nolock) on r.ppr_cd_motorista = u.usr_cd_usuario and u.cli_cd_codigo_cliente = @CodigoCliente
				where
					u.usr_in_ativo = 0
			END

			--Realiza os cálculos de pagamento
			drop table if exists #pagamento_rotas
			select
				rotas.ppr_cd_periodo
				,rotas.CodigoCliente
				,cast(rotas.ppr_cd_rota as varchar(60)) ppr_cd_rota
				,rotas.IdTransportadora
				,rotas.ppr_data_referencia
				,rotas.RosteringId
				,rotas.CodigoRota 
				,rotas.Status 
				,rotas.SubStatus
				,rotas.ppr_cd_motorista
				,rotas.ppr_nome_motorista
				,rotas.ppr_ds_placa
				,rotas.ppr_ds_tipo_veiculo
				,rotas.ServiceCenterOrigem
				,rotas.ppr_base_principal
				,rotas.svc_espelho
				,prefatura.Total TotalPrefatura
				,case when rotas.ppr_in_zerar_rota = 1 then 0 else isnull(frete.bfm_vl_frete,0) end ppr_vl_base
				,case when rotas.ppr_in_zerar_rota = 1 then 0 else isnull(frete.bfm_vl_frete,0) end ppr_vl_total
				,cast(null as int) ppr_cd_motorista_nfs
				,cast(null as int) ppr_cd_pgto_espelho
				,1362 ppr_cd_tipo_pgto
				,rotas.ppr_cd_faixa_km
				into #pagamento_rotas
			from
				#rotas rotas
				left join tb_dra_tipo_veiculo tv with(nolock) on rotas.ppr_ds_tipo_veiculo = tv.tvl_nm_tipo_veiculo

				left join tb_fin_lh_prefatura prefatura with(nolock) on rotas.ppr_cd_rota = prefatura.IdRota
														and rotas.IdTransportadora = prefatura.IdTransportadora
	
				left join vw_fin_base_frete_motorista frete with(nolock) on rotas.CodigoCliente = frete.bfm_cd_transportadora
															and rotas.ppr_base_principal = frete.bfm_cd_service_center
															and tv.tvl_cd_tipo_veiculo = frete.bfm_cd_tipo_veiculo
															and rotas.ppr_data_referencia between frete.bfm_data_inicio_vigencia and isnull(frete.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
															and frete.Operacao = 'LH'

														
		
		
			--atualiza base para os clientes que não tem divisão de espelho
			IF @CodigoCliente not in (11,1,56,66)
			begin
				update 
					r
				set 
					r.svc_espelho = r2.ppr_base_principal
				from 
					#pagamento_rotas r
					join (
						select
							ppr_nome_motorista
							,ppr_base_principal
							,row_number() over(partition by ppr_nome_motorista order by count(*) desc, ppr_base_principal desc) as ordem
						from 
							#pagamento_rotas
						group by 
							ppr_nome_motorista
							,ppr_base_principal
					) r2 on isnull(r.ppr_nome_motorista, N'') = isnull(r2.ppr_nome_motorista, N'')
						and r2.ordem = 1
			end

			--Cria tabela para espelho
			drop table if exists #espelho
			select
				 a.ppr_cd_motorista mtn_cd_motorista
				,a.ppr_nome_motorista as mtn_nome_motorista
				,a.ppr_cd_periodo as mtn_cd_pgto_periodo
				,228 mtn_cd_status
				,SUM(ppr_vl_total) as mtn_vl_nfs
				,null mtn_ds_link_nfs
				,dateadd(day,30,@DataFinal) as mtn_dt_prazo_contestacao
				,getdate() mtn_dh_criacao
				,7174 as mtn_cd_usr_criacao
				,getdate() mtn_dh_modificacao
				,7174 as mtn_cd_usr_modificacao
				,0 as mtn_in_excluido
				,CodigoCliente as mtn_cod_cliente
				,count(*) as mtn_qt_rotas
				,94  as mtn_cd_tipo_espelho
				,@IdCliTransportadora as mtn_cd_cliente_transportadora
				,bss_cd_base as mtn_cd_base
				,svc_espelho mtn_base_principal
				,@operacao as mtn_cd_operacao
				,null mtn_vl_imposto
				,null mtn_vl_liquido
				,@DataPrevistaPagamento mtn_dt_prevista_pagamento
				into #espelho
			from 
				#pagamento_rotas as a
				left join tb_bases as c (NOLOCK) on a.svc_espelho = c.bss_ds_sigla and a.IdTransportadora = c.bss_cd_idtransportadora
			where 
				a.ppr_cd_motorista is not null
			group by
				 a.ppr_cd_motorista
				,a.ppr_nome_motorista
				,a.ppr_cd_periodo
				,CodigoCliente
				,bss_cd_base
				,svc_espelho

				-- select * from #espelho
	
			--Merge espelho
			MERGE tb_pag_espelhos AS target
			USING #espelho AS source
			ON (
				target.mtn_nome_motorista = source.mtn_nome_motorista
				AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
				AND target.mtn_cd_operacao = source.mtn_cd_operacao
				and target.mtn_base_principal = source.mtn_base_principal
				AND target.mtn_in_excluido = 0
			)
			WHEN MATCHED AND target.mtn_cd_status in (34,228,38) THEN --alterar para tabela de status quando subir
				UPDATE SET
					mtn_vl_nfs = source.mtn_vl_nfs
					,mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
					,mtn_cd_usr_criacao = source.mtn_cd_usr_criacao
					,mtn_dh_modificacao = source.mtn_dh_modificacao
					,mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao
					,mtn_in_excluido = source.mtn_in_excluido
					,mtn_cod_cliente = source.mtn_cod_cliente
					,mtn_qt_rotas = source.mtn_qt_rotas
					,mtn_cd_tipo_espelho = source.mtn_cd_tipo_espelho
					,mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora
					,mtn_base_principal = source.mtn_base_principal
					,mtn_nome_motorista =  source.mtn_nome_motorista
					,mtn_cd_base = source.mtn_cd_base
					,mtn_cd_motorista = source.mtn_cd_motorista
					,mtn_vl_imposto = source.mtn_vl_imposto
					,mtn_vl_liquido = source.mtn_vl_liquido
					--ajuste para atualizar somente quando a data não for atualizada manualmente
					,mtn_dt_prevista_pagamento = case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end

			WHEN NOT MATCHED THEN
				INSERT (
					 mtn_cd_motorista
					,mtn_cd_pgto_periodo
					,mtn_cd_status
					,mtn_vl_nfs
					,mtn_ds_link_nfs
					,mtn_dt_prazo_contestacao
					,mtn_dh_criacao
					,mtn_cd_usr_criacao
					,mtn_dh_modificacao
					,mtn_cd_usr_modificacao
					,mtn_in_excluido
					,mtn_cod_cliente
					,mtn_qt_rotas
					,mtn_cd_tipo_espelho
					,mtn_cd_cliente_transportadora
					,mtn_base_principal
					,mtn_nome_motorista
					,mtn_cd_base
					,mtn_vl_imposto
					,mtn_vl_liquido
					,mtn_cd_operacao
					,mtn_dt_prevista_pagamento
				)
				VALUES (
					 source.mtn_cd_motorista
					,source.mtn_cd_pgto_periodo
					,source.mtn_cd_status
					,source.mtn_vl_nfs
					,source.mtn_ds_link_nfs
					,source.mtn_dt_prazo_contestacao
					,source.mtn_dh_criacao
					,source.mtn_cd_usr_criacao
					,source.mtn_dh_modificacao
					,source.mtn_cd_usr_modificacao
					,source.mtn_in_excluido
					,source.mtn_cod_cliente
					,source.mtn_qt_rotas
					,source.mtn_cd_tipo_espelho
					,source.mtn_cd_cliente_transportadora
					,source.mtn_base_principal
					,source.mtn_nome_motorista
					,source.mtn_cd_base
					,source.mtn_vl_imposto
					,source.mtn_vl_liquido
					,source.mtn_cd_operacao
					,source.mtn_dt_prevista_pagamento
				);


			--Atualiza código do espelho das rotas
			update
				p
			set
				ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				,ppr_cd_pgto_espelho = e.mtn_cd_motorista_nfs
			from
				#pagamento_rotas p
				join tb_pag_espelhos e on p.ppr_cd_periodo = e.mtn_cd_pgto_periodo
									and p.ppr_nome_motorista = e.mtn_nome_motorista
									and p.svc_espelho = e.mtn_base_principal
									and e.mtn_in_excluido = 0
									and e.mtn_cd_operacao = @Operacao
									and e.mtn_cd_status in (34,228,38) --trocar por nova tabela de status para fazer join com aberto

		delete from #pagamento_rotas where ppr_cd_pgto_espelho is null
			--Atualiza rotas
			MERGE INTO [tb_pgto_periodo_rota] AS target
			USING #pagamento_rotas AS source
			ON 
				target.ppr_cd_periodo = source.ppr_cd_periodo
				AND target.ppr_cd_rota = source.ppr_cd_rota
			WHEN MATCHED THEN
				UPDATE SET
					target.ppr_ds_placa = source.ppr_ds_placa,
					target.ppr_ds_tipo_veiculo = source.ppr_ds_tipo_veiculo,
					target.ppr_vl_base = source.ppr_vl_base,
					target.ppr_vl_total = source.ppr_vl_total,
					target.ppr_dh_modificacao = getdate(),
					target.ppr_cd_usr_modificacao = @UsuarioCriacao,
					target.ppr_cd_motorista = source.ppr_cd_motorista,
					target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
					target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
					target.ppr_data_referencia = source.ppr_data_referencia,
					target.ppr_base_principal = source.ppr_base_principal,
					target.ppr_nome_motorista = source.ppr_nome_motorista,
					target.ppr_cd_tipo_pgto = source.ppr_cd_tipo_pgto,
					target.ppr_cd_faixa_km = source.ppr_cd_faixa_km,
					target.ppr_cd_tipo = 'LH'
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (
					ppr_cd_periodo,
					ppr_cd_rota,
					ppr_ds_placa,
					ppr_ds_tipo_veiculo,
					ppr_vl_base,
					ppr_vl_total,
					ppr_dh_criacao,
					ppr_cd_usr_criacao,
					ppr_dh_modificacao,
					ppr_cd_usr_modificacao,
					ppr_in_ativo,
					ppr_in_excluido,
					ppr_cd_motorista,
					ppr_cd_motorista_nfs,
					ppr_cd_pgto_espelho,
					ppr_data_referencia,
					ppr_base_principal,
					ppr_nome_motorista,
					ppr_cd_tipo,
					ppr_cd_tipo_pgto,
					ppr_cd_faixa_km
				)
				VALUES (
					source.ppr_cd_periodo,
					source.ppr_cd_rota,
					source.ppr_ds_placa,
					source.ppr_ds_tipo_veiculo,
					source.ppr_vl_base,
					source.ppr_vl_total,
					getdate(),
					@UsuarioCriacao,
					getdate(),
					@UsuarioCriacao,
					1,
					0,
					source.ppr_cd_motorista,
					source.ppr_cd_motorista_nfs,
					source.ppr_cd_pgto_espelho,
					source.ppr_data_referencia,
					source.ppr_base_principal,
					source.ppr_nome_motorista,
					'LH',
					source.ppr_cd_tipo_pgto,
					source.ppr_cd_faixa_km
				);


			end --fim do if que verifica se o status do periodo está em aberto
	end


end
GO
