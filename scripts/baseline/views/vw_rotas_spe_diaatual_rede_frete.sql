-- ============================================================
-- BASELINE: dbo.vw_rotas_spe_diaatual_rede_frete
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_spe_diaatual_rede_frete]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_rotas_spe_diaatual_rede_frete]
as
select
	*
from
	vw_rotas_spe_rede_frete
where
	DataReferencia = cast(getdate() as date)
	and 1=0
GO
