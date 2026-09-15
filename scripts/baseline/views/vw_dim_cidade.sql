-- ============================================================
-- BASELINE: dbo.vw_dim_cidade
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dim_cidade]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_dim_cidade] AS
SELECT
    DENSE_RANK() OVER (ORDER BY ppr_nm_cidade) AS sk_cidade,
    ppr_nm_cidade AS Cidade
FROM (SELECT DISTINCT ppr_nm_cidade FROM dbo.tb_pgto_periodo_rota WITH (NOLOCK) WHERE ppr_nm_cidade IS NOT NULL) t;
GO
