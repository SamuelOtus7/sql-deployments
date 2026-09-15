-- ============================================================
-- BASELINE: dbo.vw_validacao_teste_espelho_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacao_teste_espelho_motorista]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_validacao_teste_espelho_motorista]
as
select 
	isnull(a.mtn_cd_pgto_periodo,d.mtn_cd_pgto_periodo) Periodo
	,isnull(a.mtn_cd_motorista,d.mtn_cd_motorista) mtn_cd_motorista
	,isnull(a.mtn_cd_base,d.mtn_cd_base) mtn_cd_base
	,isnull(a.mtn_base_principal,d.mtn_base_principal) mtn_base_principal
	,isnull(a.mtn_nome_motorista,d.mtn_nome_motorista) mtn_nome_motorista

	,a.TotalEspelhos TotalEspelhosAntes
	,d.TotalEspelhos TotalEspelhosDepois
	,isnull(a.TotalEspelhos,0) - isnull(d.TotalEspelhos,0) DiferencaTotalEspelhos

	,a.TotalEspelhosExcluidos TotalEspelhosExcluidosAntes
	,d.TotalEspelhosExcluidos TotalEspelhosExcluidosDepois
	,isnull(a.TotalEspelhosExcluidos,0) - isnull(d.TotalEspelhosExcluidos,0) DiferencaTotalEspelhosExcluidos

	,a.TotalEspelhosAtivos TotalEspelhosAtivosAntes
	,d.TotalEspelhosAtivos TotalEspelhosAtivosDepois
	,isnull(a.TotalEspelhosAtivos,0) - isnull(d.TotalEspelhosAtivos,0) DiferencaTotalEspelhosAtivos

	,a.TotalPagamentoEspelhos TotalPagamentoEspelhosAntes
	,d.TotalPagamentoEspelhos TotalPagamentoEspelhosDepois
	,isnull(a.TotalPagamentoEspelhos,0) - isnull(d.TotalPagamentoEspelhos,0) DiferencaTotalPagamentoEspelhos

	,a.TotalPagamentoLiquidoEspelhos TotalPagamentoLiquidoEspelhosAntes
	,d.TotalPagamentoLiquidoEspelhos TotalPagamentoLiquidoEspelhosDepois
	,isnull(a.TotalPagamentoLiquidoEspelhos,0) - isnull(d.TotalPagamentoLiquidoEspelhos,0) DiferencaTotalPagamentoLiquidoEspelhos

from 
	(select 
		mtn_cd_pgto_periodo
		,isnull(mtn_cd_motorista,-1) mtn_cd_motorista
		,isnull(mtn_cd_base,-1) mtn_cd_base
		,isnull(mtn_base_principal,'') mtn_base_principal
		,isnull(mtn_nome_motorista,'') mtn_nome_motorista
		,count(1) TotalEspelhos
		,count(case when mtn_in_excluido = 0 then 1 end) TotalEspelhosAtivos
		,count(case when mtn_in_excluido = 1 then 1 end) TotalEspelhosExcluidos
		,sum(case when mtn_in_excluido = 0 then mtn_vl_nfs end) TotalPagamentoEspelhos
		,sum(case when mtn_in_excluido = 0 then mtn_vl_liquido end) TotalPagamentoLiquidoEspelhos
	from 
		tb_pag_espelhos_teste_calculo 
	where 
		mtn_fase_teste = 'Antes'
	group by
		mtn_cd_pgto_periodo
		,isnull(mtn_cd_motorista,-1) 
		,isnull(mtn_cd_base,-1)
		,isnull(mtn_base_principal,'')
		,isnull(mtn_nome_motorista,'')
	) a
	full join (select 
					mtn_cd_pgto_periodo
					,isnull(mtn_cd_motorista,-1) mtn_cd_motorista
					,isnull(mtn_cd_base,-1) mtn_cd_base
					,isnull(mtn_base_principal,'') mtn_base_principal
					,isnull(mtn_nome_motorista,'') mtn_nome_motorista
					,count(1) TotalEspelhos
					,count(case when mtn_in_excluido = 0 then 1 end) TotalEspelhosAtivos
					,count(case when mtn_in_excluido = 1 then 1 end) TotalEspelhosExcluidos
					,sum(case when mtn_in_excluido = 0 then mtn_vl_nfs end) TotalPagamentoEspelhos
					,sum(case when mtn_in_excluido = 0 then mtn_vl_liquido end) TotalPagamentoLiquidoEspelhos
				from 
					tb_pag_espelhos_teste_calculo 
				where 
					mtn_fase_teste = 'Depois'
				group by
					mtn_cd_pgto_periodo
					,isnull(mtn_cd_motorista,-1) 
					,isnull(mtn_cd_base,-1)
					,isnull(mtn_base_principal,'')
					,isnull(mtn_nome_motorista,'')
				) d on a.mtn_cd_pgto_periodo = d.mtn_cd_pgto_periodo
					and a.mtn_cd_motorista = d.mtn_cd_motorista
					and a.mtn_cd_base = d.mtn_cd_base
					and a.mtn_base_principal = d.mtn_base_principal
					and a.mtn_nome_motorista = d.mtn_nome_motorista
where
	ISNULL(a.TotalEspelhos,0) <> ISNULL(d.TotalEspelhos,0)
	or ISNULL(a.TotalEspelhosAtivos,0) <> ISNULL(d.TotalEspelhosAtivos,0)
	or ISNULL(a.TotalEspelhosExcluidos,0) <> ISNULL(d.TotalEspelhosExcluidos,0)
	or ISNULL(a.TotalPagamentoEspelhos,0) <> ISNULL(d.TotalPagamentoEspelhos,0)
	or ISNULL(a.TotalPagamentoLiquidoEspelhos,0) <> ISNULL(d.TotalPagamentoLiquidoEspelhos,0)
GO
