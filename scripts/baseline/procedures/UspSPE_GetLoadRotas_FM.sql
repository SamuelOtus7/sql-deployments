-- ============================================================
-- BASELINE: dbo.UspSPE_GetLoadRotas_FM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPE_GetLoadRotas_FM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPE_GetLoadRotas_FM] as


	drop table if exists  #aux
	select 		*
	 into  #aux
	from db_Irisys_Json.dbo.tb_spe_webhook with(nolock)
	where TipoJson = 'FM-TRIP'
	and idtransportadora is not null
	and UltimoRegistro = 1

	and cast(createdAt as date) = CAST(GETDATE() AS date)
	and processingStatus = 0



DROP TABLE IF EXISTS #TripsDetalhes;
SELECT DISTINCT
    b.id,
    b.createdAt                                   AS DataCriacaoRegistro,
    b.TipoJson                                   AS TipoJson,
    b.CodigoRota                                 AS CodigoRota,
    b.CodigoPacote                               AS CodigoPacote,
    b.agency                                     AS Agencia,
    b.idtransportadora                           AS IdTransportadora,
    b.UltimoRegistro                             AS UltimoRegistro,

    -- Identificação e status da rota
    JSON_VALUE(b.jsonData, '$.data.trace_id') AS CodigoTrace,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_name') AS NomeRota,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_status') AS StatusRota,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_type') AS TipoRota,

    -- Conversão do trip_date (timestamp ? DATETIME)
    DATEADD(SECOND,
            TRY_CAST(JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_date') AS BIGINT),
            '1970-01-01') AS DataHoraColeta,

    -- Distância da rota
    TRY_CAST(JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_distance') AS DECIMAL(10,2)) AS DistanciaTotal,

    -- Hub e informações da base
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_handover_hub')    AS NomeHub,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_handover_hub_id') AS IdStation,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.trip_handover_cnpj')   AS CnpjHub,

    -- Motorista e veículo
    TRY_CAST(JSON_VALUE(b.jsonData, '$.data.body.content_data.data.driver_id') AS BIGINT) AS IdMotorista,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.driver_name') AS Motorista,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.vehicle_plate') AS Placa,
    JSON_VALUE(b.jsonData, '$.data.body.content_data.data.vehicle_type')  AS TipoVeiculo,

    -- Valor de pedágio
    TRY_CAST(JSON_VALUE(b.jsonData, '$.data.body.content_data.data.toll_fee') AS DECIMAL(10,2)) AS ValorPedagio,

    -- Lista de pontos de coleta (JSON completo)
    JSON_QUERY(b.jsonData, '$.data.body.content_data.data.pickup_point_list') AS ListaPontosColeta,

    -- Conversão do timestamp geral do evento (timestamp ? DATETIME)
    DATEADD(SECOND,
            TRY_CAST(JSON_VALUE(b.jsonData, '$.timestamp') AS BIGINT),
            '1970-01-01') AS DataHoraEvento

INTO #TripsDetalhes
FROM #aux b





 MERGE INTO tb_spe_rotas_v5 AS target
    USING #TripsDetalhes AS source
    ON target.CodigoRota = source.CodigoRota
    AND target.IdTransportadora = source.IdTransportadora
    --and TARGET.datareferencia = cast(source.datahoraevento as date)
    and target.Excluido = 0

    WHEN MATCHED THEN
        UPDATE SET
          
        target.IdMotorista = source.IdMotorista,
        target.Motorista = source.Motorista,
        target.DataHoraColeta = source.DataHoraColeta,
        target.DataReferencia = cast(source.datahoraevento as date),
        target.IdStation = source.IdStation,
        target.NomeHub = source.NomeHub,
        target.CodigoRota = source.CodigoRota,
        target.Placa = source.Placa,
        target.TipoVeiculo = source.TipoVeiculo,
        target.DataHoraInicio = source.datahoraevento,
		target.DistanciaTotal = source.DistanciaTotal,
        target.AgencyId = source.Agencia,
        target.NomeRota = source.NomeRota


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
        AgencyId,
        TipoOperacao,
        NomeRota
        )
        VALUES (
        source.Idtransportadora,
        source.IdMotorista,
        source.Motorista,
        source.DataHoraColeta,
        source.datahoraevento,
        source.IdStation,
        source.NomeHub,
        source.CodigoRota,
        source.Placa,
        source.TipoVeiculo,
        0,
        source.datahoraevento,
        DistanciaTotal,
        source.Agencia,
        'FM',
        source.NomeRota
        );

       ----------
    UPDATE W
    SET W.processingStatus = 1,
        W.processingDatetime = GETDATE()
    FROM db_Irisys_Json.dbo.tb_spe_webhook W
    INNER JOIN #aux A
        ON W.id = A.id;
GO
