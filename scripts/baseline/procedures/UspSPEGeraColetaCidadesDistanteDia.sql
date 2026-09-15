-- ============================================================
-- BASELINE: dbo.UspSPEGeraColetaCidadesDistanteDia
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGeraColetaCidadesDistanteDia]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPEGeraColetaCidadesDistanteDia]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @datainicio DATE = CAST(GETDATE() - 3 AS DATE);
    DECLARE @datafim DATE = CAST(GETDATE() AS DATE);

    DROP TABLE IF EXISTS #base1;
    SELECT 
        a.CodigoRota,
        a.CodigoPacote,
        a.Latitude AS Latitude,
        a.Longitude AS Longitude,

        geography::Point(a.Latitude, a.Longitude, 4326)
            .STDistance(geography::Point(c.latitude, c.longitude, 4326)) AS distancia,

        CASE 
            WHEN LAG(a.Latitude) OVER (PARTITION BY a.CodigoRota ORDER BY a.CodigoPacote) IS NOT NULL
                 AND LAG(a.Longitude) OVER (PARTITION BY a.CodigoRota ORDER BY a.CodigoPacote) IS NOT NULL
            THEN geography::Point(a.Latitude, a.Longitude, 4326)
                .STDistance(geography::Point(
                    LAG(a.Latitude) OVER (PARTITION BY a.CodigoRota ORDER BY a.CodigoPacote),
                    LAG(a.Longitude) OVER (PARTITION BY a.CodigoRota ORDER BY a.CodigoPacote),
                    4326))
            ELSE NULL
        END AS DistanciaDaAnterior,

        CASE 
            WHEN LEAD(a.Latitude) OVER (PARTITION BY a.CodigoRota ORDER BY a.CodigoPacote) IS NOT NULL
                 AND LEAD(a.Longitude) OVER (PARTITION BY a.CodigoRota ORDER BY a.CodigoPacote) IS NOT NULL
            THEN geography::Point(a.Latitude, a.Longitude, 4326)
                .STDistance(geography::Point(
                    LEAD(a.Latitude) OVER (PARTITION BY a.CodigoRota ORDER BY a.CodigoPacote),
                    LEAD(a.Longitude) OVER (PARTITION BY a.CodigoRota ORDER BY a.CodigoPacote),
                    4326))
            ELSE NULL
        END AS DistanciaDaPosterior
    INTO #base1
    FROM tb_spe_pacotes_v5 AS a WITH (NOLOCK)
    INNER JOIN (
        SELECT CodigoRota, DataReferencia, IdTransportadora, NomeHub, CidadeDistante, IdStation
        FROM tb_spe_rotas_v5 WITH (NOLOCK)
        WHERE DataReferencia BETWEEN @datainicio AND @datafim
            AND Excluido = 0
            AND (CidadeDistante IS NULL or CidadeDistante in ('Sem pacote entregue','Sem base cadastrada'))
    ) AS b
        ON a.CodigoRota = b.CodigoRota
        --AND a.DataReferencia = b.DataReferencia
        and a.IdTransportadora = b.IdTransportadora
    INNER JOIN tb_spe_station AS c WITH (NOLOCK)
        ON c.IdStation = b.IdStation
    WHERE a.DataReferencia BETWEEN @datainicio AND @datafim
        AND TRY_CAST(c.Longitude AS DECIMAL(14,10)) BETWEEN -90 AND 90
        AND TRY_CAST(a.Latitude AS DECIMAL(14,10)) BETWEEN -90 AND 90
        AND a.Excluido = 0
        AND (b.CidadeDistante IS NULL or b.CidadeDistante in ('Sem pacote entregue','Sem base cadastrada'))
        AND TRY_CAST(a.Latitude AS DECIMAL(14,10)) <> 0;

    DROP TABLE IF EXISTS #base2;
    SELECT *
    INTO #base2
    FROM #base1
    WHERE (DistanciaDaAnterior > 999 OR DistanciaDaAnterior IS NULL)
      AND (DistanciaDaPosterior > 999 OR DistanciaDaPosterior IS NULL);

    DELETE
    FROM #base1
    WHERE (DistanciaDaAnterior > 999 OR DistanciaDaAnterior IS NULL)
      AND (DistanciaDaPosterior > 999 OR DistanciaDaPosterior IS NULL);

    UPDATE a
    SET a.CidadeDistante = b.ordem
    FROM tb_spe_pacotes_v5 AS a WITH (ROWLOCK, READPAST, UPDLOCK)
    INNER JOIN (
        SELECT 
            CodigoRota,
            CodigoPacote,
            Latitude,
            Longitude,
            ROW_NUMBER() OVER (PARTITION BY CodigoRota ORDER BY distancia DESC) AS ordem
        FROM #base1
    ) AS b
        ON a.CodigoRota = b.CodigoRota
        AND a.CodigoPacote = b.CodigoPacote
        AND a.Longitude = b.Longitude
        AND a.Latitude = b.Latitude
    WHERE a.Excluido = 0;

    UPDATE a
    SET a.CidadeDistante = b.ordem
    FROM tb_spe_pacotes_v5 AS a WITH (ROWLOCK, READPAST, UPDLOCK)
    INNER JOIN (
        SELECT 
            a.CodigoRota,
            a.CodigoPacote,
            a.Latitude,
            a.Longitude,
            ROW_NUMBER() OVER (PARTITION BY a.CodigoRota ORDER BY a.distancia DESC) AS ordem
        FROM #base2 AS a
        LEFT JOIN #base1 AS b
            ON a.CodigoRota = b.CodigoRota
        WHERE b.CodigoRota IS NULL
    ) AS b
        ON a.CodigoRota = b.CodigoRota
        AND a.CodigoPacote = b.CodigoPacote
        AND a.Longitude = b.Longitude
        AND a.Latitude = b.Latitude
    WHERE a.Excluido = 0;

    INSERT INTO tb_dra_cidades_geo (
        dcg_nr_latitude,
        dcg_nr_longitude,
        dcg_cidade_distante
    )
    SELECT DISTINCT 
        Latitude,
        Longitude,
        MIN(CidadeDistante) AS dcg_cidade_distante
    FROM tb_spe_pacotes_v5 AS pacotes WITH (NOLOCK)
    LEFT JOIN tb_dra_cidades_geo AS geo WITH (NOLOCK)
        ON pacotes.Latitude = geo.dcg_nr_latitude
        AND pacotes.Longitude = geo.dcg_nr_longitude
    WHERE pacotes.Latitude IS NOT NULL
        AND pacotes.Longitude IS NOT NULL
        AND geo.dcg_cd_cidade_gei IS NULL
        AND geo.dcg_nr_latitude IS NULL
        AND pacotes.DataReferencia BETWEEN @datainicio AND @datafim
        AND pacotes.CidadeDistante >= 1
    GROUP BY Latitude, Longitude;

    UPDATE a
    SET a.CidadeDistante = 'Sem base cadastrada'
    
    FROM tb_spe_rotas_v5 AS a
    LEFT JOIN tb_bases AS s
        ON a.IdTransportadora = s.bss_cd_idtransportadora
        and NomeHub = bss_ds_nome
    WHERE a.CidadeDistante IS NULL
        AND a.Excluido = 0
        and bss_cd_base  is null
        and datareferencia >= @datainicio
        ;

    UPDATE a
    SET a.CidadeDistante = 'Sem pacote entregue'
    
    FROM tb_spe_rotas_v5 AS a
    JOIN tb_bases AS s
        ON a.IdTransportadora = s.bss_cd_idtransportadora
        and NomeHub = bss_ds_nome
    WHERE a.CidadeDistante IS NULL
        AND a.Excluido = 0
        and datareferencia >= @datainicio
        and PacotesEntregues = 0
        ;


    EXEC UspSPEGeraAtualizaCidadesDistanteDiaPacote;

END
GO
