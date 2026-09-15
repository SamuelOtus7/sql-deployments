-- ============================================================
-- BASELINE: dbo.vw_calculo_imposto
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_calculo_imposto]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_calculo_imposto] AS
SELECT
    p.cdi_cd_base,
    p.cdi_cd_cliente,
    b.bss_ds_sigla,       -- << nova coluna aqui
    p.[RDM],
    p.[Gestao],
    p.[ISS],
    p.[Comercial]
FROM (
    SELECT
        cdi_cd_base,
        cdi_cd_cliente,
        cdi_ds_imposto,
        cdi_vl_imposto
    FROM tb_fin_cadastro_impostos
    WHERE cdi_cd_cliente = 63
) AS src
PIVOT (
    MAX(cdi_vl_imposto)
    FOR cdi_ds_imposto IN ([RDM], [Gestao], [ISS], [Comercial])
) AS p
LEFT JOIN tb_bases b
    ON p.cdi_cd_base = b.bss_cd_base;   -- join conforme você informou
GO
