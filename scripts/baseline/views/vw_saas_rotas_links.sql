-- ============================================================
-- BASELINE: dbo.vw_saas_rotas_links
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_rotas_links]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[vw_saas_rotas_links]
as
select
	Id 
	,DataReferencia
	,LinkMapa
	,LinkMapaMeli
	,LogisticsRota
from
	 vw_rotas r

GO
