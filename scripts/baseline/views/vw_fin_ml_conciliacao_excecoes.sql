-- ============================================================
-- BASELINE: dbo.vw_fin_ml_conciliacao_excecoes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_ml_conciliacao_excecoes]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_fin_ml_conciliacao_excecoes] AS
SELECT
    c.pfc_cd_transportadora AS IdTransportadora,
    c.pfc_nu_ano AS Ano,
    c.pfc_nu_mes AS Mes,
    c.pfc_nu_quinzena AS Quinzena,
    c.pfc_cd_rota AS IdRota,
    CONCAT_WS('|', c.pfc_cd_transportadora, c.pfc_nu_ano, c.pfc_nu_mes, c.pfc_cd_rota) AS ChaveRota,
    'COMPLEMENTAR_SEM_PREFATURA' AS TipoExcecao,
    'Alta' AS Severidade,
    'Rota no complementar sem correspondencia na prefatura' AS Descricao,
    c.pfc_ds_conceito_billing AS ConceitoBilling,
    c.pfc_ds_status_final AS StatusFinal,
    c.pfc_vl_servico AS Valor,
    c.pfc_ds_service_center AS ServiceCenter,
    NULL AS Veiculo,
    NULL AS Placa,
    NULL AS Motorista
FROM dbo.tb_fin_prefatura_complementar c
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.tb_fin_prefatura p
    WHERE p.IdRota = c.pfc_cd_rota
      AND p.IdTransportadora = c.pfc_cd_transportadora
      AND p.Ano = c.pfc_nu_ano
      AND p.Mes = c.pfc_nu_mes)

UNION ALL

SELECT
    p.IdTransportadora, p.Ano, p.Mes, p.Quinzena, p.IdRota,
    CONCAT_WS('|', p.IdTransportadora, p.Ano, p.Mes, p.IdRota),
    'PREFATURA_VALOR_ZERO', 'Media',
    'Rota com valor de prefatura zero (ambulancia)',
    NULL, NULL, 0.00,
    p.ServiceCenter, p.Veiculo, p.Placa, p.Motorista
FROM dbo.tb_fin_prefatura p
WHERE p.Total = 0

UNION ALL

SELECT
    p.IdTransportadora, p.Ano, p.Mes, p.Quinzena, p.IdRota,
    CONCAT_WS('|', p.IdTransportadora, p.Ano, p.Mes, p.IdRota),
    'TOTAL_INCONSISTENTE', 'Alta',
    'Total difere de Quantidade x PrecoUnitario',
    NULL, NULL, p.Total,
    p.ServiceCenter, p.Veiculo, p.Placa, p.Motorista
FROM dbo.tb_fin_prefatura p
WHERE ABS(p.Total - ISNULL(p.Quantidade,0) * ISNULL(p.PrecoUnitario,0)) > 0.01

UNION ALL

SELECT
    p.IdTransportadora, p.Ano, p.Mes, p.Quinzena, p.IdRota,
    CONCAT_WS('|', p.IdTransportadora, p.Ano, p.Mes, p.IdRota),
    'VEICULO_DIVERGENTE', 'Media',
    'Tipo de veiculo divergente entre prefatura e complementar',
    NULL, NULL, NULL,
    p.ServiceCenter, p.Veiculo, p.Placa, p.Motorista
FROM dbo.tb_fin_prefatura p
WHERE EXISTS (
    SELECT 1 FROM dbo.tb_fin_prefatura_complementar c
    WHERE c.pfc_cd_rota = p.IdRota
      AND c.pfc_cd_transportadora = p.IdTransportadora
      AND c.pfc_nu_ano = p.Ano
      AND c.pfc_nu_mes = p.Mes
      AND c.pfc_ds_tipo_veiculo IS NOT NULL
      AND c.pfc_ds_tipo_veiculo <> p.Veiculo)

UNION ALL

SELECT
    p.IdTransportadora, p.Ano, p.Mes, p.Quinzena, p.IdRota,
    CONCAT_WS('|', p.IdTransportadora, p.Ano, p.Mes, p.IdRota),
    'ROTA_DUPLICADA_NO_PERIODO', 'Alta',
    'Chave transportadora+ano+mes+rota duplicada na prefatura',
    NULL, NULL, p.Total,
    p.ServiceCenter, p.Veiculo, p.Placa, p.Motorista
FROM dbo.tb_fin_prefatura p
WHERE EXISTS (
    SELECT 1 FROM (SELECT IdTransportadora, Ano, Mes, IdRota
                   FROM dbo.tb_fin_prefatura
                   GROUP BY IdTransportadora, Ano, Mes, IdRota
                   HAVING COUNT(*) > 1) d
    WHERE d.IdTransportadora = p.IdTransportadora
      AND d.Ano = p.Ano AND d.Mes = p.Mes AND d.IdRota = p.IdRota)

UNION ALL

SELECT
    p.IdTransportadora, p.Ano, p.Mes, p.Quinzena, p.IdRota,
    CONCAT_WS('|', p.IdTransportadora, p.Ano, p.Mes, p.IdRota),
    'TIPO_CICLO_NAO_MAPEADO', 'Baixa',
    'Tipo de ciclo nao mapeado: ' + ISNULL(p.KmCiclo, 'NULL'),
    NULL, NULL, p.Total,
    p.ServiceCenter, p.Veiculo, p.Placa, p.Motorista
FROM dbo.tb_fin_prefatura p
WHERE p.KmCiclo = 'ART TIME D ROUTE' OR p.KmCiclo IS NULL
GO
