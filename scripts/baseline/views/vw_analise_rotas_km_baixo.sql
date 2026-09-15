-- ============================================================
-- BASELINE: dbo.vw_analise_rotas_km_baixo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_analise_rotas_km_baixo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[vw_analise_rotas_km_baixo]
AS

WITH rotas_dedup AS (
    SELECT
        r.IdTransportadora,
        r.Idrota,
        r.data                 AS Data,
        r.Base,
        r.Motorista,
        r.UsuarioDA,
        r.KmApp,
        r.pontosRotasPacotesKm,
        r.FaixaPrimeiroUltimoPacote,
        r.UsouApp,
        r.ColetouGps,
        ROW_NUMBER() OVER (
            PARTITION BY r.Idrota, r.Data
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM dbo.vw_rotas_motoristas_aderencia AS r WITH (NOLOCK)
),
rotas AS (
    SELECT
        r.IdTransportadora,
        r.Idrota,
        r.Data,
        r.Base,
        r.Motorista,
        r.UsuarioDA,
        r.KmApp,
        r.pontosRotasPacotesKm,
        r.FaixaPrimeiroUltimoPacote,
        r.UsouApp,
        r.ColetouGps
    FROM rotas_dedup AS r
    WHERE r.rn = 1
),
gps AS (
    SELECT
        rgp_cd_usuario                                  AS Usuario,
        CAST(rgp_dh_data_hora AS date)                  AS Data,
        COUNT(*)                                        AS QuantidadeApontamento,
        MIN(DATEADD(HOUR, -3, rgp_dh_data_hora))        AS InicioApp,
        MAX(DATEADD(HOUR, -3, rgp_dh_data_hora))        AS FimApp
    FROM dbo.tb_registro_gps WITH (NOLOCK)
    WHERE rgp_dh_data_hora IS NOT NULL
    and CAST(rgp_dh_data_hora AS date) >= cast(GETDATE()-90 as date)
    GROUP BY
        rgp_cd_usuario,
        CAST(rgp_dh_data_hora AS date)
),
entregas AS (
    SELECT
        IdRota,
        MIN(DataHoraEntrega)    AS PrimeiraEntrega,
        MAX(DataHoraEntrega)    AS UltimaEntrega,
        COUNT(*)                AS QtdPacotes
    FROM dbo.tb_ml_pacotes WITH (NOLOCK)
    WHERE Excluido = 0
    and CAST(DataReferencia AS date) >= cast(GETDATE()-90 as date)
    GROUP BY IdRota
)
SELECT
    r.IdTransportadora,
    r.Idrota,
    r.Data,
    r.Base,
    r.Motorista,
    r.UsuarioDA,
    r.KmApp,
    r.pontosRotasPacotesKm,
    g.QuantidadeApontamento,
    g.InicioApp,
    g.FimApp,
    p.PrimeiraEntrega,
    p.UltimaEntrega,
    p.QtdPacotes,

    -- Faixa de quantidade de apontamentos
    CASE
        WHEN g.QuantidadeApontamento <= 10                      THEN 'Até 10'
        WHEN g.QuantidadeApontamento <= 50                      THEN '11 a 50'
        WHEN g.QuantidadeApontamento <= 100                     THEN '51 a 100'
        WHEN g.QuantidadeApontamento <= 150                     THEN '101 a 150'
        ELSE                                                         'Maior que 150'
    END AS FaixaQtdApontamentos,

    -- Tempo em que o primeiro apontamento GPS ocorreu em relacao a primeira entrega
    -- Positivo = GPS iniciou depois da primeira entrega
    -- Negativo = GPS iniciou antes da primeira entrega
    DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) AS MinInicioApp_PrimeiraEntrega,
    CASE
        WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) < 0   THEN 'Antes da primeira entrega'
        WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 10 THEN 'Até 10 min depois'
        WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 30 THEN '10 a 30 min depois'
        WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 60 THEN '30 a 60 min depois'
        WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 90 THEN '60 a 90 min depois'
        WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 120 THEN '90 a 120 min depois'
        WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 150 THEN '120 a 150 min depois'
        ELSE 'Maior que 150 min depois'
    END AS FaixaTempoInicioApp,

    -- Tempo em que o ultimo apontamento GPS ocorreu em relacao a ultima entrega
    -- Positivo = GPS terminou antes da ultima entrega
    -- Negativo = GPS terminou depois da ultima entrega
    DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) AS MinFimApp_UltimaEntrega,
    CASE
        WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) < 0   THEN 'Depois da ultima entrega'
        WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 10 THEN 'Até 10 min antes'
        WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 30 THEN '10 a 30 min antes'
        WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 60 THEN '30 a 60 min antes'
        WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 90 THEN '60 a 90 min antes'
        WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 120 THEN '90 a 120 min antes'
        WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 150 THEN '120 a 150 min antes'
        ELSE 'Maior que 150 min antes'
    END AS FaixaTempoFimApp,

    -- Percentual de atingimento do km pacote
    CASE
        WHEN NULLIF(r.pontosRotasPacotesKm, 0) IS NOT NULL
        THEN CAST((r.KmApp / NULLIF(r.pontosRotasPacotesKm, 0)) * 100.0 AS DECIMAL(10, 2))
        ELSE NULL
    END AS PercAtingimentoKmApp,

    CASE
        WHEN NULLIF(r.pontosRotasPacotesKm, 0) IS NOT NULL
         AND r.KmApp < 0.9 * r.pontosRotasPacotesKm
        THEN 'Sim'
        ELSE 'Não'
    END AS KmApp_Menor_90_Perc,

    -- Flags originais da base
    r.FaixaPrimeiroUltimoPacote,
    r.UsouApp,
    r.ColetouGps

FROM rotas AS r
LEFT JOIN gps AS g
    ON g.Usuario = r.UsuarioDA
   AND g.Data    = r.Data
LEFT JOIN entregas AS p
    ON p.IdRota = TRY_CONVERT(INT, r.Idrota);

GO
