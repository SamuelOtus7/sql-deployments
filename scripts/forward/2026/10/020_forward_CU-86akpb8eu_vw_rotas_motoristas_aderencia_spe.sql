/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpb8eu
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Inclui rotas Shopee (SPE) em dbo.vw_rotas_motoristas_aderencia
                 via UNION ALL, mantendo o branch Meli intacto. O relatorio
                 externo de PBI ja resolve o tenant por cli_id_shopee.

                 Mapeamentos SPE (tb_spe_rotas_v5):
                 - CodigoRota        -> IdRota
                 - IdTransportadora  -> IdTransportadora (cli_id_shopee;
                                        INNER JOIN tb_clientes elimina rotas
                                        orfas sem tenant SPE)
                 - NomeHub           -> Base
                 - StationOrigem     -> ServiceCenter (fallback NomeHub)
                 - Motorista/TipoVeiculo/QuantidadeApontamento -> direto
                 - tb_spe_status     -> StatusRota
                 - tb_spe_processamento_km_rotas -> KmApp / pontosRotasPacotesKm
                 - vw_pbi_auditoria_km_rotas_spe -> FlagUsoDevidoFin
                                        (FaixaPrimeiroUltimoPacote)
                 - Sem equivalente: Apuracao, LinkAppInterno, LinkApp,
                   UsuarioDA (PossuiUsuario='Nao'), IdTrevo, UltimaRota -> NULL

                 Filtros SPE: Excluido = 0, janela igual ao Meli (-3 meses ate
                 ontem), status pre-execucao excluidos ('Created','Pending',
                 'Pending To Creation' — equivalente ao 'planned' do Meli);
                 rotas sem status (IdStatus NULL) sao mantidas.
  Rollback     : scripts/rollback/2026/10/020_rollback_CU-86akpb8eu_vw_rotas_motoristas_aderencia_spe.sql
  Objetos      : dbo.vw_rotas_motoristas_aderencia (CREATE OR ALTER)
  Dependências : dbo.tb_spe_rotas_v5, dbo.tb_spe_status, dbo.tb_clientes,
                 dbo.tb_spe_processamento_km_rotas,
                 dbo.vw_pbi_auditoria_km_rotas_spe (criada no script 019),
                 dbo.tb_ml_rotas, dbo.tb_ml_processamento_km_rotas,
                 dbo.vw_pbi_auditoria_km_rotas
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_rotas_motoristas_aderencia'))
        THROW 50001, 'View dbo.vw_rotas_motoristas_aderencia nao encontrada (rollback/restauracao necessario antes).', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_spe_rotas_v5'))
        THROW 50002, 'Tabela dbo.tb_spe_rotas_v5 nao encontrada.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_pbi_auditoria_km_rotas_spe'))
        THROW 50003, 'View dbo.vw_pbi_auditoria_km_rotas_spe nao encontrada. Execute o forward 019 primeiro.', 1;
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
),
rotas_base_spe AS (
    SELECT
        s.IdTransportadora,
        s.CodigoRota AS IdRota,
        s.DataReferencia,
        s.NomeHub AS OrigemSaida,
        CASE
            WHEN NULLIF(LTRIM(RTRIM(s.StationOrigem)), '') IS NOT NULL
             AND s.NomeHub <> s.StationOrigem
            THEN s.StationOrigem
            ELSE s.NomeHub
        END AS ServiceCenter,
        s.Motorista AS NomeMotorista,
        s.TipoVeiculo,
        s.UsouAPP AS UsouApp,
        s.QuantidadeApontamento,
        st.Status AS StatusRota
    FROM dbo.tb_spe_rotas_v5 AS s WITH (NOLOCK)
    INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)
        ON s.IdTransportadora = c.cli_id_shopee
       AND c.cli_id_shopee <> 0
       AND c.cli_cd_codigo_cliente <> 7
    LEFT JOIN dbo.tb_spe_status AS st WITH (NOLOCK)
        ON s.IdStatus = st.IdStatus
    WHERE s.Excluido = 0
      AND s.DataReferencia >= DATEADD(MONTH, -3, CAST(GETDATE() AS date))
      AND s.DataReferencia <= CAST(GETDATE() - 1 AS date)
      AND (st.Status IS NULL OR st.Status NOT IN ('Created', 'Pending', 'Pending To Creation'))
),
regra_auditoria_spe AS (
    SELECT
        rk.IdRota,
        rk.IdTransportadora,
        rk.DataReferencia,
        MAX(rk.FlagUsoDevidoFin) AS FlagUsoDevidoFin
    FROM dbo.vw_pbi_auditoria_km_rotas_spe AS rk WITH (NOLOCK)
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
   AND regra.DataReferencia = r.DataReferencia

UNION ALL

SELECT
    CAST(r.IdTransportadora AS varchar(50)) AS IdTransportadora,
    CASE WHEN regra.FlagUsoDevidoFin = 1 THEN 'Sim' ELSE 'Não' END AS FaixaPrimeiroUltimoPacote,
    r.OrigemSaida AS Base,
    r.ServiceCenter,
    CAST(r.IdRota AS varchar(50)) AS Idrota,
    r.DataReferencia AS Data,
    r.NomeMotorista AS Motorista,
    r.TipoVeiculo,
    CAST(NULL AS varchar(100)) AS Apuracao,
    p.pontosAppRotasTotalKm AS KmApp,
    CAST(NULL AS varchar(255)) AS LinkAppInterno,
    CAST(NULL AS varchar(255)) AS LinkApp,
    ISNULL(r.QuantidadeApontamento, 0) AS QuantidadeApontamento,
    CASE WHEN ISNULL(p.pontosAppRotasTotalKm, 0) > 0 THEN 'Sim' ELSE 'Não' END AS ColetouGps,
    case when p.pontosAppRotasTotalKm > 0 then 'Sim' else r.UsouApp end as UsouApp,
    CAST(NULL AS varchar(255)) AS UsuarioDA,
    r.StatusRota,
    CAST(NULL AS varchar(50)) AS IdTrevo,
    'Não' AS PossuiUsuario,
    CAST(NULL AS varchar(50)) AS UltimaRota,
    p.pontosRotasPacotesKm
FROM rotas_base_spe AS r
LEFT JOIN dbo.tb_spe_processamento_km_rotas AS p WITH (NOLOCK)
    ON p.idRota = r.IdRota
LEFT JOIN regra_auditoria_spe AS regra
    ON regra.IdRota = r.IdRota
   AND regra.IdTransportadora = r.IdTransportadora
   AND regra.DataReferencia = r.DataReferencia;
GO

BEGIN TRY
    --==========================================================================
    -- 2. POST-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_rotas_motoristas_aderencia'))
        THROW 50004, 'View dbo.vw_rotas_motoristas_aderencia nao encontrada apos CREATE OR ALTER.', 1;

    IF OBJECT_DEFINITION(OBJECT_ID('dbo.vw_rotas_motoristas_aderencia')) NOT LIKE '%tb_spe_rotas_v5%'
        THROW 50005, 'View alterada nao contem o branch SPE (tb_spe_rotas_v5).', 1;

    PRINT 'SUCESSO: View dbo.vw_rotas_motoristas_aderencia atualizada com branch SPE.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
