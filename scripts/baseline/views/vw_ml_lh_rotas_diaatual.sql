-- ============================================================
-- BASELINE: dbo.vw_ml_lh_rotas_diaatual
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_lh_rotas_diaatual]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_ml_lh_rotas_diaatual]
as
select
	*
from
	vw_ml_lh_rotas
where
	DataReferencia = cast(getdate() as date)
GO
