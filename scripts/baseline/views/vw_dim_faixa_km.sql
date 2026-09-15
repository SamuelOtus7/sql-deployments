-- ============================================================
-- BASELINE: dbo.vw_dim_faixa_km
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dim_faixa_km]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_dim_faixa_km] AS
SELECT
    cd_faixa_km AS sk_faixa_km,
    ds_faixa_original AS Faixa_KM_original,
    km_inicio,
    km_fim,
    ds_descricao
FROM dbo.tb_dim_faixa_km
WHERE in_ativo = 1;
GO
