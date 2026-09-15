-- ============================================================
-- BASELINE: dbo.vw_ml_rota_pacote_osm
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_rota_pacote_osm]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[vw_ml_rota_pacote_osm] as
SELECT
    IdRota,
    DataHora,
    Latitude,
    Longitude,
    ROW_NUMBER() OVER (PARTITION BY IdRota ORDER BY DataHora) AS SequenciaParada,
    IdPacote
FROM (
    SELECT
        a.IdRota,
        a.IdPacote,
        a.DataHora,
        a.Latitude,
        a.Longitude,
        CASE
            WHEN a.LatAnterior IS NULL THEN 0.0
            ELSE geography::Point(a.Latitude, a.Longitude, 4326)
                 .STDistance(geography::Point(a.LatAnterior, a.LonAnterior, 4326)) / 1000.0
        END AS distancia
    FROM (
        SELECT
            a.IdRota,
            a.IdPacote,
            a.DataHoraEntrega AS DataHora,
            a.LatitudeEnderecoParada  AS Latitude,
            a.LongitudeEnderecoParada AS Longitude,
            LAG(a.LatitudeEnderecoParada)  OVER (PARTITION BY a.IdRota ORDER BY a.DataHoraEntrega) AS LatAnterior,
            LAG(a.LongitudeEnderecoParada) OVER (PARTITION BY a.IdRota ORDER BY a.DataHoraEntrega) AS LonAnterior
        FROM dbo.tb_ml_pacotes AS a WITH (NOLOCK)
        INNER JOIN dbo.tb_ml_rotas AS b WITH (NOLOCK)
            ON  a.IdRota = b.IdRota
        INNER JOIN dbo.tb_clientes AS cli WITH (NOLOCK)
            ON  b.IdTransportadora = cli.cli_id_logistics
            AND cli.cli_cd_codigo_cliente <> 7
        LEFT JOIN dbo.tb_parametros AS prm WITH (NOLOCK)
            ON  cli.cli_cd_codigo_cliente = prm.prm_cod_cliente
            AND prm.prm_nm_parametro = 'Service Center Padrão'
        LEFT JOIN dbo.tb_bases AS c WITH (NOLOCK)
            ON  b.IdTransportadora = c.bss_cd_idtransportadora
            AND c.bss_ds_sigla = CASE
                    WHEN (b.ServiceCenter <> b.OrigemSaida
                          AND LEFT(b.OrigemSaida, 1) IN ('E', 'M')
                          AND ISNULL(prm.prm_ds_valor, 0) <> 1)
                         OR ISNULL(c.bss_espelho_xpt, 0) = 1
                    THEN b.OrigemSaida
                    ELSE b.ServiceCenter
                END
        WHERE a.DataReferencia >= CAST(GETDATE() - 90 AS date)
          AND a.Excluido = 0
          AND a.StatusEntrega = 'delivered'
          AND CAST(c.bss_dc_longitude AS decimal(14, 10)) BETWEEN -90 AND 90
          AND CAST(a.LatitudeEnderecoParada AS decimal(14, 10)) BETWEEN -90 AND 90
          --AND a.LatitudeEnderecoParada  LIKE '-%'
          --AND a.LongitudeEnderecoParada LIKE '-%'
    ) AS a
) AS final
WHERE final.distancia < 15;
GO
