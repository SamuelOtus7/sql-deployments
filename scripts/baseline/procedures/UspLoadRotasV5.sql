-- ============================================================
-- BASELINE: dbo.UspLoadRotasV5
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadRotasV5]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspLoadRotasV5] ( 
@jsonParm varchar(MAX),
@agencyTeste int ,
@idtransportadoraTeste int,
@TipoJsonTeste nvarchar(100)
) 
as
BEGIN

DECLARE @json NVARCHAR(MAX) = @jsonParm
-- declare @TipoJsonTeste nvarchar(100) = (SELECT value FROM OPENJSON(@json, '$.data.body.content_data') where [key] = 'business_type') 
-- declare @agencyTeste int = (SELECT value FROM OPENJSON(@json, '$.data') where [key] = 'agency_id') 



declare @TipoJson nvarchar(100) = @TipoJsonTeste 
declare @agency int = @agencyTeste
-- declare @idtransportadoraTeste int = (select cli_id_shopee from tb_clientes where cli_agency_shpee = @agency) 
declare @idtransportadora int = @idtransportadoraTeste

declare @Tabela varchar(max) 

if @TipoJson = 'trip_info'
begin 
   
   set @Tabela = ( SELECT value FROM OPENJSON(@json, '$.data.body.content_data') where [key] = 'data')

    drop table if exists #rotas
    SELECT 
        @idtransportadora as Idtransportadora,
        driver_id as IdMotorista,
        driver_name as Motorista,
        dateadd(second,((cast(trip_collecting_datetime as bigint))) - 10800,'1970-01-01')  as DataHoraColeta,
        cast(dateadd(second,((cast(trip_date as bigint))) - 10800,'1970-01-01') as date) as DataReferencia,
        dateadd(second,((cast(trip_date as bigint))) - 10800,'1970-01-01') as DataHoraInicio,
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

    FROM OPENJSON(@Tabela)
    WITH (
        driver_id INT '$.driver_id',
        driver_name NVARCHAR(100) '$.driver_name',
        trip_collecting_datetime BIGINT '$.trip_collecting_datetime',
        trip_date BIGINT '$.trip_date',
        trip_distance decimal(10,2) '$.trip_distance',
        trip_hub_id INT '$.trip_hub_id',
        trip_hub_name NVARCHAR(255) '$.trip_hub_name',
        trip_number NVARCHAR(50) '$.trip_number',
        vehicle_plate NVARCHAR(20) '$.vehicle_plate',
        vehicle_type NVARCHAR(50) '$.vehicle_type',
        order_number varchar(50) '$.data[0].order_list'
    );

    drop table if exists #pacotes
    select
    @idtransportadora as idtransportadora
    ,(select distinct codigorota from #rotas) as codigorota
    ,value as CodigoPacote
    into #pacotes
    from openjson(@json, '$.data.body.content_data.data[0].order_list')

    update #rotas 
    set TotalPacotes =  (select count(*) from #pacotes)
    ,PacotesPendentes = (select count(*) from #pacotes)
     

    insert into tb_spe_pacotes_v5 (idtransportadora,CodigoRota,CodigoPacote,DataReferencia,DataHoraColeta ,IdMotorista, Excluido,StatusEntrega,DataAtualizacao)
    select 
        a.idtransportadora	
      ,a.CodigoRota
      ,a.CodigoPacote 
      ,(select distinct cast(DataReferencia as date) from #rotas) as DataReferencia
      ,(select distinct cast(DataHoraColeta as date) from #rotas) as DataHoraColeta
      ,(select distinct cast(IdMotorista as int) from #rotas) as IdMotorista 
      ,0 as Excluido
      ,'Pending' StatusEntrega
      ,getdate() DataAtualizacao

    from #pacotes as a
    left join tb_spe_pacotes_v5 as b
    on a.idtransportadora = b.idtransportadora
    and a.CodigoRota = b.CodigoRota
    and a.CodigoPacote = b.CodigoPacote
    where b.CodigoPacote is null


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
end
else if @TipoJson = 'order_update'
begin 

    set @Tabela = ( SELECT value FROM OPENJSON(@json, '$.data.body.content_data') where [key] = 'data')


    drop table if exists #pacote_atualizado 
    SELECT 
        @idtransportadora as idtransportadora,
        delivery_latitude as latitude,
        delivery_longitude as longitude,
        onhold_reason as MotivoAtraso,
        order_number as CodigoPacote,
        order_status as StatusEntrega,
        receiver_name as RecebidoPor,
        dateadd(second,((cast(timestamp as bigint))) - 10800,'1970-01-01') DataHoraEntrega,
        cast(dateadd(second,((cast(timestamp as bigint))) - 10800,'1970-01-01') as date) DataReferencia,
        trip_number as CodigoRota
        

        into #pacote_atualizado

    FROM OPENJSON(@Tabela)
    WITH (
        delivery_latitude FLOAT '$.delivery_latitude',
        delivery_longitude FLOAT '$.delivery_longitude',
        onhold_reason NVARCHAR(255) '$.onhold_reason',
        order_number NVARCHAR(50) '$.order_number',
        order_status NVARCHAR(50) '$.order_status',
        receiver_name NVARCHAR(100) '$.receiver_name',
        timestamp BIGINT '$.timestamp',
        trip_number NVARCHAR(50) '$.trip_number'
    );



    MERGE INTO tb_spe_pacotes_v5 AS target
    USING #pacote_atualizado AS source
    ON target.IdTransportadora = source.IdTransportadora
      AND target.CodigoRota = source.CodigoRota
      AND target.CodigoPacote= source.CodigoPacote
      and target.Excluido = 0 
      AND target.DataReferencia = source.DataReferencia
    -- Se as colunas-chave já existirem, atualiza as colunas
    WHEN MATCHED THEN
        UPDATE SET 
            target.latitude = source.latitude,
            target.longitude = source.longitude,
            target.StatusEntrega = source.StatusEntrega,
            target.RecebidoPor = source.RecebidoPor,
            target.DataHoraEntrega = source.DataHoraEntrega
            
    -- Se as colunas-chave não existirem, insere os novos registros
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (IdTransportadora,DataReferencia, CodigoRota, latitude, longitude, CodigoPacote, StatusEntrega, RecebidoPor, DataHoraEntrega, Excluido)
        VALUES (source.IdTransportadora, source.DataReferencia, source.CodigoRota, source.latitude, source.longitude, source.CodigoPacote, source.StatusEntrega, source.RecebidoPor, source.DataHoraEntrega, 0);

end

end 
  
-- select * from  #rotas 



  
GO
