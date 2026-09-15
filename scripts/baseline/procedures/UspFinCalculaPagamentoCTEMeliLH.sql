-- ============================================================
-- BASELINE: dbo.UspFinCalculaPagamentoCTEMeliLH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinCalculaPagamentoCTEMeliLH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinCalculaPagamentoCTEMeliLH]    (
    @CodPeriodoPagamento int,
	@avulso int = null -- codigo espelho,
)
as
begin

	--declare @CodPeriodoPagamento int = 2531
	--declare @avulso int = null -- codigo espelho


	set nocount on

	set @avulso = case when @avulso = 0 then null else @avulso end


	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)
	declare @DataLimiteReanalise date = (select pgp_dt_limite_reanalise from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1 and cast(getdate() as date) <= isnull(@DataLimiteReanalise,cast(getdate() as date))
	begin
		

		declare @CodigoCliente int
		declare @DataInicial date
		declare @DataFinal date
		declare @TipoContrato int
		declare @Operacao int
		declare @DataLimite date
		declare @IdCliTransportadora int
		declare @DataPrevistaPagamento date
		
		select
			@CodigoCliente = pgp_cd_cliente
			,@DataInicial = pgp_dt_inicio
			,@DataFinal = pgp_dt_fim
			,@TipoContrato = pgp_cd_tipo_contratos
			,@Operacao = pgp_tipo_operacao
			,@DataLimite = pgp_dt_limite_reanalise
			,@IdCliTransportadora = pgp_cd_cliente_transportadora
			,@DataPrevistaPagamento = pgp_dt_prevista_pagamento
		from
			tb_pgto_periodo
		where
			pgp_cd_periodo = @CodPeriodoPagamento


		declare @UsuarioCriacao int = 7
		

		drop table if exists #emissoes_cte
		select
			l.IdMotorista
			,cast(l.DataHoraAutorizacao as date) DataReferencia
			,l.TipoVeiculo
			,l.IdVeiculo
			,ltrim(rtrim(left(CodigoPesquisaPacotes, charindex(' - ', CodigoPesquisaPacotes) - 1))) CodigoRota
			,ltrim(rtrim(substring(CodigoPesquisaPacotes,CHARINDEX(' - ', CodigoPesquisaPacotes) + 3,LEN(CodigoPesquisaPacotes)))) ServiceCenter
			,l.ValorFrete
			into #emissoes_cte
		from
			[10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_lotes l with(nolock)
			join [10.1.1.21,1483].IrisysFiscal.dbo.tb_lista_fiscal l1 with(nolock) on l.IdTipoOrigem = l1.lst_cd_lista
			join [10.1.1.21,1483].IrisysFiscal.dbo.tb_lista_fiscal l2 with(nolock) on l.StatusLote = l2.lst_cd_lista
		where
			l.Ativo = 1
			and l.Excluido = 0
			and l.IsTeste = 0
			and l1.lst_ds_label = 'Line Haul Meli'
			and l2.lst_ds_label in ('Lote CTe Emitido', 'Lote CTe Finalizado', 'Lote MDFe Emitido', 'Lote MDFe Finalizado', 'Lote CTe Emitido Parcialmente')
			and l.TenantId = @CodigoCliente
			and l.DataHoraCriacao >= @DataInicial
			and l.DataHoraCriacao < dateadd(day,1,@DataFinal)
			
			

		drop table if exists #emissoes_cte_agrupado
		select
			@CodPeriodoPagamento ppr_cd_periodo
			,cast(e.CodigoRota as varchar(50)) ppr_cd_rota
			,DataReferencia ppr_data_referencia
			,cast(v.vei_ds_placa as varchar(15)) ppr_ds_placa
			,cast(e.TipoVeiculo as varchar(50)) ppr_ds_tipo_veiculo
			,cast(e.ServiceCenter as varchar(50)) ppr_base_principal
			,u.usr_cd_usuario ppr_cd_motorista
			,u.usr_nm_usuario ppr_nome_motorista
			,sum(cast(e.ValorFrete as decimal(10,2))) ppr_vl_base
			,cast(null as decimal(10,2)) ppr_vl_total
			,cast(null as decimal(10,2)) ppr_vl_bonus
			,isnull(m.mot_ctn_cd_tipo_contrato,-1) mot_ctn_cd_tipo_contrato
			into #emissoes_cte_agrupado
		from
			#emissoes_cte e
			join tb_motorista m with(nolock) on e.IdMotorista = m.mot_cd_motorista
			join tb_tipo_contrato c with(nolock) on m.mot_ctn_cd_tipo_contrato = c.ttc_cd_tipo_contrato
			join tb_usuario u with(nolock) on m.mot_cd_usuario = u.usr_cd_usuario
											and m.mot_cd_cliente = u.cli_cd_codigo_cliente
			join tb_veiculos v with(nolock) on e.IdVeiculo = v.vei_cd_veiculo
		where
			(c.ttc_cd_tipo_contrato = @TipoContrato or @TipoContrato = '-1')
		group by
			e.CodigoRota
			,DataReferencia
			,v.vei_ds_placa
			,e.TipoVeiculo
			,e.ServiceCenter
			,u.usr_cd_usuario
			,u.usr_nm_usuario
			,m.mot_ctn_cd_tipo_contrato

			
		drop table if exists #pagamento_rotas
		select
			e.ppr_cd_periodo
			,e.ppr_cd_rota
			,e.ppr_data_referencia
			,e.ppr_ds_placa
			,e.ppr_ds_tipo_veiculo
			,e.ppr_base_principal
			,e.ppr_base_principal svc_espelho
			,e.ppr_cd_motorista
			,e.ppr_nome_motorista
			,isnull(e.ppr_vl_base * fmc_vl_perc_frete,0) ppr_vl_base
			,isnull(e.ppr_vl_base * fmc_vl_perc_frete_bonus,0) ppr_vl_bonus
			,isnull(e.ppr_vl_base * fmc_vl_perc_frete,0) + isnull(e.ppr_vl_base * fmc_vl_perc_frete_bonus,0) ppr_vl_total
			,cast(null as int) ppr_cd_motorista_nfs
			,cast(null as int) ppr_cd_pgto_espelho
			,cast(null as varchar(2000)) ppr_lcto_observacao
			,1362 ppr_cd_tipo_pgto
			,'CTE' ppr_cd_tipo
			into #pagamento_rotas
		from
			#emissoes_cte_agrupado e
			left join tb_fin_base_frete_motorista_cte b with(nolock) on e.mot_ctn_cd_tipo_contrato = b.fmc_cd_tipo_contrato
																and b.fmc_cd_cliente = @CodigoCliente
																and b.fmc_cd_cliente_transportadora = @IdCliTransportadora
																and e.ppr_data_referencia between b.fmc_data_inicio_vigencia and isnull(b.fmc_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))

		
		update 
			r
		set 
			r.svc_espelho = r2.ppr_base_principal
		from 
			#pagamento_rotas r
			join (
				select
					ppr_cd_motorista
					,ppr_base_principal
					,row_number() over(partition by ppr_cd_motorista order by count(*) desc, ppr_base_principal desc) as ordem
				from 
					#pagamento_rotas
				group by 
					ppr_cd_motorista
					,ppr_base_principal
			) r2 on r.ppr_cd_motorista = r2.ppr_cd_motorista
				and r2.ordem = 1


		--Cria tabela para espelho
		drop table if exists #espelho
		select
			a.ppr_cd_motorista mtn_cd_motorista
			,a.ppr_nome_motorista as mtn_nome_motorista
			,a.ppr_cd_periodo as mtn_cd_pgto_periodo
			,228 mtn_cd_status
			,SUM(ppr_vl_total) as mtn_vl_nfs
			,null mtn_ds_link_nfs
			,@DataLimite as mtn_dt_prazo_contestacao
			,getdate() mtn_dh_criacao
			,7174 as mtn_cd_usr_criacao
			,getdate() mtn_dh_modificacao
			,7174 as mtn_cd_usr_modificacao
			,0 as mtn_in_excluido
			,@CodigoCliente as mtn_cod_cliente
			,count(*) as mtn_qt_rotas
			,94 as mtn_cd_tipo_espelho
			,@IdCliTransportadora as mtn_cd_cliente_transportadora
			,bss_cd_base mtn_cd_base
			,svc_espelho mtn_base_principal
			,@operacao as mtn_cd_operacao
			,null mtn_vl_imposto
			,null mtn_vl_liquido
			into #espelho
		from 
			#pagamento_rotas as a
			left join tb_bases b with(nolock) on a.svc_espelho = b.bss_ds_sigla
												and b.bss_in_status = 1
												and b.bss_in_excluido = 0
												and b.bss_cod_cliente = @CodigoCliente
		where 
			a.ppr_cd_motorista is not null
		group by
			a.ppr_cd_motorista
			,a.ppr_nome_motorista
			,a.ppr_cd_periodo
			,svc_espelho
			,bss_cd_base

		

		--Merge espelho
		MERGE tb_pag_espelhos AS target
		USING (
			select
				e.mtn_cd_motorista
				,e.mtn_nome_motorista
				,e.mtn_cd_pgto_periodo
				,e.mtn_cd_status
				,e.mtn_vl_nfs
				,e.mtn_ds_link_nfs
				,e.mtn_dt_prazo_contestacao
				,e.mtn_dh_criacao
				,e.mtn_cd_usr_criacao
				,e.mtn_dh_modificacao
				,e.mtn_cd_usr_modificacao
				,e.mtn_in_excluido
				,e.mtn_cod_cliente
				,e.mtn_qt_rotas
				,e.mtn_cd_tipo_espelho
				,e.mtn_cd_cliente_transportadora
				,e.mtn_cd_base
				,e.mtn_base_principal
				,e.mtn_cd_operacao
				,e.mtn_vl_imposto
				,e.mtn_vl_liquido
				,m.Banco mtn_ds_Banco
				,m.NomeTitular mtn_ds_NomeTitular
				,m.CpfTitular mtn_ds_CpfTitular
				,m.CnpjTitular mtn_ds_CnpjTitular
				,m.Agencia mtn_ds_Agencia
				,m.Conta mtn_ds_Conta
				,m.TipoConta mtn_ds_TipoConta
				,m.TipoChavePix mtn_ds_TipoChavePix
				,m.ChavePix mtn_ds_ChavePix
				,m.CnpjEmpresa mtn_ds_CnpjEmpresa
				,m.RazaoSocial mtn_ds_RazaoSocial
				,m.NomeFantasia mtn_ds_NomeFantasia
				,@DataPrevistaPagamento mtn_dt_prevista_pagamento
			from
				#espelho e
				left join (
							SELECT	
								*,
								ROW_NUMBER() OVER(PARTITION BY CodigoUsuario ORDER BY CodigoUsuario ASC)	AS ID
							FROM 
								vw_dados_motoristas
						) as m on m.CodigoUsuario = e.mtn_cd_motorista
								and m.id = 1
		) AS source
		ON (
			target.mtn_cd_motorista = source.mtn_cd_motorista
			AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
			AND target.mtn_cd_operacao = source.mtn_cd_operacao
			AND target.mtn_in_excluido = 0
		)
		WHEN MATCHED AND target.mtn_cd_status in (34,228,38) THEN --alterar para tabela de status quando subir
			UPDATE SET
				mtn_vl_nfs = source.mtn_vl_nfs
				,mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
				,mtn_dh_modificacao = source.mtn_dh_modificacao
				,mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao
				,mtn_in_excluido = source.mtn_in_excluido
				,mtn_cod_cliente = source.mtn_cod_cliente
				,mtn_qt_rotas = source.mtn_qt_rotas
				,mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora
				,mtn_base_principal = source.mtn_base_principal
				,mtn_nome_motorista =  source.mtn_nome_motorista
				,mtn_cd_base = source.mtn_cd_base
				,mtn_cd_motorista = source.mtn_cd_motorista
				,mtn_vl_imposto = source.mtn_vl_imposto
				,mtn_vl_liquido = source.mtn_vl_liquido
				,mtn_ds_Banco = source.mtn_ds_Banco
				,mtn_ds_NomeTitular = source.mtn_ds_NomeTitular
				,mtn_ds_CpfTitular = source.mtn_ds_CpfTitular
				,mtn_ds_CnpjTitular = source.mtn_ds_CnpjTitular
				,mtn_ds_Agencia = source.mtn_ds_Agencia
				,mtn_ds_Conta = source.mtn_ds_Conta
				,mtn_ds_TipoConta = source.mtn_ds_TipoConta
				,mtn_ds_TipoChavePix = source.mtn_ds_TipoChavePix
				,mtn_ds_ChavePix = source.mtn_ds_ChavePix
				,mtn_ds_CnpjEmpresa = source.mtn_ds_CnpjEmpresa
				,mtn_ds_RazaoSocial = source.mtn_ds_RazaoSocial
				,mtn_ds_NomeFantasia = source.mtn_ds_NomeFantasia
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
				,mtn_ds_Banco
				,mtn_ds_NomeTitular
				,mtn_ds_CpfTitular
				,mtn_ds_CnpjTitular
				,mtn_ds_Agencia
				,mtn_ds_Conta
				,mtn_ds_TipoConta
				,mtn_ds_TipoChavePix
				,mtn_ds_ChavePix
				,mtn_ds_CnpjEmpresa
				,mtn_ds_RazaoSocial
				,mtn_ds_NomeFantasia
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
				,source.mtn_ds_Banco
				,source.mtn_ds_NomeTitular
				,source.mtn_ds_CpfTitular
				,source.mtn_ds_CnpjTitular
				,source.mtn_ds_Agencia
				,source.mtn_ds_Conta
				,source.mtn_ds_TipoConta
				,source.mtn_ds_TipoChavePix
				,source.mtn_ds_ChavePix
				,source.mtn_ds_CnpjEmpresa
				,source.mtn_ds_RazaoSocial
				,source.mtn_ds_NomeFantasia
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
								and p.ppr_cd_motorista = e.mtn_cd_motorista
								and e.mtn_in_excluido = 0
								and e.mtn_cd_operacao = @Operacao
								and e.mtn_cd_status in (34,228,38)

		--Remove o que não encontrou espelho ativo
		delete from #pagamento_rotas where ppr_cd_motorista_nfs is null


		--deleta pagamentos que foram criados e não existem mais (em caso de exclusão de cte)
		--apenas se o espelho tiver em aberto ainda
		update
			p
		set
			ppr_in_excluido = 1
		from
			tb_pgto_periodo_rota p
			join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
										and e.mtn_in_excluido = 0
										and e.mtn_cd_operacao = @Operacao
										and e.mtn_cd_status in (34,228,38)
			left join #pagamento_rotas p2 on p.ppr_cd_periodo = p2.ppr_cd_periodo
										and p.ppr_cd_rota = p2.ppr_cd_rota
										and p.ppr_cd_motorista = p2.ppr_cd_motorista
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento
			and p.ppr_cd_rota is not null
			and p.ppr_cd_tipo_pgto = 1362 
			and p2.ppr_cd_rota is null



		--Atualiza pagamento
		MERGE INTO [tb_pgto_periodo_rota] AS target
		USING #pagamento_rotas AS source
		ON 
			target.ppr_cd_periodo = source.ppr_cd_periodo
			AND target.ppr_cd_rota = source.ppr_cd_rota
			and target.ppr_cd_motorista = source.ppr_cd_motorista
		WHEN MATCHED THEN
			UPDATE SET
				target.ppr_vl_base = source.ppr_vl_base,
				target.ppr_vl_total = source.ppr_vl_total,
				target.ppr_dh_modificacao = getdate(),
				target.ppr_cd_usr_modificacao = @UsuarioCriacao,
				target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
				target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
				target.ppr_data_referencia = source.ppr_data_referencia,
				target.ppr_base_principal = source.ppr_base_principal,
				target.ppr_nome_motorista = source.ppr_nome_motorista,
				target.ppr_cd_tipo_pgto = source.ppr_cd_tipo_pgto,
				target.ppr_cd_tipo = source.ppr_cd_tipo,
				target.ppr_lcto_observacao = source.ppr_lcto_observacao
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				ppr_cd_periodo,
				ppr_cd_rota,
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
				ppr_lcto_observacao
			)
			VALUES (
				source.ppr_cd_periodo,
				source.ppr_cd_rota,
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
				source.ppr_cd_tipo,
				source.ppr_cd_tipo_pgto,
				source.ppr_lcto_observacao
			);

	end

end
GO
