-- ============================================================
-- BASELINE: dbo.UspFinAtualizaLancamentoManualFM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaLancamentoManualFM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure  [dbo].[UspFinAtualizaLancamentoManualFM]    (
    @CodPeriodoPagamento int
)
as
begin


	--declare @CodPeriodoPagamento int = 2861

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
									and lst_ds_valor = 'FM' 
									and lst_cd_cliente = @CodigoCliente
								)
		declare @SiglaOperacao varchar(10) = (select 
													lst_ds_valor 
												from 
													tb_lista with(nolock)
												where 
													lst_nm_lista = 'Operações Marketplace' 
													and lst_ds_valor = 'FM' 
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

		 declare @DivisaoEspelho varchar(50) = lower(ltrim(rtrim(isnull(
															(select 
																prm_ds_valor
															from 
																tb_parametros with(nolock)
															where 
																prm_nm_parametro = 'Divisão  de espelho'
																and prm_in_ativo = 1
																and prm_in_excluido = 0
																and prm_cod_cliente = @CodigoCliente
															)
														,'false'))))

		declare @UsuarioCriacao int = 7

		declare @DataPrevistaPagamento date = (  
      
			  select pgp_dt_prevista_pagamento  
			  from [tb_pgto_periodo] as a (NOLOCK)  
			  where pgp_cd_periodo  = @CodPeriodoPagamento
     
			 )

		drop table if exists #lancamentos
		select	
			l.tlm_cd_lancamento_manual
			,case when l.tlm_cd_rota = '' or l.tlm_cd_rota = 'null' then null else l.tlm_cd_rota end tlm_cd_rota
			,cast(l.tlm_dh_referencia as date) tlm_dh_referencia
			,l.tlm_cd_service_center
			,l.tlm_cd_motorista
			,l.tlm_cd_cliente
			,isnull(l.tlm_vl_valor_apoio * -1,0) + isnull(l.tlm_vl_valor_rota,0) + ISNULL(l.tlm_vl_valor_adicional,0) + ISNULL(l.tlm_vl_valor_descontos*-1,0) tlm_valor
			,l.plm_nm_tipo
			,l.plm_in_calculo_desconto
			,l.tlm_ds_observacao
			,u.usr_cd_usuario
			,@CodPeriodoPagamento tlm_cod_periodo
		into #lancamentos
		from	vw_lancamentos_manuais_aprovados as l
		left	join tb_usuario u on l.tlm_cd_motorista = u.usr_nm_usuario
									and l.tlm_cd_cliente = u.cli_cd_codigo_cliente
									and u.usr_in_ativo = 1
									and u.usr_in_motorista = 1

		where	Operacao = @SiglaOperacao
				and tlm_cd_cliente = @CodigoCliente
				and tlm_dh_referencia between @DataInicial and @DataFinal




		--Ajuste para unificar os lançamentos no mesmo espelho quando o o cliente não tem a divisão de espelho
		IF @DivisaoEspelho = 'false'
		BEGIN


			update	l
			set		tlm_cd_service_center = base.base_espelho
			from	#lancamentos as l
			join	(


					select	tlm_cd_motorista
						,	usr_cd_usuario
						,	isnull(b.mtn_base_principal,a.tlm_cd_service_center) base_espelho
						,	row_number() over(partition by tlm_cd_motorista order by count(*) desc) as ordem
					from	#lancamentos as a
					left join tb_pag_espelhos as b on a.tlm_cd_motorista = b.mtn_nome_motorista
												and a.tlm_cod_periodo = b.mtn_cd_pgto_periodo 
												and b.mtn_cd_operacao = @Operacao
												and b.mtn_in_excluido = 0
					group	by tlm_cd_motorista
						,	usr_cd_usuario
						,	isnull(b.mtn_base_principal,a.tlm_cd_service_center)

				) as base
					on l.tlm_cd_motorista = base.tlm_cd_motorista
						and l.usr_cd_usuario = base.usr_cd_usuario
						and base.ordem = 1

		END



		MERGE INTO tb_pag_espelhos AS target
		USING (

			SELECT 
				usr_cd_usuario AS mtn_cd_motorista,
				tlm_cd_motorista AS mtn_nome_motorista,
				tlm_cod_periodo AS mtn_cd_pgto_periodo,
				228 AS mtn_cd_status,
				SUM(CASE WHEN plm_in_calculo_desconto = 0 THEN ISNULL(tlm_valor,0) ELSE 0 END) AS mtn_vl_nfs,
				SUM(CASE WHEN plm_in_calculo_desconto = 1 THEN ISNULL(tlm_valor,0) ELSE 0 END) AS mtn_vl_desconto,
				NULL AS mtn_ds_link_nfs,
				DATEADD(DAY,30,@DataFinal) AS mtn_dt_prazo_contestacao,
				GETDATE() AS mtn_dh_criacao,
				@UsuarioCriacao AS mtn_cd_usr_criacao,
				GETDATE() AS mtn_dh_modificacao,
				@UsuarioCriacao AS mtn_cd_usr_modificacao,
				0 AS mtn_in_excluido,
				@CodigoCliente AS mtn_cod_cliente,
				COUNT(*) AS mtn_qt_rotas,
				94 AS mtn_cd_tipo_espelho,
				@IdCliTransportadora AS mtn_cd_cliente_transportadora,
				bss_cd_base AS mtn_cd_base,
				tlm_cd_service_center AS mtn_base_principal,
				@Operacao AS mtn_cd_operacao,
				@DataPrevistaPagamento mtn_dt_prevista_pagamento
			FROM 
				#lancamentos AS a
				LEFT JOIN tb_bases AS c 
					ON a.tlm_cd_service_center = c.bss_ds_sigla 
				   AND c.bss_cd_idtransportadora = @IdTransportadora
			GROUP BY usr_cd_usuario, tlm_cd_motorista, tlm_cod_periodo, bss_cd_base, tlm_cd_service_center

		) AS source
		ON (
			target.mtn_nome_motorista = source.mtn_nome_motorista
			AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
			--Criar parametro para dizer se o espelho do motorista varia para cada svc
			and (
				(@DivisaoEspelho = 'false' and target.mtn_base_principal = source.mtn_base_principal)
				or
				@DivisaoEspelho <> 'false'
			)
			AND target.mtn_cd_operacao = source.mtn_cd_operacao
			AND target.mtn_in_excluido = 0
		)
		WHEN MATCHED THEN
			UPDATE SET 
				target.mtn_cd_motorista = source.mtn_cd_motorista,
				target.mtn_vl_nfs = source.mtn_vl_nfs,
				target.mtn_vl_desconto = source.mtn_vl_desconto,
				target.mtn_qt_rotas = source.mtn_qt_rotas,
				target.mtn_dh_modificacao = GETDATE(),
				target.mtn_cd_usr_modificacao = @UsuarioCriacao,
				--ajuste para atualizar somente quando a data não for atualizada manualmente
				target.mtn_dt_prevista_pagamento = case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end
		WHEN NOT MATCHED THEN
			INSERT (
				mtn_cd_motorista, mtn_nome_motorista, mtn_cd_pgto_periodo, mtn_cd_status,
				mtn_vl_nfs, mtn_vl_desconto, mtn_ds_link_nfs, mtn_dt_prazo_contestacao,
				mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao,
				mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho,
				mtn_cd_cliente_transportadora, mtn_cd_base, mtn_base_principal, mtn_cd_operacao,
				mtn_dt_prevista_pagamento
			)
			VALUES (
				source.mtn_cd_motorista, source.mtn_nome_motorista, source.mtn_cd_pgto_periodo, source.mtn_cd_status,
				source.mtn_vl_nfs, source.mtn_vl_desconto, source.mtn_ds_link_nfs, source.mtn_dt_prazo_contestacao,
				source.mtn_dh_criacao, source.mtn_cd_usr_criacao, source.mtn_dh_modificacao, source.mtn_cd_usr_modificacao,
				source.mtn_in_excluido, source.mtn_cod_cliente, source.mtn_qt_rotas, source.mtn_cd_tipo_espelho,
				source.mtn_cd_cliente_transportadora, source.mtn_cd_base, source.mtn_base_principal, source.mtn_cd_operacao,
				source.mtn_dt_prevista_pagamento
			);







		drop table if exists #pgto_descontos
		select
			d.tlm_cd_rota ppr_cd_rota
			,d.tlm_cd_motorista ppr_nome_motorista
			,d.tlm_dh_referencia ppr_data_referencia
			,d.tlm_ds_observacao ppr_lcto_observacao
			,d.tlm_valor ppr_vl_lancamentos
			,d.tlm_valor ppr_vl_total
			,d.tlm_cod_periodo ppr_cd_periodo
			,e.mtn_cd_motorista_nfs ppr_cd_pgto_espelho
			,getdate() ppr_dh_criacao
			,@UsuarioCriacao ppr_cd_usr_criacao
			,getdate() ppr_dh_modificacao
			,@UsuarioCriacao ppr_cd_usr_modificacao
			,1 ppr_in_ativo
			,0 ppr_in_excluido
			,d.usr_cd_usuario ppr_cd_motorista
			,e.mtn_cd_motorista_nfs as ppr_cd_motorista_nfs
			,d.tlm_cd_lancamento_manual ppr_lcto_cd_lancamento
			,d.tlm_cd_service_center ppr_base_principal
			,d.plm_in_calculo_desconto ppr_fl_desconto
			into #pgto_descontos
		from
			#lancamentos d
			join tb_pag_espelhos e on d.tlm_cd_motorista = e. mtn_nome_motorista
										and d.tlm_cod_periodo = e.mtn_cd_pgto_periodo
										--Criar parametro para dizer se o espelho do motorista varia para cada svc
											and (
												(@DivisaoEspelho = 'false' and d.tlm_cd_service_center = e.mtn_base_principal)
												or
												@DivisaoEspelho <> 'false'
											)
										and e.mtn_cd_operacao = @Operacao
										and e.mtn_in_excluido = 0
			join tb_lista l with(nolock) on e.mtn_cd_status = l.lst_cd_lista 
										and l.lst_nm_lista = 'Status motorista nfs' 
										and lst_cd_fechado=0

		where
			e.mtn_in_excluido = 0

	

		--Atualiza pagamentos com rotas e que tiveram lançamentos manuais
		update
			p
		set
			p.ppr_vl_lancamentos = d.ppr_vl_lancamentos
			--,p.ppr_lcto_cd_lancamento = d.ppr_lcto_cd_lancamento
			,p.ppr_lcto_observacao = d.ppr_lcto_observacao
		from
			tb_pgto_periodo_rota p
			join (
				select
					ppr_cd_rota
					,ppr_lcto_cd_lancamento
					,ppr_lcto_observacao
					,sum(ppr_vl_lancamentos) ppr_vl_lancamentos
				from
					#pgto_descontos
				where
					ppr_cd_rota is not null
					and ppr_fl_desconto = 0
				group by
					ppr_cd_rota
					,ppr_lcto_cd_lancamento
					,ppr_lcto_observacao
			) d on p.ppr_cd_rota = d.ppr_cd_rota
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento


		--apos atualizar apaga os registros com rotas que pertencem ao periodo atual
		delete d from #pgto_descontos d
		where d.ppr_cd_rota is not null
		and exists (
			select 1 from tb_pgto_periodo_rota p
			where p.ppr_cd_periodo = @CodPeriodoPagamento
			and p.ppr_cd_rota = d.ppr_cd_rota
		)


		-- Insere novos lançamentos ou altera o que já foi incluido (sem rotas)
		merge into tb_pgto_periodo_rota as a
		using #pgto_descontos as p on a.ppr_cd_periodo = p.ppr_cd_periodo
										and a.ppr_cd_motorista_nfs = p.ppr_cd_motorista_nfs
										and a.ppr_lcto_cd_lancamento = p.ppr_lcto_cd_lancamento
		when matched then
			update set
					ppr_vl_lancamentos = p.ppr_vl_lancamentos
					,ppr_vl_total = case when p.ppr_fl_desconto = 1 then p.ppr_vl_total else a.ppr_vl_total end --se for algum adiantamento, o total é igual ao lançamento
					,ppr_dh_modificacao = getdate()
		when not matched then
			insert ( 
					ppr_nome_motorista
					,ppr_data_referencia
					,ppr_lcto_observacao
					,ppr_vl_lancamentos
					,ppr_vl_total
					,ppr_cd_periodo
					,ppr_cd_pgto_espelho
					,ppr_dh_criacao
					,ppr_cd_usr_criacao
					,ppr_dh_modificacao
					,ppr_cd_usr_modificacao
					,ppr_in_ativo
					,ppr_in_excluido
					,ppr_cd_motorista
					,ppr_cd_motorista_nfs
					,ppr_lcto_cd_lancamento
					,ppr_base_principal
					,ppr_fl_desconto
					,ppr_cd_tipo_pgto
					)
			values (
					p.ppr_nome_motorista
					,p.ppr_data_referencia
					,p.ppr_lcto_observacao
					,p.ppr_vl_lancamentos
					,p.ppr_vl_total
					,p.ppr_cd_periodo
					,p.ppr_cd_pgto_espelho
					,p.ppr_dh_criacao
					,p.ppr_cd_usr_criacao
					,p.ppr_dh_modificacao
					,p.ppr_cd_usr_modificacao
					,p.ppr_in_ativo
					,p.ppr_in_excluido
					,p.ppr_cd_motorista
					,p.ppr_cd_motorista_nfs
					,p.ppr_lcto_cd_lancamento
					,p.ppr_base_principal
					,p.ppr_fl_desconto
					,1363
			);

			-- Deleta lançamentos que foram cancelados com espelhos ainda em aberto
			update
				p
			set
				p.ppr_in_excluido = 1
			from
				tb_pgto_periodo_rota p
				join tb_pag_espelhos e on p.ppr_nome_motorista = e. mtn_nome_motorista
										and p.ppr_cd_periodo = e.mtn_cd_pgto_periodo
										--Criar parametro para dizer se o espelho do motorista varia para cada svc
											and (
												(@DivisaoEspelho = 'false' and p.ppr_base_principal = e.mtn_base_principal)
												or
												@DivisaoEspelho <> 'false'
											)
										and e.mtn_cd_operacao = @Operacao
				join tb_lista l with(nolock) on e.mtn_cd_status = l.lst_cd_lista 
											and l.lst_nm_lista = 'Status motorista nfs' 
											and lst_cd_fechado=0
			where
				p.ppr_cd_periodo = @CodPeriodoPagamento
				and p.ppr_cd_tipo_pgto = 1363
				and not exists (select 
									1 
								from 
									vw_lancamentos_manuais_aprovados l 
								where 
									l.tlm_cd_cliente = @CodigoCliente
									and p.ppr_lcto_cd_lancamento = l.tlm_cd_lancamento_manual
									and l.Operacao = @SiglaOperacao
								)

	end --fim do if que verifica se o status está em aberto

end
GO
