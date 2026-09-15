-- ============================================================
-- BASELINE: dbo.UspGetLoadRotasV5
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetLoadRotasV5]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGetLoadRotasV5] 
as

	

	drop table if exists  #aux
	select 		 *
	 into  #aux
	from db_Irisys_Json.dbo.tb_spe_webhook with(nolock)
	-- where cast(createdAt as date) &gt;= '2024-09-19'
	where TipoJson = 'trip_info'
    and cast(createdAt as date) = cast(getdate() as date)
	and processingStatus = 0
	and idtransportadora is not null
	and UltimoRegistro = 1

	


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
		,		    dateadd(second,((cast(trip_collecting_datetime as bigint))) - 10800,'1970-01-01') as DataHoraDesignacaoRota
        ,aux.agency AgencyId

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
		target.DistanciaTotal = source.DistanciaTotal,
		target.DataHoraDesignacaoRota = source.DataHoraDesignacaoRota,
        target.AgencyId = source.AgencyId


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
        DistanciaTotal,
		DataHoraDesignacaoRota,
        AgencyId
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
        DistanciaTotal,
		DataHoraDesignacaoRota,
        AgencyId
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
		,value as CodigoPacote,
		DataHoraDesignacaoRota

    into #pacotes
    from #aux as aux 
	inner join #rotas as b
	on aux.codigorota = b.codigorota
    cross apply openjson (aux.jsondata, '$.data.body.content_data.data[0].order_list')
	
	/*
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
--*/

--    insert into tb_spe_pacotes_v5 (idtransportadora,CodigoRota,CodigoPacote,DataReferencia,DataHoraColeta ,IdMotorista, Excluido,StatusEntrega,DataAtualizacao)
--    select top 1
--        a.idtransportadora	
--      ,a.CodigoRota
--      ,a.CodigoPacote 
--      ,cast(r.DataReferencia as date) as DataReferencia
--      ,cast(r.DataHoraColeta as date) as DataHoraColeta
--      ,cast(r.IdMotorista as int)  as IdMotorista
--      ,0 as Excluido
--      ,'Pending' StatusEntrega
--      ,getdate() DataAtualizacao

--      --select *
--    from #pacotes as a
--    left join tb_spe_pacotes_v5 as b
--    on a.idtransportadora = b.idtransportadora
--    and a.CodigoRota = b.CodigoRota
--    and a.CodigoPacote = b.CodigoPacote
--    left join #rotas as r
--    on a.CodigoRota = r.CodigoRota

--    where b.CodigoPacote is null

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
GO
