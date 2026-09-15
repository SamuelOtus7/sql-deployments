-- ============================================================
-- BASELINE: dbo.UspSPELoadRotasSemTripInfo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadRotasSemTripInfo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadRotasSemTripInfo]
as


DECLARE @DataInicio DATE = getdate();
DECLARE @DataFim DATE = getdate();
DECLARE @IdTransportadora INT = NULL; -- ex: 20230027 | NULL = todas

INSERT INTO dbo.tb_spe_rotas_v5
(
    CodigoRota,
    IdTransportadora,
    DataReferencia,
    DataHoraInicio,
    DataHoraFim,
    DataHoraColeta,
    IdStation,
    IdMotorista,
    IdStatus,
    DataAtualizacao,
    Excluido,
    TotalPacotes,
    PacotesEntregues,
    PacotesNaoEntregue,
    PacotesPendentes,
    DataUltimaEntrega,
    KmColetado,
    LinkMapa,
    TipoVeiculo,
    DataHoraCarga,
    Paradas,
    CidadeReferencia,
    DistanciaTotal,
    UsuarioIrisys,
    KmApp,
    LinkMapaApp,
    QuantidadeApontamento,
    LinkAppInterno,
    Apuracao,
    UsouAPP,
    NomeHub,
    Motorista,
    Placa,
    CidadeDistante,
    KmPacotes,
    LinkMapaPacotes,
    TipoOperacao,
    StationOrigem,
    StationDestino,
    DataHoraDesignacaoRota
)
SELECT
    x.CodigoRota,
    x.IdTransportadora,
    x.DataReferencia,
    x.DataHoraInicio,
    NULL AS DataHoraFim,
    x.DataHoraColeta,
    0 AS IdStation,
    ISNULL(x.IdMotorista, 0) AS IdMotorista,
    0 AS IdStatus,
    GETDATE() AS DataAtualizacao,
    0 AS Excluido,
    CAST(x.TotalPacotes AS SMALLINT) AS TotalPacotes,
    CAST(x.PacotesEntregues AS SMALLINT) AS PacotesEntregues,
    CAST(x.PacotesNaoEntregue AS SMALLINT) AS PacotesNaoEntregue,
    CAST(x.PacotesPendentes AS SMALLINT) AS PacotesPendentes,

    x.DataUltimaEntrega,
    NULL AS KmColetado,
    NULL AS LinkMapa,
    'Aguardando informações da rota' AS TipoVeiculo,
    GETDATE() AS DataHoraCarga,
    x.Paradas,
    ISNULL(x.CidadeReferencia, 'Aguardando informações da rota') AS CidadeReferencia,
    NULL AS DistanciaTotal,
    NULL AS UsuarioIrisys,
    NULL AS KmApp,
    NULL AS LinkMapaApp,
    NULL AS QuantidadeApontamento,
    'INSERT_SEM_WEBHOOK' AS LinkAppInterno,
    'FIX_SEM_TRIPINFO' AS Apuracao,
    NULL AS UsouAPP,
    'Aguardando informações da rota' AS NomeHub,
    'Aguardando informações da rota' AS Motorista,
    'Aguardando informações da rota' AS Placa,
    ISNULL(x.CidadeDistante, 'Aguardando informações da rota') AS CidadeDistante,
    NULL AS KmPacotes,
    NULL AS LinkMapaPacotes,
    'LM' AS TipoOperacao,
    NULL AS StationOrigem,
    NULL AS StationDestino,
    NULL AS DataHoraDesignacaoRota
FROM (
    SELECT
        p.IdTransportadora,
        MIN(p.CodigoRota) AS CodigoRota,
        MAX(p.DataReferencia) AS DataReferencia,
        MIN(COALESCE(p.DataHoraColeta, p.DataHoraEntrega, CAST(p.DataReferencia AS DATETIME))) AS DataHoraInicio,
        MAX(COALESCE(p.DataHoraColeta, p.DataHoraEntrega, CAST(p.DataReferencia AS DATETIME))) AS DataHoraColeta,
        MAX(p.IdMotorista) AS IdMotorista,
        COUNT(*) AS TotalPacotes,
        SUM(CASE WHEN p.StatusEntrega = 'Delivered' THEN 1 ELSE 0 END) AS PacotesEntregues,
        SUM(CASE WHEN p.StatusEntrega IN ('On Hold','On_Hold','Cancelled','OnHold') THEN 1 ELSE 0 END) AS PacotesNaoEntregue,
        SUM(CASE
                WHEN p.StatusEntrega IN ('Delivering','Assigned','Pending') THEN 1
                WHEN p.StatusEntrega LIKE '%Return_%' THEN 1
                ELSE 0
            END) AS PacotesPendentes,
        MAX(CASE WHEN p.StatusEntrega = 'Delivered' THEN p.DataHoraEntrega END) AS DataUltimaEntrega,
        COUNT(DISTINCT ISNULL(NULLIF(p.CEP,''), p.CodigoPacote)) AS Paradas,
        MAX(CASE
                WHEN p.Cidade IS NOT NULL
                 AND p.Cidade NOT IN ('Sem pacote entregue','Sem base cadastrada')
                THEN p.Cidade
            END) AS CidadeReferencia,
        MAX(CASE
                WHEN p.Cidade IS NOT NULL
                 AND p.Cidade NOT IN ('Sem pacote entregue','Sem base cadastrada')
                THEN p.Cidade
            END) AS CidadeDistante,
        UPPER(LTRIM(RTRIM(p.CodigoRota))) AS CodigoRotaNorm
    FROM dbo.tb_spe_pacotes_v5 p WITH (NOLOCK)
    WHERE p.DataReferencia BETWEEN @DataInicio AND @DataFim
      AND p.Excluido = 0
      AND ISNULL(LTRIM(RTRIM(p.CodigoRota)), '') <> ''
      AND ISNULL(p.SubStatus, '') <> 'transferred'
      AND (@IdTransportadora IS NULL OR p.IdTransportadora = @IdTransportadora)
    GROUP BY
        p.IdTransportadora,
        UPPER(LTRIM(RTRIM(p.CodigoRota)))
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.tb_spe_rotas_v5 r WITH (NOLOCK)
    WHERE r.IdTransportadora = x.IdTransportadora
      AND UPPER(LTRIM(RTRIM(r.CodigoRota))) = x.CodigoRotaNorm
);

------------------------


/* Desduplica: exclui rota artificial quando já existe rota oficial (trip_info) */
UPDATE r_art
SET
    r_art.Excluido        = 1,
    r_art.DataAtualizacao = GETDATE()
FROM dbo.tb_spe_rotas_v5 r_art
WHERE r_art.Excluido = 0
  AND r_art.IdStation = 0
  AND r_art.IdMotorista = 0
  AND (
        r_art.LinkAppInterno = N'INSERT_SEM_WEBHOOK'
     OR r_art.Apuracao       = N'FIX_SEM_TRIPINFO'
     OR r_art.TipoVeiculo    = N'Aguardando informações da rota'
     OR r_art.Motorista      = N'Aguardando informações da rota'
     OR r_art.NomeHub        = N'Aguardando informações da rota'
     OR r_art.Placa          = N'Aguardando informações da rota'
  )
  AND EXISTS (
        SELECT 1
        FROM dbo.tb_spe_rotas_v5 r_of WITH (NOLOCK)
        WHERE r_of.CodigoRota       = r_art.CodigoRota
          AND r_of.IdTransportadora = r_art.IdTransportadora
          AND r_of.Excluido         = 0
          AND r_of.Id              <> r_art.Id
          AND r_of.IdStation       <> 0
          AND r_of.IdMotorista     <> 0
  );
GO
