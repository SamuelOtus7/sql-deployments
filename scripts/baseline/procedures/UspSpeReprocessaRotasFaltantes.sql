-- ============================================================
-- BASELINE: dbo.UspSpeReprocessaRotasFaltantes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSpeReprocessaRotasFaltantes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSpeReprocessaRotasFaltantes] 
as




	drop table if exists  #aux
SELECT *--DISTINCT a.CodigoRota
into #aux
FROM db_Irisys_Json.dbo.tb_spe_webhook a WITH (NOLOCK)
WHERE 
    a.createdAt >= DATEADD(DAY, -30, CAST(GETDATE() AS date))
    AND a.TipoJson = 'trip_info'
    AND NOT EXISTS (
        SELECT 1
        FROM db_Irisys_Json.dbo.tb_spe_webhook b WITH (NOLOCK)
        WHERE 
            b.CodigoRota = a.CodigoRota
            AND b.TipoJson = 'trip_info'
            and UltimoRegistro = 1
            AND b.ProcessingStatus = 1
            AND b.createdAt >= DATEADD(DAY, -30, CAST(GETDATE() AS date))
    )
      AND NOT EXISTS (
        SELECT 1
        FROM TB_SPE_ROTAS_V5 r WITH (NOLOCK)
        WHERE r.CodigoRota = a.CodigoRota
    )

	--select processingStatus,count(*) 
	--from #aux
	--group by processingStatus

-- select * from #aux


	drop table if exists  #rotas
    SELECT 
         aux.idtransportadora as Idtransportadora,
        driver_id as IdMotorista,
        driver_name as Motorista,
        dateadd(second,((cast(trip_date as bigint))) - 10800,'1970-01-01')  as DataHoraColeta,
		    dateadd(second,((cast(trip_collecting_datetime as bigint))) - 10800,'1970-01-01') as DataReferencia,
        --cast(dateadd(second,((cast(trip_collecting_datetime as bigint))) - 10800,'1970-01-01') as date) as DataReferencia,
        dateadd(second,((cast(timestamp as bigint))) - 10800,'1970-01-01') as DataHoraInicio,
        trip_hub_id as IdStation,
        trip_hub_name as NomeHub,
        trip_number as CodigoRota,
        vehicle_plate Placa,
        vehicle_type as TipoVeiculo,
        null IdStatus
        ,null as DataAtualizacao
        ,0 as Excluido
        ,null as TotalPacotes
        ,null as PacotesEntregues
        ,null as PacotesNaoEntregue
        ,null as PacotesPendentes
        ,null as DataUltimaEntrega
        ,null as KmColetado
        ,null as LinkMapa
        ,null as DataHoraCarga
        ,null as Paradas
        ,null as CidadeReferencia
        ,trip_distance as DistanciaTotal
        ,null as UsuarioIrisys
        ,null as KmApp
        ,null as LinkMapaApp
        ,null as QuantidadeApontamento
        ,null as LinkAppInterno
        ,null as Apuracao
        ,null as UsouAPP
        ,order_number as Pedidos

	into #rotas

    from #aux as aux 
    cross apply openjson (aux.jsondata, '$')
    WITH (
        driver_id INT '$.data.body.content_data.data[0].driver_id',
        driver_name NVARCHAR(100) '$.data.body.content_data.data[0].driver_name',
        trip_collecting_datetime BIGINT '$.data.body.content_data.data[0].trip_collecting_datetime',
        trip_date BIGINT '$.data.body.content_data.data[0].trip_date',
        trip_distance decimal(10,2) '$.data.body.content_data.data[0].trip_distance',
        trip_hub_id INT '$.data.body.content_data.data[0].trip_hub_id',
        trip_hub_name NVARCHAR(255) '$.data.body.content_data.data[0].trip_hub_name',
        trip_number NVARCHAR(50) '$.data.body.content_data.data[0].trip_number',
        vehicle_plate NVARCHAR(20) '$.data.body.content_data.data[0].vehicle_plate',
        vehicle_type NVARCHAR(50) '$.data.body.content_data.data[0].vehicle_type',
        order_number varchar(50) '$.data.body.content_data.data[0].order_list',
        timestamp varchar(50) '$.timestamp'
    );


    MERGE INTO tb_spe_rotas_v5 AS target
    USING #rotas AS source
    ON target.CodigoRota = source.CodigoRota
    AND target.IdTransportadora = source.IdTransportadora
    and TARGET.datareferencia = source.datareferencia
    and target.Excluido = 0

    WHEN MATCHED THEN
        UPDATE SET
          
        target.IdMotorista = source.IdMotorista,
        target.Motorista = source.Motorista,
        target.DataHoraColeta = source.DataHoraColeta,
        target.DataReferencia = source.DataReferencia,
        target.IdStation = source.IdStation,
        target.NomeHub = source.NomeHub,
        target.CodigoRota = source.CodigoRota,
        target.Placa = source.Placa,
        target.TipoVeiculo = source.TipoVeiculo,
        target.DataHoraInicio = source.DataHoraInicio,
		target.DistanciaTotal = source.DistanciaTotal



    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
        Idtransportadora,
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
        DistanciaTotal
        )
        VALUES (
        source.Idtransportadora,
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
        DistanciaTotal
        );

    
    drop table if exists #pacotes
	select 
		aux.idtransportadora as Idtransportadora
		,aux.codigorota
		,DataReferencia
		,DataHoraColeta
		,DataHoraInicio
		,IdMotorista
		,0 excluido
		,value as CodigoPacote

    into #pacotes
    from #aux as aux 
	inner join #rotas as b
	on aux.codigorota = b.codigorota
    cross apply openjson (aux.jsondata, '$.data.body.content_data.data[0].order_list')
	
	
	insert into tb_spe_pacotes_v5 (IdTransportadora, CodigoRota, DataReferencia, DataHoraColeta, IdMotorista, excluido, CodigoPacote,StatusEntrega) 
	select 
		 a.idtransportadora
		,a.codigorota
		,a.DataReferencia
		,a.DataHoraColeta
		,a.IdMotorista
		,a.excluido
		,a.CodigoPacote
        ,'Delivering' StatusEntrega
	from #pacotes as a
	left join tb_spe_pacotes_v5 as b
	on a.CodigoPacote = b.CodigoPacote
	and  a.CodigoRota = b.codigorota
	where b.datareferencia>= CAST(getdate()-2 as date)
 and  b.CodigoPacote is null 
	   AND NOT EXISTS (
        SELECT 1
        FROM tb_spe_pacotes_v5 b2 WITH (NOLOCK)
        WHERE b2.CodigoPacote = a.CodigoPacote
          AND b2.StatusEntrega = 'Delivered'
          AND b2.Excluido = 0
		  and b2.DataReferencia >=CAST(getdate()-2 as date)

    )



	update a
	set
		processingDatetime =CAST(getdate() as date)
, 
		processingStatus = 1
	
	from db_Irisys_Json.dbo.tb_spe_webhook as a (nolock)
	inner join #aux as b
	on a.id = b.id;
	------------------------

	WITH RotasDuplicadas AS (
    SELECT 
        Id,
        ROW_NUMBER() OVER (
            PARTITION BY CodigoRota, IdTransportadora, DataReferencia
            ORDER BY Id DESC
        ) AS rn
    FROM tb_spe_rotas_v5
    WHERE Excluido = 0
	      AND DataReferencia >='2025-01-01'

)
UPDATE tb
SET Excluido = 1
FROM tb_spe_rotas_v5 tb
INNER JOIN RotasDuplicadas dup ON tb.Id = dup.Id
WHERE dup.rn> 1;


----Pacotes



DROP TABLE IF EXISTS #aux_pac;

SELECT  a.*
INTO #aux_pac
FROM db_Irisys_Json.dbo.tb_spe_webhook a  WITH (NOLOCK) 
join #aux as b
on a.CodigoRota = b.codigorota
and a.TipoJson = 'order_update'
WHERE CAST(a.createdAt AS DATE) >= DATEADD(DAY, -30, CAST(GETDATE() AS date))
--  and id = 63263851
  and a.idtransportadora is not null
  AND (
        -- Caso padrão:  ainda não processado
        ( a.processingStatus = 0)

        -- OU: já processado, mas é Delivered
        OR EXISTS (
            SELECT 1
            FROM OPENJSON(a.jsondata, '$.data.body.content_data.data[0]')
            WITH (
                order_status NVARCHAR(50) '$.order_status'
            ) AS j
            WHERE j.order_status = 'Delivered'
        )
    )

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

		trace_id -- puxando o trace_id puro, sem tratar nada

	into #pacote_atualizado

	from #aux_pac as #aux_pac

	cross apply openjson (#aux_pac.jsondata, '$.data.body.content_data.data')
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

	cross apply openjson (#aux_pac.jsondata, '$.data')
	WITH (
		trace_id NVARCHAR(500) '$.trace_id'
	) as header;


DROP TABLE IF EXISTS #pacote_filtrado;

-- Cria a tabela temporária com apenas o último registro por grupo
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
        target.DataAtualizacao =CAST(getdate() as date)


WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        IdTransportadora, DataReferencia, CodigoRota, latitude, longitude, CodigoPacote,
        StatusEntrega, RecebidoPor, DataHoraEntrega, Excluido
    )
    VALUES (
        source.IdTransportadora, source.DataReferencia, source.CodigoRota,
        source.latitude, source.longitude, source.CodigoPacote,
        source.StatusEntrega, source.RecebidoPor, source.DataHoraEntrega, 0
    );


-- Detecta pacotes transferidos (ou seja, mesmo pacote em outra rota com data mais recente)
DROP TABLE IF EXISTS #pacotes_transferidos;

-- Para cada pacote, encontra sua entrega mais recente (apenas últimos 2 dias)
WITH UltimosPacotes AS (
    SELECT 
        CodigoPacote,
        IdTransportadora,
        MAX(DataHoraEntrega) AS DataMaisRecente
    FROM tb_spe_pacotes_v5
    WHERE          DataHoraEntrega >=CAST(getdate()-2 as date)

	AND
        Excluido = 0
    GROUP BY CodigoPacote, IdTransportadora
)

-- Agora encontra os registros antigos desse pacote que devem ser marcados como 'Transferred'
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
WHERE 
	     p.DataHoraEntrega >= CAST(getdate()-2 as date)


 AND   p.DataHoraEntrega < u.DataMaisRecente

    AND p.Excluido = 0;

-- Atualiza os pacotes marcando como 'Transferred'
UPDATE tb_spe_pacotes_v5
SET 
    StatusEntrega = 'Transferred',
    DataAtualizacao =CAST(getdate() as date)

FROM tb_spe_pacotes_v5 p
JOIN #pacotes_transferidos t
  ON p.CodigoPacote = t.CodigoPacote
 AND p.IdTransportadora = t.IdTransportadora
 AND p.CodigoRota = t.CodigoRota
 AND p.DataReferencia = t.DataReferencia
 AND p.DataHoraEntrega = t.DataHoraEntrega;



 



 WITH PacotesAlvo AS (
    SELECT DISTINCT CodigoPacote, IdTransportadora,codigorota
    FROM #pacote_filtrado
),
PacotesRankeados AS (
    SELECT 
        p.Id,
        p.CodigoPacote,
        p.IdTransportadora,
        ROW_NUMBER() OVER (
            PARTITION BY p.CodigoPacote, p.IdTransportadora
            ORDER BY p.Id DESC -- o mais recente (maior ID) fica como rn = 1
        ) AS rn
    FROM tb_spe_pacotes_v5 p
    JOIN PacotesAlvo f
      ON p.CodigoPacote = f.CodigoPacote
     AND p.IdTransportadora = f.IdTransportadora
	 and p.CodigoRota = f.codigorota
    WHERE p.Excluido = 0
	and CAST(p.datareferencia as date) >= CAST(getdate()-7 as date)
)

-- Atualiza os registros que NÃO são os mais recentes (rn > 1)
UPDATE p
SET 
    Excluido = 1,
    DataAtualizacao = CAST(getdate() as date)

FROM tb_spe_pacotes_v5 p
JOIN PacotesRankeados r ON p.Id = r.Id
WHERE r.rn > 1
	and CAST(p.datareferencia as date) >= CAST(getdate()-7 as date)


	-- select * from  #rotas 
	update a
	set processingStatus = 1
	from db_Irisys_Json.dbo.tb_spe_webhook as a
	inner join #aux_pac as b
	on a.id = b.id



GO
