-- ============================================================
-- BASELINE: dbo.UspSPEGetLoadRotasLH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetLoadRotasLH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPEGetLoadRotasLH] as 

DROP TABLE IF EXISTS #aux;

SELECT *
INTO #aux
FROM db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
WHERE CAST(createdAt AS DATE) = CAST(GETDATE() AS date)
  AND TipoJson = 'LH'
  AND idtransportadora IS NOT NULL
  and processingStatus  = 0


DROP TABLE IF EXISTS #rotas;

;WITH TripInfo AS (
    SELECT
        JSON_VALUE(aux.jsondata, '$.data.agency_id') AS IdTransportadora,
        JSON_VALUE(aux.jsondata, '$.data.body.content_data.driver_id') AS IdMotorista,
        JSON_VALUE(aux.jsondata, '$.data.body.content_data.driver_name') AS Motorista,
        DATEADD(SECOND, CAST(JSON_VALUE(aux.jsondata, '$.data.body.content_data.trip_date') AS BIGINT) - 10800, '1970-01-01') AS DataHoraColeta,
        DATEADD(SECOND, CAST(JSON_VALUE(aux.jsondata, '$.timestamp') AS BIGINT) - 10800, '1970-01-01') AS DataReferencia,
        JSON_VALUE(aux.jsondata, '$.data.body.content_data.trip_number') AS CodigoRota,
        JSON_VALUE(aux.jsondata, '$.data.body.content_data.vehicle_plate') AS Placa,
        JSON_VALUE(aux.jsondata, '$.data.body.content_data.vehicle_type') AS TipoVeiculo,
        JSON_VALUE(aux.jsondata, '$.data.body.content_data.trip_distance') AS DistanciaTotal,

        trip.station_id,
        trip.dataunload,
        trip.dataunseal,
        station.station_name AS NomeHub,

        origem.station_name  AS Station_Origem,
        destino.station_name AS Station_Destino,

        aux.agency AgencyId

    FROM #aux AS aux

    OUTER APPLY OPENJSON(aux.jsondata, '$.data.body.content_data.trip_info')
    WITH (
        station_id INT '$.station_id',
        dataunload DATETIME2 '$.dataunload',
        dataunseal DATETIME2 '$.dataunseal'
    ) AS trip

    OUTER APPLY OPENJSON(aux.jsondata, '$.data.body.content_data.trip_path')
    WITH (
        station_name NVARCHAR(255) '$.station_name'
    ) AS station

    /* Origem = primeiro elemento trip_path[0] */
    OUTER APPLY (
        SELECT
            JSON_VALUE(aux.jsondata, '$.data.body.content_data.trip_path[0].station_name') AS station_name
    ) AS origem

    /* Destino = segundo elemento trip_path[1] */
    OUTER APPLY (
        SELECT
            JSON_VALUE(aux.jsondata, '$.data.body.content_data.trip_path[1].station_name') AS station_name
    ) AS destino
)

, Ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY CodigoRota
               ORDER BY 
                   ISNULL(dataunload, dataunseal) DESC,
                   station_id DESC
           ) AS rn
    FROM TripInfo
)

SELECT
    IdTransportadora,
    IdMotorista,
    Motorista,
    DataHoraColeta,
    DataReferencia,
    CodigoRota,
    Placa,
    TipoVeiculo,
    DistanciaTotal,
    station_id AS IdStation,
    NomeHub,
    Station_Origem,
    Station_Destino,
    DataReferencia AS DataHoraInicio,
    0 AS Excluido,
    AgencyId
INTO #rotas
FROM Ranked
WHERE rn = 1;



MERGE INTO tb_spe_rotas_v5 AS target
USING #rotas AS source
ON target.CodigoRota = source.CodigoRota
AND target.IdTransportadora = source.IdTransportadora
WHEN MATCHED THEN
    UPDATE SET
        target.IdMotorista     = source.IdMotorista,
        target.Motorista      = source.Motorista,
        target.DataHoraColeta = source.DataHoraColeta,
        target.DataReferencia = source.DataReferencia,
        target.IdStation      = source.IdStation,
        target.NomeHub        = source.NomeHub,
        target.CodigoRota     = source.CodigoRota,
        target.Placa          = source.Placa,
        target.TipoVeiculo    = source.TipoVeiculo,
        target.DataHoraInicio = source.DataHoraInicio,
        target.DistanciaTotal = source.DistanciaTotal,
        target.Excluido       = 0  -- Reativa rota, se existia
    ,target.StationOrigem = source.Station_Origem
    ,target.StationDestino = source.Station_Destino
       ,target.AgencyId = source.AgencyId
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        IdTransportadora,
        IdMotorista,
        Motorista,
        DataHoraColeta,
        DataReferencia,
        IdStation,
        NomeHub,
        CodigoRota,
        Placa,
        TipoVeiculo,
        Excluido,
        DataHoraInicio,
        DistanciaTotal,
        TipoOperacao,
    StationOrigem,
    StationDestino,
        AgencyId
    )
    VALUES (
        source.IdTransportadora,
        source.IdMotorista,
        source.Motorista,
        source.DataHoraColeta,
        source.DataReferencia,
        source.IdStation,
        source.NomeHub,
        source.CodigoRota,
        source.Placa,
        source.TipoVeiculo,
        0,
        source.DataHoraInicio,
        source.DistanciaTotal,
        'LH',
    source.Station_Origem,
    source.Station_Destino,
       source.AgencyId
    );




  ;WITH CTE_Duplicadas AS (
    SELECT 
        Id,
        CodigoRota,
        DataHoraInicio,
        ROW_NUMBER() OVER (PARTITION BY CodigoRota ORDER BY DataHoraInicio DESC) AS Ordem
    FROM tb_spe_rotas_v5
    WHERE Excluido = 0
      AND TipoOperacao = 'LH'
)
UPDATE r
SET r.Excluido = 1
FROM tb_spe_rotas_v5 r
INNER JOIN CTE_Duplicadas d ON r.Id = d.Id
WHERE d.Ordem > 1;









  update rotas
  set IdTransportadora = clientes.cli_id_shopee
  from tb_Spe_Rotas_v5 as rotas
    join tb_clientes as clientes on rotas.IdTransportadora = clientes.cli_agency_shpee or rotas.IdTransportadora = clientes.cli_agency_shopee_2  
     or rotas.IdTransportadora = clientes.cli_agency_shopee_3
      or rotas.IdTransportadora = clientes.cli_agency_shopee_4
GO
