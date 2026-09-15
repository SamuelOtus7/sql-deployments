-- ============================================================
-- BASELINE: dbo.vw_ssas_service_center
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssas_service_center]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_ssas_service_center]
as
select 
	distinct
	svc_cd_service_center ServiceCenter
from
	tb_ml_service_center
GO
