-- ============================================================
-- BASELINE: dbo.UspSPEGetLoadPacotes_FM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetLoadPacotes_FM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPEGetLoadPacotes_FM] AS
DROP TABLE IF EXISTS #aux;

SELECT  * 
INTO    #aux
FROM db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
WHERE TipoJson = 'FM-ORDER'
  AND idtransportadora IS NOT NULL
  AND UltimoRegistro = 1
  AND CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
  AND processingStatus = 0;

DROP TABLE IF EXISTS #OrdersDetalhes;

SELECT 
    DISTINCT b.id,
    b.createdAt AS DataCriacaoRegistro,
    b.TipoJson AS TipoJson,
    b.agency AS Agencia,
    b.idtransportadora AS IdTransportadora,
    b.UltimoRegistro AS UltimoRegistro,
    JSON_VALUE(b.jsonData, '$.data.trace_id') AS CodigoTrace,
    TRY_CAST(JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_number') AS BIGINT) AS CodigoRota,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.order_number') AS CodigoPacote,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.order_status') AS StatusPacote,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.pickup_point_id') AS PickupPointId,
    TRY_CAST(JSON_VALUE(b.jsonData, '$.data.body.content_data.data.timestamp') AS DATETIME) AS DataHoraEvento,
    DATEADD(SECOND, TRY_CAST(JSON_VALUE(b.jsonData, '$.timestamp') AS BIGINT), '1970-01-01') AS DataEventoUnix 

INTO #OrdersDetalhes
FROM #aux b;

MERGE dbo.tb_spe_pacotes_FM AS T 
USING #OrdersDetalhes AS S 
    ON T.IdTransportadora = S.IdTransportadora
    and T.CodigoRota = S.CodigoRota
    and T.CodigoPacote = S.CodigoPacote 


WHEN MATCHED THEN UPDATE
SET DataCriacaoRegistro = S.DataCriacaoRegistro,
    TipoJson = S.TipoJson,
    Agencia = S.Agencia,
    IdTransportadora = S.IdTransportadora,
    CodigoTrace = S.CodigoTrace,
    CodigoRota = S.CodigoRota,
    CodigoPacote = S.CodigoPacote,
    StatusPacote = S.StatusPacote,
    PickupPointId = S.PickupPointId,
    DataHoraEvento = S.DataHoraEvento,
    DataEventoUnix = S.DataEventoUnix,
    Excluido = 0,
    DataAtualizacao = GETDATE() 
    
    

WHEN NOT MATCHED BY TARGET THEN
INSERT (IdWebhook,
        DataCriacaoRegistro,
        TipoJson,
        Agencia,
        IdTransportadora,
        CodigoTrace,
        CodigoRota,
        CodigoPacote,
        StatusPacote,
        PickupPointId,
        DataHoraEvento,
        DataEventoUnix,
        Excluido,
        DataInclusao)
VALUES (S.id, 
        S.DataCriacaoRegistro, 
        S.TipoJson, S.Agencia, 
        S.IdTransportadora, 
        S.CodigoTrace, 
        S.CodigoRota, 
        S.CodigoPacote, 
        S.StatusPacote, 
        S.PickupPointId, 
        S.DataHoraEvento, 
        S.DataEventoUnix, 
        0, 
        GETDATE()
        ); 



WITH PacotesRankeados AS
  (SELECT Id,
          ROW_NUMBER() OVER (PARTITION BY CodigoPacote, CodigoRota
                             ORDER BY DataHoraEvento DESC) AS rn
   FROM dbo.tb_spe_pacotes_FM
   WHERE CAST(DataHoraEvento AS DATE) >= CAST(GETDATE()-5 AS DATE)
   )


UPDATE P
SET Excluido = CASE
                   WHEN R.rn = 1 THEN 0
                   ELSE 1
               END
FROM dbo.tb_spe_pacotes_FM P
INNER JOIN PacotesRankeados R ON P.Id = R.Id
WHERE CAST(P.DataHoraEvento AS DATE) >= CAST(GETDATE()-5 AS DATE);


UPDATE W
SET W.processingStatus = 1,
    W.processingDatetime = GETDATE()
FROM db_Irisys_Json.dbo.tb_spe_webhook W
INNER JOIN #aux A ON W.id = A.id;
GO
