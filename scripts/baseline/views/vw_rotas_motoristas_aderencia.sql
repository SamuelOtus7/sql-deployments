-- ============================================================
-- BASELINE: dbo.vw_rotas_motoristas_aderencia
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_motoristas_aderencia]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
    Projeto: Aderencia rotas motoristas (Power BI)
    Objeto:  dbo.vw_rotas_motoristas_aderencia
    Ordem:   01
    Alteracao: substitui OUTER APPLY correlacionado por LEFT JOIN agregado
               em vw_pbi_auditoria_km_rotas (Opção B - performance)
    Pre-validacao: scripts/vw-rotas-motoristas-aderencia/00_validacao.sql
    Rollback: scripts/vw-rotas-motoristas-aderencia/99_rollback.sql
*/

--SET NOCOUNT ON;
--GO

--select * from [vw_rotas_motoristas_aderencia] where idrota  = 406051920

CREATE   VIEW [dbo].[vw_rotas_motoristas_aderencia]
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
      AND a.DataReferencia >= DATEADD(MONTH, -3, CAST(GETDATE() AS date))
      AND a.DataReferencia <= CAST(GETDATE() - 1 AS date)
      --AND a.IdTransportadora IN (1024706007)
),
regra_auditoria AS (
    SELECT
        rk.IdRota,
        rk.IdTransportadora,
        rk.DataReferencia,
        MAX(rk.FlagUsoDevidoFin) AS FlagUsoDevidoFin
    FROM dbo.vw_pbi_auditoria_km_rotas AS rk WITH (NOLOCK)
    WHERE  rk.DataReferencia >= DATEADD(MONTH, -2, CAST(GETDATE() AS date))
      AND rk.DataReferencia <= CAST(GETDATE() - 1 AS date)
    GROUP BY
        rk.IdRota,
        rk.IdTransportadora,
        rk.DataReferencia
)
SELECT
    CAST(r.IdTransportadora AS varchar(50)) AS IdTransportadora,
    CASE WHEN regra.FlagUsoDevidoFin = 1 THEN 'Sim' ELSE 'Não' END AS FaixaPrimeiroUltimoPacote,
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
    case when p.pontosAppRotasTotalKm > 0 then 'Sim' else r.UsouApp end as UsouApp,
    r.UsuarioDA,
    r.StatusRota,
    r.IdTrevo,
    CASE WHEN r.UsuarioDA IS NOT NULL THEN 'Sim' ELSE 'Não' END AS PossuiUsuario,
    CAST(NULL AS varchar(50)) AS UltimaRota,
    p.pontosRotasPacotesKm
FROM rotas_base AS r
LEFT JOIN dbo.tb_ml_processamento_km_rotas AS p WITH (NOLOCK)
    ON p.idrota = r.IdRota
LEFT JOIN regra_auditoria AS regra
    ON regra.IdRota = r.IdRota
   AND regra.IdTransportadora = r.IdTransportadora
   AND regra.DataReferencia = r.DataReferencia;

GO
