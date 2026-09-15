-- ============================================================
-- BASELINE: dbo.vw_pacotes_diaatual_alc
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_diaatual_alc]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vw_pacotes_diaatual_alc]
as
SELECT 
	p.*
FROM 
	vw_pacotes_diaatual p
where
	p.IdTransportadora = 2087146923
GO
