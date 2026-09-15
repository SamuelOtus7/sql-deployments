-- ============================================================
-- BASELINE: dbo.vw_service_center_alc
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_service_center_alc]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_service_center_alc]
as
select
	dst_servicecenter,
	dst_status
from
	tb_dra_service_center_tranportadora
where
	dst_cd_transportadora = 2087146923
GO
