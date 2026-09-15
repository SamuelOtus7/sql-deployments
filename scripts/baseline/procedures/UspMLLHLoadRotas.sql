-- ============================================================
-- BASELINE: dbo.UspMLLHLoadRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLHLoadRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLLHLoadRotas] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@DataColeta datetime,
	@DataReferencia date
)
as
begin

	SET NOCOUNT ON;	
	--declare @JSON VARCHAR(max)
	--declare @IdTransportadora int
	--declare @DataColeta datetime
	--declare @DataReferencia date
	
	-- select
	-- 	@JSON = dac_ds_contexto_json,
	-- 	@IdTransportadora = dac_cd_transportadora,
	-- 	@DataColeta = dac_dh_coleta,
	-- 	@DataReferencia = dac_dh_referencia
	-- from
	-- 	db_Irisys_Json.dbo.tb_dra_coleta with(nolock)
	-- where
	-- 	dac_cd_coleta = 50249860

	DECLARE @JsonRoutes nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'line_hauls_by_route') --line_hauls_by_id
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonRoutes) WHERE [key] = 'list') 

	drop table if exists #rotas
	SELECT 
		IdRota
		,@IdTransportadora IdTransportadora
		,ltrim(rtrim(CarrierId)) CarrierId
		,cast(@IdTransportadora as varchar(60)) CarrierIdConferencia
		,cast(DataReferencia as date) DataReferencia
		,RosteringId
		,CodigoRota 
		,DataPartidaEsperada
		,DataFinalizacao
		,Status
		,SubStatus
		,StatusGeral
		,SubstatusGeral
		,SecaoRota
		,IdMotorista
		,NomeMotorista
		,SequenciaMotorista
		,IdVeiculo
		,Placa
		,TipoVeiculo
		,IdVeiculo1
		,PlacaVeiculo1
		,TracaoVeiculo1
		,IdVeiculo2
		,PlacaVeiculo2
		,TracaoVeiculo2
		,QuantidadeTotalRotas
		,IdParadaOrigem
		,StatusParadaOrigem
		,TipoParadaOrigem
		,NomeServiceCenterOrigem
		,ServiceCenterOrigem
		,DataInicioEsperadaOrigem
		,DataFinalizacaoEsperadaOrigem
		,FonteInicioOrigem
		,FonteFinalizacaoOrigem
		,EtaOrigem
		,AtaOrigem
		,EtdOrigem
		,AtdOrigem
		,IdCargaOrigem
		,TotalUnidadesTransporteOrigem
		,TotalPacotesOrigem
		,TotalPacotesAcumuladosOrigem
		,IdParadaDestino
		,StatusParadaDestino
		,TipoParadaDestino
		,NomeServiceCenterDestino
		,ServiceCenterDestino
		,DataInicioEsperadaDestino
		,DataFinalizacaoEsperadaDestino
		,FonteInicioDestino
		,FonteFinalizacaoDestino
		,EtaDestino
		,AtaDestino
		,EtdDestino
		,AtdDestino
		,IdCargaDestino
		,TotalUnidadesTransporteDestino
		,TotalPacotesDestino
		,TotalPacotesAcumuladosDestino
		,@DataColeta DataHoraColeta
		,getdate() DataAtualizacao
		,0 Excluido
	--	,ROW_NUMBER() over ( partition by IdRota, cast(DataReferencia as date) order by case when Status = 'finished' then 1 else 2 end asc) as OrdemExclusao
		--o ROW NUMBER acima considera a mesma rota mais de 1x, caso a data seja diferente. Atualizado 15/05
		,ROW_NUMBER() over (partition by IdRota, CarrierId order by DataReferencia DESC) as OrdemExclusao
		into #rotas
	FROM 
		OPENJSON (@JsonList)
	with
	(
		IdRota int '$.id' 
		,CarrierId varchar(60) '$.carrier_id'
		,RosteringId int '$.rostering_assign_id' 
		,CodigoRota varchar(100) '$.code' 
		,DataReferencia datetime '$.date'
		,DataPartidaEsperada datetime '$.expected_departure_date'
		,DataFinalizacao datetime '$.finish_date'
		,Status varchar(60) '$.status'
		,SubStatus varchar(60) '$.substatus'
		,StatusGeral varchar(60) '$.general_status'
		,SubstatusGeral varchar(60) '$.general_substatus'
		,SecaoRota int '$.route_section'
		,IdMotorista int '$.drivers[0].id'
		,NomeMotorista varchar(60) '$.drivers[0].name'
		,SequenciaMotorista int '$.drivers[0].sequence'
		,IdVeiculo int '$.vehicle_id'
		,Placa varchar(10) '$.vehicle_license_plate'
		,TipoVeiculo varchar(60) '$.vehicle_type'
		,IdVeiculo1 int '$.vehicles[0].id'
		,PlacaVeiculo1 varchar(10) '$.vehicles[0].license_plate'
		,TracaoVeiculo1 bit '$.vehicles[0].is_traction'
		,IdVeiculo2 int '$.vehicles[1].id'
		,PlacaVeiculo2 varchar(10) '$.vehicles[1].license_plate'
		,TracaoVeiculo2 bit '$.vehicles[1].is_traction'
		,QuantidadeTotalRotas int '$.total_route'
		,IdParadaOrigem int '$.steps[0].origin.stop_id'
		,StatusParadaOrigem varchar(60) '$.steps[0].origin.status'
		,TipoParadaOrigem varchar(60) '$.steps[0].origin.type'
		,NomeServiceCenterOrigem varchar(60) '$.steps[0].origin.facility'
		,ServiceCenterOrigem varchar(60) '$.steps[0].origin.facility_id'
		,DataInicioEsperadaOrigem datetime '$.steps[0].origin.expected_init_date'
		,DataFinalizacaoEsperadaOrigem datetime '$.steps[0].origin.expected_finish_date'
		,FonteInicioOrigem varchar(60) '$.steps[0].origin.init_date_source'
		,FonteFinalizacaoOrigem varchar(60) '$.steps[0].origin.finish_date_source'
		,EtaOrigem datetime '$.stops[0].eta'
		,AtaOrigem datetime '$.stops[0].ata'
		,EtdOrigem datetime '$.stops[0].etd'
		,AtdOrigem datetime '$.stops[0].atd'
		,IdCargaOrigem int '$.stops[0].pickup_order.order_id'
		,TotalUnidadesTransporteOrigem int '$.stops[0].pickup_order.total_transport_units'
		,TotalPacotesOrigem int '$.stops[0].pickup_order.total_packages'
		,TotalPacotesAcumuladosOrigem int '$.stops[0].pickup_order.total_accumulated_packages'
		,IdParadaDestino int '$.steps[0].destination.stop_id'
		,StatusParadaDestino varchar(60) '$.steps[0].destination.status'
		,TipoParadaDestino varchar(60) '$.steps[0].destination.type'
		,NomeServiceCenterDestino varchar(60) '$.steps[0].destination.facility'
		,ServiceCenterDestino varchar(60) '$.steps[0].destination.facility_id'
		,DataInicioEsperadaDestino datetime '$.steps[0].destination.expected_init_date'
		,DataFinalizacaoEsperadaDestino datetime '$.steps[0].destination.expected_finish_date'
		,FonteInicioDestino varchar(60) '$.steps[0].destination.init_date_source'
		,FonteFinalizacaoDestino varchar(60) '$.steps[0].destination.finish_date_source'
		,EtaDestino datetime '$.stops[1].eta'
		,AtaDestino datetime '$.stops[1].ata'
		,EtdDestino datetime '$.stops[1].etd'
		,AtdDestino datetime '$.stops[1].atd'
		,IdCargaDestino int '$.stops[1].pickup_order.order_id'
		,TotalUnidadesTransporteDestino int '$.stops[1].pickup_order.total_transport_units'
		,TotalPacotesDestino int '$.stops[1].pickup_order.total_packages'
		,TotalPacotesAcumuladosDestino int '$.stops[1].pickup_order.total_accumulated_packages'
	)

	--Deleta rotas que não são da transportadora em que foi coletado o json
	delete #rotas where CarrierId <> CarrierIdConferencia

	delete #rotas where OrdemExclusao > 1

	merge tb_ml_lh_rotas as r
	--using #rotas as i ON r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora
	using #rotas as i ON r.IdRota = i.IdRota and r.IdTransportadora = i.IdTransportadora
	when matched then
	update set
		r.RosteringId = i.RosteringId
		,r.CodigoRota = i.CodigoRota
		,r.DataReferencia = i.DataReferencia
		,r.DataPartidaEsperada = i.DataPartidaEsperada
		,r.DataFinalizacao = i.DataFinalizacao
		,r.Status = i.Status
		,r.SubStatus = i.SubStatus
		,r.StatusGeral = i.StatusGeral
		,r.SubstatusGeral = i.SubstatusGeral
		,r.SecaoRota = i.SecaoRota
		,r.IdMotorista = i.IdMotorista
		,r.NomeMotorista = i.NomeMotorista
		,r.SequenciaMotorista = i.SequenciaMotorista
		,r.IdVeiculo = i.IdVeiculo
		,r.Placa = i.Placa
		,r.TipoVeiculo = i.TipoVeiculo
		,r.IdVeiculo1 = i.IdVeiculo1
		,r.PlacaVeiculo1 = i.PlacaVeiculo1
		,r.TracaoVeiculo1 = i.TracaoVeiculo1
		,r.IdVeiculo2 = i.IdVeiculo2
		,r.PlacaVeiculo2 = i.PlacaVeiculo2
		,r.TracaoVeiculo2 = i.TracaoVeiculo2
		,r.QuantidadeTotalRotas = i.QuantidadeTotalRotas
		,r.IdParadaOrigem = i.IdParadaOrigem
		,r.StatusParadaOrigem = i.StatusParadaOrigem
		,r.TipoParadaOrigem = i.TipoParadaOrigem
		,r.NomeServiceCenterOrigem = i.NomeServiceCenterOrigem
		,r.ServiceCenterOrigem = i.ServiceCenterOrigem
		,r.DataInicioEsperadaOrigem = i.DataInicioEsperadaOrigem
		,r.DataFinalizacaoEsperadaOrigem = i.DataFinalizacaoEsperadaOrigem
		,r.FonteInicioOrigem = i.FonteInicioOrigem
		,r.FonteFinalizacaoOrigem = i.FonteFinalizacaoOrigem
		,r.EtaOrigem = i.EtaOrigem
		,r.AtaOrigem = i.AtaOrigem
		,r.EtdOrigem = i.EtdOrigem
		,r.AtdOrigem = i.AtdOrigem
		,r.IdCargaOrigem = i.IdCargaOrigem
		,r.TotalUnidadesTransporteOrigem = i.TotalUnidadesTransporteOrigem
		,r.TotalPacotesOrigem = i.TotalPacotesOrigem
		,r.TotalPacotesAcumuladosOrigem = i.TotalPacotesAcumuladosOrigem
		,r.IdParadaDestino = i.IdParadaDestino
		,r.StatusParadaDestino = i.StatusParadaDestino
		,r.TipoParadaDestino = i.TipoParadaDestino
		,r.NomeServiceCenterDestino = i.NomeServiceCenterDestino
		,r.ServiceCenterDestino = i.ServiceCenterDestino
		,r.DataInicioEsperadaDestino = i.DataInicioEsperadaDestino
		,r.DataFinalizacaoEsperadaDestino = i.DataFinalizacaoEsperadaDestino
		,r.FonteInicioDestino = i.FonteInicioDestino
		,r.FonteFinalizacaoDestino = i.FonteFinalizacaoDestino
		,r.EtaDestino = i.EtaDestino
		,r.AtaDestino = i.AtaDestino
		,r.EtdDestino = i.EtdDestino
		,r.AtdDestino = i.AtdDestino
		,r.IdCargaDestino = i.IdCargaDestino
		,r.TotalUnidadesTransporteDestino = i.TotalUnidadesTransporteDestino
		,r.TotalPacotesDestino = i.TotalPacotesDestino
		,r.TotalPacotesAcumuladosDestino = i.TotalPacotesAcumuladosDestino
		,r.DataHoraColeta = i.DataHoraColeta
		,r.DataAtualizacao = i.DataAtualizacao
		,r.Excluido = i.Excluido

	when not matched by target then 
	insert (
			IdRota
			,IdTransportadora
			,DataReferencia
			,RosteringId
			,CodigoRota
			,DataPartidaEsperada
			,DataFinalizacao
			,Status
			,SubStatus
			,StatusGeral
			,SubstatusGeral
			,SecaoRota
			,IdMotorista
			,NomeMotorista
			,SequenciaMotorista
			,IdVeiculo
			,Placa
			,TipoVeiculo
			,IdVeiculo1
			,PlacaVeiculo1
			,TracaoVeiculo1
			,IdVeiculo2
			,PlacaVeiculo2
			,TracaoVeiculo2
			,QuantidadeTotalRotas
			,IdParadaOrigem
			,StatusParadaOrigem
			,TipoParadaOrigem
			,NomeServiceCenterOrigem
			,ServiceCenterOrigem
			,DataInicioEsperadaOrigem
			,DataFinalizacaoEsperadaOrigem
			,FonteInicioOrigem
			,FonteFinalizacaoOrigem
			,EtaOrigem
			,AtaOrigem
			,EtdOrigem
			,AtdOrigem
			,IdCargaOrigem
			,TotalUnidadesTransporteOrigem
			,TotalPacotesOrigem
			,TotalPacotesAcumuladosOrigem
			,IdParadaDestino
			,StatusParadaDestino
			,TipoParadaDestino
			,NomeServiceCenterDestino
			,ServiceCenterDestino
			,DataInicioEsperadaDestino
			,DataFinalizacaoEsperadaDestino
			,FonteInicioDestino
			,FonteFinalizacaoDestino
			,EtaDestino
			,AtaDestino
			,EtdDestino
			,AtdDestino
			,IdCargaDestino
			,TotalUnidadesTransporteDestino
			,TotalPacotesDestino
			,TotalPacotesAcumuladosDestino
			,DataHoraColeta
			,DataAtualizacao
			,Excluido
	)
	values (
		i.IdRota
		,i.IdTransportadora
		,i.DataReferencia
		,i.RosteringId
		,i.CodigoRota
		,i.DataPartidaEsperada
		,i.DataFinalizacao
		,i.Status
		,i.SubStatus
		,i.StatusGeral
		,i.SubstatusGeral
		,i.SecaoRota
		,i.IdMotorista
		,i.NomeMotorista
		,i.SequenciaMotorista
		,i.IdVeiculo
		,i.Placa
		,i.TipoVeiculo
		,i.IdVeiculo1
		,i.PlacaVeiculo1
		,i.TracaoVeiculo1
		,i.IdVeiculo2
		,i.PlacaVeiculo2
		,i.TracaoVeiculo2
		,i.QuantidadeTotalRotas
		,i.IdParadaOrigem
		,i.StatusParadaOrigem
		,i.TipoParadaOrigem
		,i.NomeServiceCenterOrigem
		,i.ServiceCenterOrigem
		,i.DataInicioEsperadaOrigem
		,i.DataFinalizacaoEsperadaOrigem
		,i.FonteInicioOrigem
		,i.FonteFinalizacaoOrigem
		,i.EtaOrigem
		,i.AtaOrigem
		,i.EtdOrigem
		,i.AtdOrigem
		,i.IdCargaOrigem
		,i.TotalUnidadesTransporteOrigem
		,i.TotalPacotesOrigem
		,i.TotalPacotesAcumuladosOrigem
		,i.IdParadaDestino
		,i.StatusParadaDestino
		,i.TipoParadaDestino
		,i.NomeServiceCenterDestino
		,i.ServiceCenterDestino
		,i.DataInicioEsperadaDestino
		,i.DataFinalizacaoEsperadaDestino
		,i.FonteInicioDestino
		,i.FonteFinalizacaoDestino
		,i.EtaDestino
		,i.AtaDestino
		,i.EtdDestino
		,i.AtdDestino
		,i.IdCargaDestino
		,i.TotalUnidadesTransporteDestino
		,i.TotalPacotesDestino
		,i.TotalPacotesAcumuladosDestino
		,i.DataHoraColeta
		,i.DataAtualizacao
		,i.Excluido
	);
	
end

GO
