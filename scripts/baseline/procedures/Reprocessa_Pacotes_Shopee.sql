-- ============================================================
-- BASELINE: dbo.Reprocessa_Pacotes_Shopee
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Reprocessa_Pacotes_Shopee]    Script Date: 14/09/2026 12:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE
 [dbo].[Reprocessa_Pacotes_Shopee]

 as 
DROP TABLE IF EXISTS #aux;

SELECT w.*
INTO #aux
FROM db_Irisys_Json.dbo.tb_spe_webhook w WITH (NOLOCK)
LEFT JOIN tb_spe_pacotes_v5 p
    ON W.CODIGOPACOTE = p.CodigoPacote
    AND  W.CODIGOROTA =  p.CodigoRota
    AND w.idtransportadora = p.IdTransportadora -- Garante que são da mesma transportadora
CROSS APPLY OPENJSON (w.jsondata, '$.data.body.content_data.data') -- Pegamos os valores de dentro do ARRAY 'data'
WITH (
    delivery_latitude FLOAT '$.delivery_latitude',
    delivery_longitude FLOAT '$.delivery_longitude',
    onhold_reason NVARCHAR(255) '$.onhold_reason',
    order_number NVARCHAR(50) '$.order_number',
    order_status NVARCHAR(50) '$.order_status',
    receiver_name NVARCHAR(100) '$.receiver_name',
    timestamp BIGINT '$.timestamp',
    trip_number NVARCHAR(50) '$.trip_number'
) AS jsondata
WHERE 
    CAST(w.createdAt AS DATE) = CAST(GETDATE() AS DATE) 
    AND w.TipoJson = 'order_update' 
    AND w.idtransportadora IS NOT NULL
    AND w.ultimoregistro = 1
    AND (
        w.processingStatus = 0 -- Regra original: processa registros novos
        OR (
            w.processingStatus = 1 -- Caso o processamento já tenha ocorrido
            AND jsondata.order_status <>    p.StatusEntrega   --'Delivered' -- Agora acessamos corretamente o campo do JSON
       --   = 'DELIVERING' -- Mas o status na tb_spe_pacotes_v5 ainda está como DELIVERING
        )
    );

	   	  

	drop table if exists  #pacote_atualizado
	select 

		idtransportadora as idtransportadora,
		delivery_latitude as latitude,
		delivery_longitude as longitude,
		case when onhold_reason = '' then null else onhold_reason end as SubStatus,
		order_number as CodigoPacote,
		order_status as StatusEntrega,
		receiver_name as RecebidoPor,
		dateadd(second,((cast(timestamp as bigint))) - 10800,'1970-01-01') DataHoraEntrega,
		cast(dateadd(second,((cast(timestamp as bigint))) - 10800,'1970-01-01') as date) DataReferencia,
		-- DataReferencia,
		trip_number as CodigoRota
	
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



		MERGE INTO tb_spe_pacotes_v5 AS target
		USING #pacote_atualizado AS source
		ON target.IdTransportadora = source.IdTransportadora
		  AND target.CodigoRota = source.CodigoRota
		  AND target.CodigoPacote= source.CodigoPacote
		  and target.Excluido = 0 
		--  AND target.DataReferencia = source.DataReferencia

		-- Se as colunas-chave já existirem, atualiza as colunas
		WHEN MATCHED THEN
			UPDATE SET 
				target.latitude = source.latitude,
				target.longitude = source.longitude,
				target.StatusEntrega = source.StatusEntrega,
                target.SubStatus = source.SubStatus,
				target.RecebidoPor = source.RecebidoPor,
				target.DataHoraEntrega = source.DataHoraEntrega,
				target.dataatualizacao = getdate();
            
		-- Se as colunas-chave não existirem, insere os novos registros
		-- WHEN NOT MATCHED BY TARGET THEN
		-- 	INSERT (IdTransportadora,DataReferencia, CodigoRota, latitude, longitude, CodigoPacote, StatusEntrega, RecebidoPor, DataHoraEntrega, Excluido)
		-- 	VALUES (source.IdTransportadora, source.DataReferencia, source.CodigoRota, source.latitude, source.longitude, source.CodigoPacote, source.StatusEntrega, source.RecebidoPor, source.DataHoraEntrega, 0);


	-- select * from  #rotas 
	update a
	set processingStatus = 1
	from db_Irisys_Json.dbo.tb_spe_webhook as a
	inner join #aux as b
	on a.id = b.id

GO
