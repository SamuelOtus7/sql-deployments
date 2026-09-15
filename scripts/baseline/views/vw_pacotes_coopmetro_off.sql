-- ============================================================
-- BASELINE: dbo.vw_pacotes_coopmetro_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_coopmetro_off]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[vw_pacotes_coopmetro_off]
as
SELECT 
	p.*
FROM 
	vw_pacotes p
where
	p.IdTransportadora = 1070423464
	--and p.DataReferencia >= dateadd(month,-3,getdate())
GO
