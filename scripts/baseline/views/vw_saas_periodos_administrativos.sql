-- ============================================================
-- BASELINE: dbo.vw_saas_periodos_administrativos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_periodos_administrativos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_saas_periodos_administrativos]
as
select
	per.pgp_cd_periodo IdPeriodo
	,per.pgp_cd_cliente IdTenant
	,per.pgp_nm_periodo NomePeriodo
	,per.pgp_dt_inicio DataInicioPeriodo
	,per.pgp_dt_fim DataFimPeriodo
	,per.pgp_dt_limite_reanalise DataLimiteReanalise
	,per.pgp_dt_pagamento DataPagamentoPeriodo
from
	tb_pgto_periodo per with(nolock)
	join tb_lista mkt with(nolock) on per.pgp_cd_cliente_transportadora = mkt.lst_cd_lista
where
	per.pgp_in_excluido = 0
	and mkt.lst_ds_valor = 'Administrativo'
GO
