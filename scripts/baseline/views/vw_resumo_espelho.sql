-- ============================================================
-- BASELINE: dbo.vw_resumo_espelho
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_resumo_espelho]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_resumo_espelho]
as
select 
    ppr_cd_periodo
	,ppr_cd_rota Rota
	,ppr_base_principal SVC
	,ppr_ds_ciclo Ciclo
	,ppr_ds_tipo_veiculo Tipo_Veiculo
	,ppr_nome_motorista Motorista
	,cast(case when b.pgp_dt_inicio >= dateadd(day,-30,cast(getdate() as date)) then cast(getdate() as date) else b.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
    ,sum(ppr_vl_total) Total
	,sum(c.RecebMeli) RecebMeli
from 
	tb_pgto_periodo_rota a with(nolock)
	inner join tb_pgto_periodo as b with(nolock) on a.ppr_cd_periodo = b.pgp_cd_periodo
	left join vw_resultado_financeiro as c on a.ppr_cd_rota = c.IdRota
where 
	pgp_cd_status = 1
	and pgp_cd_periodo >= 370 
	and ppr_in_excluido = 0 
	and b.pgp_in_excluido = 0
group by
	ppr_cd_rota
	,ppr_cd_periodo
	,ppr_base_principal
	,ppr_ds_ciclo
	,ppr_ds_tipo_veiculo
	,ppr_nome_motorista
	,pgp_dt_inicio
GO
