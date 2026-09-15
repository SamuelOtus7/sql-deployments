-- ============================================================
-- BASELINE: dbo.vw_validacao_teste_pgto_geral
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacao_teste_pgto_geral]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[vw_validacao_teste_pgto_geral]
as
select 
	isnull(a.ppr_cd_periodo,d.ppr_cd_periodo) Periodo

	,a.TotalRegistros TotalRegistrosAntes
	,d.TotalRegistros TotalRegistrosDepois
	,isnull(a.TotalRegistros,0) - isnull(d.TotalRegistros,0) DiferencaTotalRegistros

	,a.TotalRegistrosAtivos TotalRegistrosAtivosAntes
	,d.TotalRegistrosAtivos TotalRegistrosAtivosDepois
	,isnull(a.TotalRegistrosAtivos,0) - isnull(d.TotalRegistrosAtivos,0) DiferencaTotalRegistrosAtivos

	,a.TotalRegistrosExcluidos TotalRegistrosExcluidosAntes
	,d.TotalRegistrosExcluidos TotalRegistrosExcluidosDepois
	,isnull(a.TotalRegistrosExcluidos,0) - isnull(d.TotalRegistrosExcluidos,0) DiferencaTotalRegistrosExcluidos

	,a.TotalBase TotalBaseAntes
	,d.TotalBase TotalBaseDepois
	,isnull(a.TotalBase,0) - isnull(d.TotalBase,0) DiferencaTotalBase

	,a.TotalDomingo TotalDomingoAntes
	,d.TotalDomingo TotalDomingoDepois
	,isnull(a.TotalDomingo,0) - isnull(d.TotalDomingo,0) DiferencaTotalDomingo

	,a.TotalParadas TotalParadasAntes
	,d.TotalParadas TotalParadasDepois
	,isnull(a.TotalParadas,0) - isnull(d.TotalParadas,0) DiferencaTotalParadas

	,a.TotalLancamentos TotalLancamentosAntes
	,d.TotalLancamentos TotalLancamentosDepois
	,isnull(a.TotalLancamentos,0) - isnull(d.TotalLancamentos,0) DiferencaTotalLancamentos

	,a.TotalGeral TotalGeralAntes
	,d.TotalGeral TotalGeralDepois
	,isnull(a.TotalGeral,0) - isnull(d.TotalGeral,0) DiferencaTotalGeral
from 
	(select 
		ppr_cd_periodo
		,count(1) TotalRegistros
		,count(case when ppr_in_excluido = 0 then 1 end) TotalRegistrosAtivos
		,count(case when ppr_in_excluido = 1 then 1 end) TotalRegistrosExcluidos
		,sum(case when ppr_in_excluido = 0 then ppr_vl_base end) TotalBase
		,sum(case when ppr_in_excluido = 0 then ppr_vl_dom_fer end) TotalDomingo
		,sum(case when ppr_in_excluido = 0 then ppr_vl_paradas end) TotalParadas
		,sum(case when ppr_in_excluido = 0 then ppr_vl_lancamentos end) TotalLancamentos
		,sum(case when ppr_in_excluido = 0 then ppr_vl_total end) TotalGeral
	from 
		tb_pgto_periodo_rota_teste_calculo 
	where 
		ppr_fase_teste = 'Antes'
	group by
		ppr_cd_periodo
	) a
	full join (select 
					ppr_cd_periodo
					,count(1) TotalRegistros
					,count(case when ppr_in_excluido = 0 then 1 end) TotalRegistrosAtivos
					,count(case when ppr_in_excluido = 1 then 1 end) TotalRegistrosExcluidos
					,sum(case when ppr_in_excluido = 0 then ppr_vl_base end) TotalBase
					,sum(case when ppr_in_excluido = 0 then ppr_vl_dom_fer end) TotalDomingo
					,sum(case when ppr_in_excluido = 0 then ppr_vl_paradas end) TotalParadas
					,sum(case when ppr_in_excluido = 0 then ppr_vl_lancamentos end) TotalLancamentos
					,sum(case when ppr_in_excluido = 0 then ppr_vl_total end) TotalGeral
				from 
					tb_pgto_periodo_rota_teste_calculo 
				where 
					ppr_fase_teste = 'Depois'
				group by
					ppr_cd_periodo
				) d on a.ppr_cd_periodo = d.ppr_cd_periodo
where
	ISNULL(a.TotalRegistros,0) <> ISNULL(d.TotalRegistros,0)
	or ISNULL(a.TotalRegistrosAtivos,0) <> ISNULL(d.TotalRegistrosAtivos,0)
	or ISNULL(a.TotalRegistrosExcluidos,0) <> ISNULL(d.TotalRegistrosExcluidos,0)
	or ISNULL(a.TotalBase,0) <> ISNULL(d.TotalBase,0)
	or ISNULL(a.TotalDomingo,0) <> ISNULL(d.TotalDomingo,0)
	or ISNULL(a.TotalParadas,0) <> ISNULL(d.TotalParadas,0)
	or ISNULL(a.TotalLancamentos,0) <> ISNULL(d.TotalLancamentos,0)
	or ISNULL(a.TotalGeral,0) <> ISNULL(d.TotalGeral,0)
GO
