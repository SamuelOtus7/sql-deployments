-- ============================================================
-- BASELINE: dbo.vw_rotas_motoristas_aderencia_v2
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_motoristas_aderencia_v2]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[vw_rotas_motoristas_aderencia_v2]
AS

WITH rotas_base AS (
    SELECT
        a.IdTransportadora,
        a.IdRota,
        a.DataReferencia,
        a.OrigemSaida,
        a.ServiceCenter,
        a.NomeMotorista,
        a.TipoVeiculo,
        a.Apuracao,
        a.LinkAppInterno,
        a.LinkMapaApp,
        a.UsouApp,
        a.UsuarioDA,
        a.StatusRota,
        a.IdTrevo
    FROM dbo.tb_ml_rotas AS a WITH (NOLOCK)
    WHERE a.Excluido = 0
      AND a.StatusRota <> 'planned'
      AND a.DataReferencia >= DATEADD(MONTH, -2, CAST(GETDATE() AS date))
      AND a.DataReferencia <= CAST(GETDATE() - 1 AS date)
      AND a.IdTransportadora IN (1024706007)
),
pacotes_janela AS (
    SELECT
        p.IdRota,
        p.DataReferencia,
        MIN(p.DataHoraEntrega) AS PrimeiraDataHoraEntrega,
        MAX(p.DataHoraEntrega) AS UltimaDataHoraEntrega
    FROM dbo.tb_ml_pacotes AS p WITH (NOLOCK)
    WHERE p.DataReferencia >= DATEADD(MONTH, -3, GETDATE())
      AND p.Excluido = 0
    GROUP BY
        p.IdRota,
        p.DataReferencia
),
acao_gps_dia AS (
    SELECT
        g.agp_cd_usuario,
        CAST(DATEADD(hour, -3, g.agp_dh_data_hora) AS date) AS DataLocal,
        COUNT(CASE WHEN g.agp_ds_acao = 'I' THEN 1 END) AS QtInicio,
        COUNT(CASE WHEN g.agp_ds_acao = 'F' THEN 1 END) AS QtFim,
        MIN(CASE WHEN g.agp_ds_acao = 'I'
                 THEN DATEADD(hour, -3, g.agp_dh_data_hora) END) AS InicioAppMin,
        MAX(CASE WHEN g.agp_ds_acao = 'F'
                 THEN DATEADD(hour, -3, g.agp_dh_data_hora) END) AS FimAppMax
    FROM dbo.tb_acao_gps AS g WITH (NOLOCK)
    WHERE g.agp_dh_data_hora >= DATEADD(hour, 3, CAST(DATEADD(MONTH, -2, CAST(GETDATE() AS date)) AS datetime))
      AND g.agp_ds_acao IN ('I', 'F')
    GROUP BY
        g.agp_cd_usuario,
        CAST(DATEADD(hour, -3, g.agp_dh_data_hora) AS date)
),
regra_auditoria AS (
    SELECT
        rk.IdRota,
        rk.IdTransportadora,
        rk.DataReferencia,
        rk.FlagUsoDevidoFin AS FlagPercentual,
        rk.DsMotivoFlagUsoDevidoFin AS DsMotivoPercentual
    FROM (
        SELECT
            rk.IdRota,
            rk.IdTransportadora,
            rk.DataReferencia,
            rk.FlagUsoDevidoFin,
            rk.DsMotivoFlagUsoDevidoFin,
            ROW_NUMBER() OVER (
                PARTITION BY rk.IdRota, rk.IdTransportadora, rk.DataReferencia
                ORDER BY rk.FlagUsoDevidoFin DESC
            ) AS rn
        FROM dbo.vw_pbi_auditoria_km_rotas_v2 AS rk WITH (NOLOCK)
        WHERE rk.IdTransportadora IN (1024706007)
          AND rk.DataReferencia >= DATEADD(MONTH, -2, CAST(GETDATE() AS date))
          AND rk.DataReferencia <= CAST(GETDATE() - 1 AS date)
    ) AS rk
    WHERE rk.rn = 1
)
SELECT
    CAST(r.IdTransportadora AS varchar(50)) AS IdTransportadora,
    CASE WHEN ISNULL(regra.FlagPercentual, 0) = 1 THEN 'Sim' ELSE 'Não' END AS FaixaPrimeiroUltimoPacote,
    CASE
        -- 1. App validation FIRST (so mostra motivo do app se percentual tambem falhou)
        WHEN (acao.QtInicio IS NULL OR acao.QtInicio = 0)
             AND ISNULL(regra.FlagPercentual, 0) = 0
            THEN 'App não foi aberto no dia'
        WHEN (acao.QtFim IS NULL OR acao.QtFim = 0)
             AND ISNULL(regra.FlagPercentual, 0) = 0
            THEN 'App não foi fechado no dia'
        WHEN acao.FimAppMax < DATEADD(minute, -20, pac.UltimaDataHoraEntrega)
             AND ISNULL(regra.FlagPercentual, 0) = 0 THEN
            CASE
                WHEN DATEDIFF(minute, acao.FimAppMax, pac.UltimaDataHoraEntrega) < 60
                    THEN 'App fechado entre 20 e 60min antes do fim da rota'
                WHEN DATEDIFF(minute, acao.FimAppMax, pac.UltimaDataHoraEntrega) < 90
                    THEN 'App fechado entre 60 e 90min antes do fim da rota'
                WHEN DATEDIFF(minute, acao.FimAppMax, pac.UltimaDataHoraEntrega) < 120
                    THEN 'App fechado entre 90 e 120min antes do fim da rota'
                WHEN DATEDIFF(minute, acao.FimAppMax, pac.UltimaDataHoraEntrega) < 160
                    THEN 'App fechado entre 120 e 160min antes do fim da rota'
                WHEN DATEDIFF(minute, acao.FimAppMax, pac.UltimaDataHoraEntrega) < 190
                    THEN 'App fechado entre 160 e 190min antes do fim da rota'
                ELSE 'App fechado mais de 190min antes do fim da rota'
            END
        -- 1b. Tempo de uso do app (entre I e F) — faixas
        WHEN acao.QtInicio > 0 AND acao.QtFim > 0
             AND acao.InicioAppMin IS NOT NULL AND acao.FimAppMax IS NOT NULL THEN
            CASE
                WHEN DATEDIFF(minute, acao.InicioAppMin, acao.FimAppMax) <= 5
                    THEN 'App usado até 5min'
                WHEN DATEDIFF(minute, acao.InicioAppMin, acao.FimAppMax) <= 10
                    THEN 'App usado de 5 a 10min'
                WHEN DATEDIFF(minute, acao.InicioAppMin, acao.FimAppMax) <= 20
                    THEN 'App usado de 10 a 20min'
                WHEN DATEDIFF(minute, acao.InicioAppMin, acao.FimAppMax) <= 30
                    THEN 'App usado de 20 a 30min'
                WHEN DATEDIFF(minute, acao.InicioAppMin, acao.FimAppMax) <= 60
                    THEN 'App usado de 30 a 60min'
                WHEN DATEDIFF(minute, acao.InicioAppMin, acao.FimAppMax) <= 120
                    THEN 'App usado de 60 a 120min'
                ELSE 'App usado por mais de 120min'
            END
        -- 2. Percentual validation (mensagens da v1)
        ELSE ISNULL(regra.DsMotivoPercentual, 'App não coletou KM')
    END AS DsMotivoFlagUsoDevidoFin,
    r.OrigemSaida AS Base,
    r.ServiceCenter,
    CAST(r.IdRota AS varchar(50)) AS Idrota,
    r.DataReferencia AS Data,
    r.NomeMotorista AS Motorista,
    r.TipoVeiculo,
    r.Apuracao,
    p.pontosAppRotasTotalKm AS KmApp,
    r.LinkAppInterno,
    r.LinkMapaApp AS LinkApp,
    0 AS QuantidadeApontamento,
    CASE WHEN ISNULL(p.pontosAppRotasTotalKm, 0) > 0 THEN 'Sim' ELSE 'Não' END AS ColetouGps,
    r.UsouApp,
    r.UsuarioDA,
    r.StatusRota,
    r.IdTrevo,
    CASE WHEN r.UsuarioDA IS NOT NULL THEN 'Sim' ELSE 'Não' END AS PossuiUsuario,
    CAST(NULL AS varchar(50)) AS UltimaRota,
    p.pontosRotasPacotesKm
FROM rotas_base AS r
LEFT JOIN dbo.tb_ml_processamento_km_rotas AS p WITH (NOLOCK)
    ON p.idrota = r.IdRota
LEFT JOIN pacotes_janela AS pac
    ON pac.IdRota = r.IdRota
   AND pac.DataReferencia = r.DataReferencia
LEFT JOIN acao_gps_dia AS acao
    ON acao.agp_cd_usuario = r.UsuarioDA
   AND acao.DataLocal = r.DataReferencia
LEFT JOIN regra_auditoria AS regra
    ON regra.IdRota = r.IdRota
   AND regra.IdTransportadora = r.IdTransportadora
   AND regra.DataReferencia = r.DataReferencia;

GO
