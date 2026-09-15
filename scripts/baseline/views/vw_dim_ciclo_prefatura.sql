-- ============================================================
-- BASELINE: dbo.vw_dim_ciclo_prefatura
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dim_ciclo_prefatura]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_dim_ciclo_prefatura] AS
SELECT
    DENSE_RANK() OVER (ORDER BY CicloPM) AS sk_ciclo_prefatura,
    CicloPM AS Ciclo_Prefatura
FROM (SELECT DISTINCT CicloPM FROM dbo.tb_fin_prefatura WITH (NOLOCK) WHERE CicloPM IS NOT NULL) t;
GO
