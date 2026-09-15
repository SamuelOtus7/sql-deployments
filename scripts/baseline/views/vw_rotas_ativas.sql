-- ============================================================
-- BASELINE: dbo.vw_rotas_ativas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_ativas]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_rotas_ativas] AS

SELECT 
    'MELI' AS Origem,
    cli_cd_codigo_cliente AS TenantId,
    datareferencia AS Data,
    COUNT(*) AS Qtd
FROM tb_ml_rotas AS a WITH (NOLOCK)
INNER JOIN tb_clientes AS b
    ON a.idtransportadora = b.cli_id_logistics
WHERE 
    a.excluido = 0
    AND a.statusrota <> 'planeed'
    AND a.datareferencia >= DATEADD(MONTH, -8, GETDATE())
    AND b.cli_in_ativo = 1
    AND b.cli_cd_codigo_cliente <> 7
GROUP BY 
    b.cli_cd_codigo_cliente,
    a.datareferencia

UNION ALL

SELECT 
    'Shoppe' AS Origem,
    cli_cd_codigo_cliente AS TenantId,
    datareferencia AS Data,
    COUNT(*) AS Qtd
FROM tb_spe_rotas_v5 AS a WITH (NOLOCK)
INNER JOIN tb_clientes AS b
    ON a.idtransportadora = b.cli_id_shopee
WHERE 
    a.excluido = 0
    AND a.datareferencia >= DATEADD(MONTH, -8, GETDATE())
    AND b.cli_in_ativo = 1
    AND b.cli_cd_codigo_cliente <> 7
GROUP BY 
    b.cli_cd_codigo_cliente,
    a.datareferencia;
GO
