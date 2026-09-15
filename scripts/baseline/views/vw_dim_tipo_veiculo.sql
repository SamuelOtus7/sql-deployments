-- ============================================================
-- BASELINE: dbo.vw_dim_tipo_veiculo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dim_tipo_veiculo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_dim_tipo_veiculo] AS
SELECT
    tvl_cd_tipo_veiculo AS sk_tipo_veiculo,
    tvl_nm_tipo_veiculo AS Tipo_Veiculo
FROM dbo.tb_dra_tipo_veiculo WITH (NOLOCK);
GO
