-- ============================================================
-- BASELINE: dbo.tb_geotab_final
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[tb_geotab_final]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[tb_geotab_final] as 
select * from [dbo].[tb_geotab_stg]
UNION ALL
select * from [dbo].[tb_geotab_stg2]
;
GO
