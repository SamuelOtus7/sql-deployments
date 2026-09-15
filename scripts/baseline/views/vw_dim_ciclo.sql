-- ============================================================
-- BASELINE: dbo.vw_dim_ciclo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dim_ciclo]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_dim_ciclo] AS
SELECT
    DENSE_RANK() OVER (ORDER BY ppr_ds_ciclo) AS sk_ciclo,
    ppr_ds_ciclo AS Ciclo
FROM (SELECT DISTINCT ppr_ds_ciclo FROM dbo.tb_pgto_periodo_rota WITH (NOLOCK) WHERE ppr_ds_ciclo IS NOT NULL) t;
GO
