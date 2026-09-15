-- ============================================================
-- BASELINE: dbo.UspRecalculaApoioPercentual
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspRecalculaApoioPercentual]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspRecalculaApoioPercentual] (
	@CodPeriodoPagamento int
)
as
begin

	SET NOCOUNT ON;

	drop table if exists #lancamentos_apoio_percentual
	select
		tlm_cd_lancamento_manual
		,tlm_cd_rota
		,tlm_vl_valor_apoio
		,tlm_vl_valor_apoio / 100.00 percentual
		,cast(0 as decimal(18,4)) valor_apoio_calculado
		into #lancamentos_apoio_percentual
	from 
		tb_lancamentos_manuais lan with(nolock)
		join tb_aprovacao_lancamento_manual apv with(nolock) on alm_cd_lancamento_manual = tlm_cd_lancamento_manual
		left join tb_tipos_lancamentos_manuais tip with(nolock) on tip.plm_cd_tipo_lancamento_manual = lan.tlm_cd_tipo
	where 
		tlm_in_ativo = 1
		and alm_ds_status = 'Aprovado'
		and tip.plm_nm_tipo = 'Apoio'
		and tlm_tipo_valor_apoio = 'Percentual'
		--Por enquanto só realiza calculo para 50+
		and tlm_cd_cliente = 11
		


	-- Calcula valor do apoio com base no percentual do valor da rota
	update
		l
	set
		valor_apoio_calculado = l.percentual * p.ppr_vl_base
	from
		#lancamentos_apoio_percentual l
		join tb_pgto_periodo_rota p on l.tlm_cd_rota = p.ppr_cd_rota
	where
		p.ppr_cd_periodo = @CodPeriodoPagamento


	-- Ajusta valor do motorista que deve receber o apoio
	update
		p
	set
		p.ppr_vl_lancamentos = l.valor_apoio_calculado
		,p.ppr_vl_total = l.valor_apoio_calculado
	from
		#lancamentos_apoio_percentual l
		join tb_pgto_periodo_rota p on l.tlm_cd_lancamento_manual = p.ppr_lcto_cd_lancamento
	where
		p.ppr_cd_periodo = @CodPeriodoPagamento
	--select
	--	p.ppr_vl_lancamentos
	--	,p.ppr_vl_total
	--	,l.valor_apoio_calculado
	--	,l.tlm_vl_valor_apoio
	--from
	--	#lancamentos_apoio_percentual l
	--	join tb_pgto_periodo_rota p on l.tlm_cd_lancamento_manual = p.ppr_lcto_cd_lancamento
	--where
	--	p.ppr_cd_periodo = 444


	-- Ajusta valor do motorista que deve descontar o apoio
	update
		p
	set
		ppr_vl_lancamentos = p.ppr_vl_lancamentos+tlm_vl_valor_apoio-valor_apoio_calculado
		,ppr_vl_total = (ppr_vl_total-ppr_vl_lancamentos)+(ppr_vl_lancamentos+tlm_vl_valor_apoio-valor_apoio_calculado)
	from
		#lancamentos_apoio_percentual l
		join tb_pgto_periodo_rota p on l.tlm_cd_rota = p.ppr_cd_rota
	where
		p.ppr_cd_periodo = @CodPeriodoPagamento
	--select
	--	p.ppr_vl_lancamentos
	--	,p.ppr_vl_total
	--	,l.valor_apoio_calculado
	--	,l.tlm_vl_valor_apoio
	--	,p.ppr_vl_lancamentos+tlm_vl_valor_apoio-valor_apoio_calculado
	--	,ppr_vl_total = (ppr_vl_total-ppr_vl_lancamentos)+(ppr_vl_lancamentos+tlm_vl_valor_apoio-valor_apoio_calculado)
	--from
	--	#lancamentos_apoio_percentual l
	--	join tb_pgto_periodo_rota p on l.tlm_cd_rota = p.ppr_cd_rota
	--where
	--	p.ppr_cd_periodo = 444






end
GO
