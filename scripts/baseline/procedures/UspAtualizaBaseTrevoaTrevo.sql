-- ============================================================
-- BASELINE: dbo.UspAtualizaBaseTrevoaTrevo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaBaseTrevoaTrevo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspAtualizaBaseTrevoaTrevo]
AS
BEGIN

-- Identifica pacotes fora do raio de cobertura (mesma regra de UspGeraColetaCidadesDistanteDia)
DROP TABLE IF EXISTS #pacotes_cobertura;

SELECT
    a.IdRota,
    a.IdPacote,
    CASE
        WHEN LAG(a.LatitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.SequenciaParada) IS NOT NULL
         AND LAG(a.LongitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.SequenciaParada) IS NOT NULL
        THEN geography::Point(a.LatitudeEnderecoParada, a.LongitudeEnderecoParada, 4326)
             .STDistance(geography::Point(
                  LAG(a.LatitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.SequenciaParada),
                  LAG(a.LongitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.SequenciaParada),
                  4326))
        ELSE NULL
    END AS DistanciaDaAnterior,
    CASE
        WHEN LEAD(a.LatitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.SequenciaParada) IS NOT NULL
         AND LEAD(a.LongitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.SequenciaParada) IS NOT NULL
        THEN geography::Point(a.LatitudeEnderecoParada, a.LongitudeEnderecoParada, 4326)
             .STDistance(geography::Point(
                  LEAD(a.LatitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.SequenciaParada),
                  LEAD(a.LongitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.SequenciaParada),
                  4326))
        ELSE NULL
    END AS DistanciaDaPosterior
INTO #pacotes_cobertura
FROM tb_ml_pacotes AS a WITH (NOLOCK)
JOIN tb_ml_rotas AS c WITH (NOLOCK)
    ON a.IdRota = c.IdRota
   AND a.DataReferencia = c.DataReferencia
JOIN tb_clientes AS d WITH (NOLOCK)
    ON a.IdTransportadora = d.cli_id_logistics
WHERE a.IdTransportadora IN (1731064496,  1024706007)
  AND a.datareferencia >= dateadd(day,-1,cast(getdate() as date))
  AND a.StatusEntrega = 'delivered'
  AND d.cli_in_ativo = 1
  AND d.cli_cd_codigo_cliente <> 7
  AND a.excluido = 0
  AND c.excluido = 0;

DROP TABLE IF EXISTS #pacotes_fora_cobertura;

SELECT
    IdRota,
    IdPacote
INTO #pacotes_fora_cobertura
FROM #pacotes_cobertura
WHERE (DistanciaDaAnterior > 999 OR DistanciaDaAnterior IS NULL)
  AND (DistanciaDaPosterior > 999 OR DistanciaDaPosterior IS NULL)
  AND (DistanciaDaAnterior > 999 OR DistanciaDaPosterior > 999);

-- Processa lista de cidades por transportadora e service center
DROP TABLE IF EXISTS #rotas;

SELECT
    IdTransportadora,
    IdRota,
    ServiceCenter,
    TipoRota,
    STRING_AGG(CidadeEstado, ', ') WITHIN GROUP (ORDER BY CidadeEstado ASC) AS CidadesEstados,
    COUNT(*) AS QtdeCidades
INTO #rotas
FROM (
    SELECT
        a.IdTransportadora,
        a.IdRota,
        CASE WHEN c.ServiceCenter <> c.OrigemSaida THEN c.OrigemSaida ELSE c.ServiceCenter END AS ServiceCenter,
        b.dcg_ds_cidade + ' - ' + b.dcg_ds_estado + ' - Brasil' AS CidadeEstado,
        c.TipoRota,
        ROW_NUMBER() OVER (
            PARTITION BY
                a.IdTransportadora,
                CASE WHEN c.ServiceCenter <> c.OrigemSaida THEN c.OrigemSaida ELSE c.ServiceCenter END,
                b.dcg_ds_estado,
                a.IdRota
            ORDER BY b.dcg_ds_cidade
        ) AS Ordem
    FROM tb_ml_pacotes AS a WITH (NOLOCK)
    JOIN tb_dra_cidades_geo AS b WITH (NOLOCK)
        ON a.LatitudeEnderecoParada = b.dcg_nr_latitude
       AND a.LongitudeEnderecoParada = b.dcg_nr_longitude
    JOIN tb_ml_rotas AS c WITH (NOLOCK)
        ON a.IdRota = c.IdRota
       AND a.DataReferencia = c.DataReferencia
    JOIN tb_clientes AS d WITH (NOLOCK)
        ON a.IdTransportadora = d.cli_id_logistics
    WHERE 1 = 1
      AND a.IdTransportadora IN (1731064496, 1024706007)
      --AND a.datareferencia BETWEEN '2026-07-01' AND '2026-08-02'
      AND a.StatusEntrega = 'delivered'
      AND d.cli_in_ativo = 1
      AND d.cli_cd_codigo_cliente <> 7
      AND b.dcg_ds_cidade <> 'NOT_FOUND'
      AND b.dcg_ds_estado <> 'NOT_FOUND'
      AND a.excluido = 0
      AND c.excluido = 0
      AND NOT EXISTS (
          SELECT 1
          FROM #pacotes_fora_cobertura AS fc
          WHERE fc.IdRota = a.IdRota
            AND fc.IdPacote = a.IdPacote
      )
    GROUP BY
        a.IdTransportadora,
        CASE WHEN c.ServiceCenter <> c.OrigemSaida THEN c.OrigemSaida ELSE c.ServiceCenter END,
        b.dcg_ds_cidade,
        b.dcg_ds_estado,
        c.TipoRota,
        a.IdRota
) AS base
WHERE Ordem <= 4
GROUP BY
    IdTransportadora,
    IdRota,
    TipoRota,
    ServiceCenter;

DROP TABLE IF EXISTS #aux;

SELECT DISTINCT
    base.IdTransportadora,
    ServiceCenter,
    CASE
        WHEN TipoRota LIKE '%GUA%' OR TipoRota LIKE '%GNH%' OR TipoRota LIKE '%XGUA%' OR TipoRota LIKE '%GN%'
         AND ServiceCenter = 'smg8' AND svc.bss_in_base_intermediaria = 1
        THEN svc.bss_ds_latitude_intermediario
        ELSE svc.bss_dc_latitude
    END AS bss_dc_latitude,
    CASE
        WHEN TipoRota LIKE '%GUA%' OR TipoRota LIKE '%GNH%' OR TipoRota LIKE '%XGUA%' OR TipoRota LIKE '%GN%'
         AND ServiceCenter = 'smg8' AND ServiceCenter = 'smg8' AND svc.bss_in_base_intermediaria = 1
        THEN svc.bss_ds_longitude_intermediario
        ELSE svc.bss_dc_longitude
    END AS bss_dc_longitude,
    base.CidadesEstados,
    NULL AS OrdemIdeal,
    0 AS KmIdeal,
    NULL AS LinkGoogleMaps,
    NULL AS DataProcessamento,
    0 AS Processado,
    QtdeCidades AS QtdeCidades,
    NULL AS CidadeBase
INTO #aux
FROM #rotas AS base
INNER JOIN tb_bases AS svc
    ON base.ServiceCenter = svc.bss_ds_sigla
   AND base.IdTransportadora = svc.bss_cd_idtransportadora
WHERE ABS(svc.bss_dc_latitude) > 0
  AND ABS(svc.bss_dc_longitude) > 0;

INSERT INTO tb_fin_base_km_trevo
SELECT DISTINCT a.*
FROM #aux AS a
LEFT JOIN tb_fin_base_km_trevo AS b
    ON a.IdTransportadora = b.bkt_cd_transportadora
   AND a.ServiceCenter = b.bkt_cd_service_center
   AND a.CidadesEstados = b.bkt_nm_cidades
WHERE b.bkt_cd_transportadora IS NULL;

UPDATE base
SET IdTrevo = trevo.bkt_cd_base_km_trevo
FROM tb_ml_rotas AS base
JOIN #rotas AS rotas ON base.IdRota = rotas.IdRota
JOIN tb_fin_base_km_trevo AS trevo
    ON rotas.CidadesEstados = trevo.bkt_nm_cidades
   AND rotas.IdTransportadora = trevo.bkt_cd_transportadora;

END
GO
