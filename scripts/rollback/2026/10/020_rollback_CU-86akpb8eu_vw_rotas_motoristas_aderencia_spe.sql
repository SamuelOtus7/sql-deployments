/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpb8eu
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Restaura dbo.vw_rotas_motoristas_aderencia para a versao
                 anterior (somente Meli — tb_ml_rotas), removendo o branch
                 SPE adicionado pelo forward 020.
  Forward ref  : scripts/forward/2026/10/020_forward_CU-86akpb8eu_vw_rotas_motoristas_aderencia_spe.sql
  Objetos      : dbo.vw_rotas_motoristas_aderencia (CREATE OR ALTER — versao anterior)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_rotas_motoristas_aderencia'))
        THROW 50010, 'View dbo.vw_rotas_motoristas_aderencia nao encontrada.', 1;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

CREATE OR ALTER VIEW [dbo].[vw_rotas_motoristas_aderencia]
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

BEGIN TRY
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.vw_rotas_motoristas_aderencia')) LIKE '%tb_spe_rotas_v5%'
        THROW 50011, 'View ainda contem branch SPE apos rollback.', 1;

    PRINT 'SUCESSO: Rollback de dbo.vw_rotas_motoristas_aderencia executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
