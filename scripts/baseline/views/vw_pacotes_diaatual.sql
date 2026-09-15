-- ============================================================
-- BASELINE: dbo.vw_pacotes_diaatual
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_diaatual]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vw_pacotes_diaatual]
as
SELECT
	p.*
FROM 
	vw_pacotes p
where
	p.DataReferencia = cast(getdate() as date)
	
GO
