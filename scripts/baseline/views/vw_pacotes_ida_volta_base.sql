-- ============================================================
-- BASELINE: dbo.vw_pacotes_ida_volta_base
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_ida_volta_base]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_pacotes_ida_volta_base]
AS

WITH PrimeiraParada AS (
    SELECT
        v.IdRota,
        v.IdPacote,
        v.DataHora,
        v.Latitude,
        v.Longitude
    FROM dbo.vw_ml_rota_pacote_osm AS v WITH (NOLOCK)
    WHERE v.SequenciaParada = 1
),
RotaResolvida AS (
    SELECT
        p.IdRota,
        p.IdPacote,
        p.DataHora AS DataHoraPrimeiraParada,
        p.Latitude AS LatitudePrimeiraParada,
        p.Longitude AS LongitudePrimeiraParada,
        COALESCE(pac.DataReferencia, fmp.DataReferencia) AS DataReferencia,
        COALESCE(lm.IdTransportadora, fm.IdTransportadora, pac.IdTransportadora, fmp.IdTransportadora) AS IdTransportadora,
        COALESCE(lm.ServiceCenter, fm.OrigemSaida) AS ServiceCenter,
        COALESCE(lm.ServiceCenter, fm.OrigemSaida) AS BaseSigla
    FROM PrimeiraParada AS p
    LEFT JOIN dbo.tb_ml_pacotes AS pac WITH (NOLOCK)
        ON p.IdRota = pac.IdRota
       AND p.IdPacote = pac.IdPacote
       AND pac.excluido = 0
    LEFT JOIN dbo.tb_ml_fm_paradas AS fmp WITH (NOLOCK)
        ON p.IdRota = fmp.IdRota
       AND p.IdPacote = fmp.IdParada
       AND fmp.Excluido = 0
    LEFT JOIN dbo.tb_ml_rotas AS lm WITH (NOLOCK)
        ON p.IdRota = lm.IdRota
       AND lm.DataReferencia = COALESCE(pac.DataReferencia, fmp.DataReferencia)
    LEFT JOIN dbo.tb_ml_fm_rotas AS fm WITH (NOLOCK)
        ON p.IdRota = fm.IdRota
       AND fm.DataReferencia = COALESCE(pac.DataReferencia, fmp.DataReferencia)
),
BaseResolvida AS (
    SELECT
        r.IdRota,
        r.IdPacote,
        r.DataHoraPrimeiraParada,
        r.DataReferencia,
        r.IdTransportadora,
        r.ServiceCenter,
        r.BaseSigla,
        r.LatitudePrimeiraParada,
        r.LongitudePrimeiraParada,
        b.bss_cd_base,
        b.bss_dc_latitude AS BaseLatitude,
        b.bss_dc_longitude AS BaseLongitude
    FROM RotaResolvida AS r
    LEFT JOIN dbo.tb_bases AS b WITH (NOLOCK)
        ON r.IdTransportadora = b.bss_cd_idtransportadora
       AND r.BaseSigla = b.bss_ds_sigla
)
SELECT
    b.IdRota,
    b.IdPacote,
    b.DataHoraPrimeiraParada,
    b.DataReferencia,
    b.IdTransportadora,
    b.ServiceCenter,
    b.BaseSigla,
    b.LatitudePrimeiraParada,
    b.LongitudePrimeiraParada,
    b.BaseLatitude,
    b.BaseLongitude,
    CASE
        WHEN b.BaseLatitude IS NOT NULL
         AND b.BaseLongitude IS NOT NULL
         AND b.LatitudePrimeiraParada IS NOT NULL
         AND b.LongitudePrimeiraParada IS NOT NULL
         AND CAST(b.BaseLongitude AS DECIMAL(14, 10)) BETWEEN -90 AND 90
         AND CAST(b.LatitudePrimeiraParada AS DECIMAL(14, 10)) BETWEEN -90 AND 90
        THEN geography::Point(b.LatitudePrimeiraParada, b.LongitudePrimeiraParada, 4326)
             .STDistance(geography::Point(b.BaseLatitude, b.BaseLongitude, 4326)) / 1000.0
        ELSE NULL
    END AS DistanciaBasePrimeiraParadaKm,
    CASE
        WHEN b.BaseLatitude IS NOT NULL
         AND b.BaseLongitude IS NOT NULL
         AND b.LatitudePrimeiraParada IS NOT NULL
         AND b.LongitudePrimeiraParada IS NOT NULL
         AND CAST(b.BaseLongitude AS DECIMAL(14, 10)) BETWEEN -90 AND 90
         AND CAST(b.LatitudePrimeiraParada AS DECIMAL(14, 10)) BETWEEN -90 AND 90
        THEN geography::Point(b.LatitudePrimeiraParada, b.LongitudePrimeiraParada, 4326)
             .STDistance(geography::Point(b.BaseLatitude, b.BaseLongitude, 4326)) / 1000.0
        ELSE NULL
    END AS DistanciaPrimeiraParadaBaseKm,
    CASE
        WHEN b.BaseLatitude IS NOT NULL
         AND b.BaseLongitude IS NOT NULL
         AND b.LatitudePrimeiraParada IS NOT NULL
         AND b.LongitudePrimeiraParada IS NOT NULL
         AND CAST(b.BaseLongitude AS DECIMAL(14, 10)) BETWEEN -90 AND 90
         AND CAST(b.LatitudePrimeiraParada AS DECIMAL(14, 10)) BETWEEN -90 AND 90
        THEN geography::Point(b.LatitudePrimeiraParada, b.LongitudePrimeiraParada, 4326)
             .STDistance(geography::Point(b.BaseLatitude, b.BaseLongitude, 4326)) / 1000.0 * 2.0
        ELSE NULL
    END AS DistanciaIdaVoltaBaseKm,
    CASE WHEN b.bss_cd_base IS NULL THEN 1 ELSE 0 END AS FlagSemBase,
    CASE
        WHEN b.LatitudePrimeiraParada IS NULL
          OR b.LongitudePrimeiraParada IS NULL
          OR b.BaseLatitude IS NULL
          OR b.BaseLongitude IS NULL
        THEN 1
        ELSE 0
    END AS FlagSemCoordenada
FROM BaseResolvida AS b;
GO
