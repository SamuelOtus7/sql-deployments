-- ============================================================
-- BASELINE: dbo.UspGetLoadPacotesV5
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetLoadPacotesV5]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspGetLoadPacotesV5]
AS
BEGIN

DROP TABLE IF EXISTS #aux;

SELECT  *
INTO #aux
FROM db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
WHERE CAST(createdAt AS DATE)=  CAST(GETDATE() AS DATE)
  AND TipoJson = 'order_update'
  and idtransportadora is not null
  AND (
        ( processingStatus = 0)
        OR EXISTS (
            SELECT 1
            FROM OPENJSON(db_Irisys_Json.dbo.tb_spe_webhook.jsondata, '$.data.body.content_data.data[0]')
            WITH (
                order_status NVARCHAR(50) '$.order_status'
            ) AS j
            WHERE j.order_status = 'Delivered'
        )
    );

	drop table if exists  #pacote_atualizado
	select  DISTINCT
		idtransportadora as idtransportadora,
		delivery_latitude as latitude,
		delivery_longitude as longitude,
		case when onhold_reason = '' then null else onhold_reason end as SubStatus,
		order_number as CodigoPacote,
 order_status  as StatusEntrega
,		receiver_name as RecebidoPor,
		dateadd(second,((cast(timestamp as bigint))) - 10800,'1970-01-01') DataHoraEntrega,
		cast(dateadd(second,((cast(timestamp as bigint))) - 10800,'1970-01-01') as date) DataReferencia,
		trip_number as CodigoRota,
		trace_id
	into #pacote_atualizado
	from #aux as aux
	cross apply openjson (aux.jsondata, '$.data.body.content_data.data')
	WITH (
		delivery_latitude FLOAT '$.delivery_latitude',
		delivery_longitude FLOAT '$.delivery_longitude',
		onhold_reason NVARCHAR(255) '$.onhold_reason',
		order_number NVARCHAR(50) '$.order_number',
		order_status NVARCHAR(50) '$.order_status',
		receiver_name NVARCHAR(100) '$.receiver_name',
		timestamp BIGINT '$.timestamp',
		trip_number NVARCHAR(50) '$.trip_number'
	) as jsondata
	cross apply openjson (aux.jsondata, '$.data')
	WITH (
		trace_id NVARCHAR(500) '$.trace_id'
	) as header;

DROP TABLE IF EXISTS #pacote_filtrado;

SELECT *
INTO #pacote_filtrado
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY IdTransportadora, CodigoRota, CodigoPacote, DataReferencia
            ORDER BY DataHoraEntrega DESC
        ) AS rn
    FROM #pacote_atualizado
) AS sub
WHERE rn = 1;

MERGE INTO tb_spe_pacotes_v5   AS target
USING (
    SELECT *
    FROM #pacote_filtrado WITH (NOLOCK)
) AS source
ON target.IdTransportadora = source.IdTransportadora
  AND target.CodigoRota = source.CodigoRota
  AND target.CodigoPacote = source.CodigoPacote
  AND target.Excluido = 0
  AND target.DataReferencia = source.DataReferencia

WHEN MATCHED THEN
    UPDATE SET
        target.latitude = source.latitude,
        target.longitude = source.longitude,
        target.StatusEntrega = source.StatusEntrega,
        target.SubStatus = source.SubStatus,
        target.RecebidoPor = source.RecebidoPor,
        target.DataHoraEntrega = source.DataHoraEntrega,
        target.DataAtualizacao = GETDATE()

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        IdTransportadora, DataReferencia, CodigoRota, latitude, longitude, CodigoPacote,
        StatusEntrega, RecebidoPor, DataHoraEntrega, Excluido, DataAtualizacao
    )
    VALUES (
        source.IdTransportadora, source.DataReferencia, source.CodigoRota,
        source.latitude, source.longitude, source.CodigoPacote,
        source.StatusEntrega, source.RecebidoPor, source.DataHoraEntrega, 0, GETDATE()
    );

DROP TABLE IF EXISTS #pacotes_transferidos;

WITH UltimosPacotes AS (
    SELECT
        CodigoPacote,
        IdTransportadora,
        MAX(DataHoraEntrega) AS DataMaisRecente
    FROM tb_spe_pacotes_v5
    WHERE DataHoraEntrega >= CAST(GETDATE()-2 AS date)
      AND Excluido = 0
    GROUP BY CodigoPacote, IdTransportadora
)
SELECT
    p.Id,
    p.CodigoPacote,
    p.CodigoRota,
    p.DataReferencia,
    p.IdTransportadora,
    p.DataHoraEntrega
INTO #pacotes_transferidos
FROM tb_spe_pacotes_v5 p
JOIN UltimosPacotes u
  ON p.CodigoPacote = u.CodigoPacote
 AND p.IdTransportadora = u.IdTransportadora
WHERE p.DataHoraEntrega >= CAST(GETDATE()-2 AS date)
  AND p.DataHoraEntrega < u.DataMaisRecente
  AND p.Excluido = 0;

UPDATE tb_spe_pacotes_v5
SET
    StatusEntrega = 'Transferred',
    DataAtualizacao = GETDATE()
FROM tb_spe_pacotes_v5 p
JOIN #pacotes_transferidos t
  ON p.CodigoPacote = t.CodigoPacote
 AND p.IdTransportadora = t.IdTransportadora
 AND p.CodigoRota = t.CodigoRota
 AND p.DataReferencia = t.DataReferencia
 AND p.DataHoraEntrega = t.DataHoraEntrega;

 WITH PacotesAlvo AS (
    SELECT DISTINCT CodigoPacote, IdTransportadora, codigorota
    FROM #pacote_filtrado
),
PacotesRankeados AS (
    SELECT
        p.Id,
        p.CodigoPacote,
        p.IdTransportadora,
        ROW_NUMBER() OVER (
            PARTITION BY p.CodigoPacote, p.IdTransportadora
            ORDER BY p.Id DESC
        ) AS rn
    FROM tb_spe_pacotes_v5 p
    JOIN PacotesAlvo f
      ON p.CodigoPacote = f.CodigoPacote
     AND p.IdTransportadora = f.IdTransportadora
     AND p.CodigoRota = f.codigorota
    WHERE p.Excluido = 0
      AND CAST(p.datareferencia AS date) >= CAST(GETDATE()-7 AS date)
)
UPDATE p
SET
    Excluido = 1,
    DataAtualizacao = GETDATE()
FROM tb_spe_pacotes_v5 p
JOIN PacotesRankeados r ON p.Id = r.Id
WHERE r.rn > 1
  AND CAST(p.datareferencia AS date) >= CAST(GETDATE()-7 AS date);

	update a
	set processingStatus = 1
	from db_Irisys_Json.dbo.tb_spe_webhook as a
	inner join #aux as b
	on a.id = b.id

END;
GO
