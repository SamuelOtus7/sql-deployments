-- ============================================================
-- BASELINE: dbo.UspFinAtualizaLancamentoManualAdministrativo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaLancamentoManualAdministrativo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinAtualizaLancamentoManualAdministrativo]    (
    @CodPeriodoPagamento int
)
as
begin


	--declare @CodPeriodoPagamento int = 524

	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1
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
		declare @Base varchar(60) = 'Administrativo'
		declare @IdBase int = (select bss_cd_base from tb_bases where bss_cod_cliente = @CodigoCliente and bss_ds_marketplace = @Base and bss_in_excluido = 0)

		drop table if exists #lancamentos
		select
			*
			into #lancamentos
		from
			(
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
				from 
					vw_lancamentos_manuais_aprovados l
					join tb_usuario u on l.tlm_cd_motorista = u.usr_nm_usuario
											and l.tlm_cd_cliente = u.cli_cd_codigo_cliente
											and u.usr_in_ativo = 1
											--and u.usr_in_motorista = 1
				where
					l.tlm_cd_cliente = @CodigoCliente
					and l.tlm_dh_referencia >= @DataInicial 
					and l.tlm_dh_referencia < dateadd(day,1,@DataFinal)
					and l.tlm_cd_cliente_transportadora = @IdCliTransportadora
			) lancamentos



		insert into tb_pag_espelhos (mtn_cd_motorista, mtn_nome_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_vl_desconto, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_base_principal, mtn_cd_operacao, mtn_dt_prevista_pagamento)
		select 
			usr_cd_usuario mtn_cd_motorista
			,tlm_cd_motorista as mtn_nome_motorista
			,tlm_cod_periodo as mtn_cd_pgto_periodo
			,228 mtn_cd_status
			,SUM(case when plm_in_calculo_desconto = 0 then isnull(tlm_valor,0) else 0 end) as tlm_valor
			,SUM(case when plm_in_calculo_desconto = 1 then isnull(tlm_valor,0) else 0 end) as mtn_vl_desconto
			,null mtn_ds_link_nfs
			,dateadd(day,30,@DataFinal) as mtn_dt_prazo_contestacao
			,getdate() mtn_dh_criacao
			,@UsuarioCriacao as mtn_cd_usr_criacao
			,getdate() mtn_dh_modificacao
			,@UsuarioCriacao as mtn_cd_usr_modificacao
			,0 as mtn_in_excluido
			,@CodigoCliente as mtn_cod_cliente
			,count(*) as mtn_qt_rotas
			,94  as mtn_cd_tipo_espelho
			,@IdCliTransportadora as mtn_cd_cliente_transportadora
			,@IdBase mtn_cd_base
			,@Base mtn_base_principal
			,@operacao mtn_cd_operacao
			,@DataPrevistaPagamento mtn_dt_prevista_pagamento
		from 
			#lancamentos as a 
			left join tb_pag_espelhos as b on a.usr_cd_usuario = b.mtn_cd_motorista
												and a.tlm_cod_periodo = b.mtn_cd_pgto_periodo 
												and b.mtn_cd_operacao = @Operacao
												and b.mtn_in_excluido = 0
		where
			b.mtn_cd_motorista_nfs is null
		group by
			usr_cd_usuario
			,tlm_cd_motorista
			,tlm_cod_periodo


	
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
			join tb_pag_espelhos e on d.usr_cd_usuario = e. mtn_cd_motorista
										and d.tlm_cod_periodo = e.mtn_cd_pgto_periodo
										and e.mtn_cd_operacao = @Operacao
										and e.mtn_in_excluido = 0
										and e.mtn_cd_status in (34,228,38)

	



		-- Insere novos lançamentos ou altera o que já foi incluido
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
				join tb_pag_espelhos e on p.ppr_cd_motorista = e. mtn_cd_motorista
										and p.ppr_cd_periodo = e.mtn_cd_pgto_periodo
										and e.mtn_cd_operacao = @Operacao
										and e.mtn_cd_status in (34,228,38)
			where
				p.ppr_cd_periodo = @CodPeriodoPagamento
				and p.ppr_lcto_cd_lancamento is not null
				and p.ppr_cd_tipo_pgto = 1363
				and not exists (select 
									1 
								from 
									vw_lancamentos_manuais_aprovados l 
								where 
									l.tlm_cd_cliente = @CodigoCliente
									and p.ppr_lcto_cd_lancamento = l.tlm_cd_lancamento_manual
									and tlm_cd_cliente_transportadora = @IdCliTransportadora
									and l.tlm_dh_referencia >= @DataInicial 
									and l.tlm_dh_referencia < dateadd(day,1,@DataFinal)
								)

	end --fim do if que verifica se o status está em aberto

end
GO
