-- ============================================================
-- BASELINE: dbo.UspMLFMLoadRotasHistorico
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLFMLoadRotasHistorico]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLFMLoadRotasHistorico] (
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
	-- 	dac_cd_coleta = 72620174


	-- **************** ATUALIZA A ROTA ****************
	drop table if exists #rotas
	select
		IdRota
		,@IdTransportadora IdTransportadora
		,cast(@DataReferencia as date) DataReferencia
		,ISNULL(NomeRota,0) as NomeRota
		,TipoRota
		,Tipo
		,OrigemSaida
		,NomeOrigemSaida
		,QuantidadeParadas
		,QuantidadeParadasComSucesso
		,QuantidadeParadasComFalha
		,QuantidadeParadasComProblema
		,QuantidadeParadasParcialmenteColetadas
		,0 PorcentagemParadas --cast(cast(replace(PorcentagemParadas,',','.') as decimal(5,2)) / 100.00 as decimal(5,4)) PorcentagemParadas
		,QuantidadePacotesEstimados
		,QuantidadePacotesColetados
		,QuantidadePacotesPreparados
		,Status
		,NomeVeiculo
		,TipoVeiculo
		,0 IdTipoVeiculo
		,PlacaVeiculo
		,0 CapacidadeVeiculo --ISNULL(CapacidadeVeiculo,0) CapacidadeVeiculo
		,IdMotorista 
		,NomeMotorista
		,0 DiaAtual
		,ColetadoParcialmente
		,0 Perfomance --cast(cast(replace(Perfomance,',','.') as decimal(5,2)) / 100.00 as decimal(5,4)) Perfomance
		,0 ChegouNaInstalacao
		,0 IniciouEntrada
		,0 CaminhoParaInstalacao
		,case when DataConclusao > 0 then dateadd(second,((cast(DataConclusao as bigint))) - 10800,'1970-01-01') else cast(null as datetime) end DataConclusao
		,dateadd(second,((cast(DataInicio as bigint))) - 10800,'1970-01-01') DataInicio
		,null VolumeCarregado --cast(replace(VolumeCarregado,',','.') as decimal(5,2)) VolumeCarregado
		,@DataColeta DataHoraColeta
		,getdate() DataAtualizacao
		,0 Excluido
		into #rotas
	from
		OPENJSON (@JSON)
	with
	(
		IdRota int '$.id' 
		,NomeRota varchar(60) '$.routeName' 
		,TipoRota varchar(30) '$.routeType' 
		,Tipo varchar(30) '$.type' 
		,OrigemSaida varchar(60) '$.facilityId'
		,NomeOrigemSaida varchar(60) '$.facilityName'
		,QuantidadeParadas int '$.totalStops'
		,QuantidadeParadasComSucesso int '$.successfulStops'
		,QuantidadeParadasComFalha int '$.failedStops'
		,QuantidadeParadasComProblema int '$.withProblemStops'
		,QuantidadeParadasParcialmenteColetadas int '$.partiallyCollectedStops'
		--,PorcentagemParadas varchar(50) '$.stopsPercentage'
		,QuantidadePacotesEstimados int '$.estimatedPackages'
		,QuantidadePacotesColetados int '$.collectedPackages'
		,QuantidadePacotesPreparados int '$.preparedPackages'
		,Status varchar(60) '$.status'
		,NomeVeiculo varchar(10) '$.vehicleName'
		,TipoVeiculo varchar(60) '$.vehicleType'
		--,IdTipoVeiculo int '$.vehicleTypeID'
		,PlacaVeiculo varchar(60) '$.vehicleName' --considera a placa a mesma informação que vem como Nome veiculo
		--,CapacidadeVeiculo int '$.vehicleCapacity'
		,IdMotorista int '$.driverId'
		,NomeMotorista varchar(60) '$.driverName'
		--,NomeTransportadora varchar(60) '$.carrierName'
		--,DiaAtual bit '$.currentDay'
		,ColetadoParcialmente bit '$.isPartiallyCollected'
		--,Perfomance varchar(50) '$.performance'
		--,ChegouNaInstalacao bit '$.arrivedAtFacility'
		--,IniciouEntrada bit '$.inboundStarted'
		--,CaminhoParaInstalacao bit '$.wayToFacility'
		,DataConclusao int '$.finishTime'
		--,VolumeCarregado varchar(50) '$.loadedVolume'
		,DataInicio int '$.startTime'
	)


	update
		r
	set 
		datareferencia = CASE
							WHEN p.prm_ds_valor = 1159 THEN DataInicio
							WHEN isnull(p.prm_ds_valor,1162) = 1162 THEN CASE WHEN DataConclusao is null THEN r.DataReferencia ELSE DataConclusao END
						END
	from 
		#rotas r
		left join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_logistics and c.cli_id_logistics <> 7
		left join tb_parametros p with(nolock) on p.prm_cod_cliente = c.cli_cd_codigo_cliente and p.prm_nm_parametro = 'Data do Monitoramento FM'
	 
	
	merge tb_ml_fm_rotas as r
	using #rotas as i ON r.IdRota = i.IdRota and r.IdTransportadora = i.IdTransportadora 
	--and r.DataReferencia = i.DataReferencia

WHEN MATCHED
AND EXISTS (
    SELECT
        ISNULL(i.Status,'')                               AS Status,
        ISNULL(i.DataInicio,'19000101')                   AS DataInicio,
        ISNULL(i.DataConclusao,'19000101')                AS DataConclusao,
        ISNULL(i.QuantidadeParadasComSucesso,0)           AS QtdSucesso,
        ISNULL(i.QuantidadeParadasComFalha,0)             AS QtdFalha,
        ISNULL(i.QuantidadeParadasComProblema,0)          AS QtdProblema,
        ISNULL(i.QuantidadeParadasParcialmenteColetadas,0)AS QtdParcial,
        ISNULL(i.QuantidadePacotesColetados,0)            AS PacotesColetados
    EXCEPT
    SELECT
        ISNULL(r.Status,''),
        ISNULL(r.DataInicio,'19000101'),
        ISNULL(r.DataConclusao,'19000101'),
        ISNULL(r.QuantidadeParadasComSucesso,0),
        ISNULL(r.QuantidadeParadasComFalha,0),
        ISNULL(r.QuantidadeParadasComProblema,0),
        ISNULL(r.QuantidadeParadasParcialmenteColetadas,0),
        ISNULL(r.QuantidadePacotesColetados,0)
)


then
	update set
	--	r.DataReferencia = i.DataReferencia
		r.NomeRota = i.NomeRota
		,r.TipoRota = i.TipoRota
		,r.Tipo = i.Tipo
		,r.OrigemSaida = i.OrigemSaida
		,r.NomeOrigemSaida = i.NomeOrigemSaida
		,r.QuantidadeParadas = i.QuantidadeParadas
		,r.QuantidadeParadasComSucesso = i.QuantidadeParadasComSucesso
		,r.QuantidadeParadasComFalha = i.QuantidadeParadasComFalha
		,r.QuantidadeParadasComProblema = i.QuantidadeParadasComProblema
		,r.QuantidadeParadasParcialmenteColetadas = i.QuantidadeParadasParcialmenteColetadas
		--,r.PorcentagemParadas = i.PorcentagemParadas
		,r.QuantidadePacotesEstimados = i.QuantidadePacotesEstimados
		,r.QuantidadePacotesColetados = i.QuantidadePacotesColetados
		,r.QuantidadePacotesPreparados = i.QuantidadePacotesPreparados
		,r.Status = i.Status
		,r.NomeVeiculo = i.NomeVeiculo
		,r.TipoVeiculo = i.TipoVeiculo
		--,r.IdTipoVeiculo = i.IdTipoVeiculo
		,r.PlacaVeiculo = i.PlacaVeiculo
		--,r.CapacidadeVeiculo = i.CapacidadeVeiculo
		,r.IdMotorista = i.IdMotorista
		,r.NomeMotorista = i.NomeMotorista
		--,r.DiaAtual = i.DiaAtual
		,r.ColetadoParcialmente = i.ColetadoParcialmente
		--,r.Perfomance = i.Perfomance
		--,r.ChegouNaInstalacao = i.ChegouNaInstalacao
		--,r.IniciouEntrada = i.IniciouEntrada
		--,r.CaminhoParaInstalacao = i.CaminhoParaInstalacao
		,r.DataConclusao = i.DataConclusao
		,r.DataInicio = i.DataInicio
		--,r.VolumeCarregado = i.VolumeCarregado
		,r.DataHoraColeta = i.DataHoraColeta
		,r.DataAtualizacao = i.DataAtualizacao
		,r.Excluido = i.Excluido

	when not matched by target then 
	insert (
			IdRota
			,IdTransportadora
			,DataReferencia
			,NomeRota
			,TipoRota
			,Tipo
			,OrigemSaida
			,NomeOrigemSaida
			,QuantidadeParadas
			,QuantidadeParadasComSucesso
			,QuantidadeParadasComFalha
			,QuantidadeParadasComProblema
			,QuantidadeParadasParcialmenteColetadas
			,PorcentagemParadas
			,QuantidadePacotesEstimados
			,QuantidadePacotesColetados
			,QuantidadePacotesPreparados
			,Status
			,NomeVeiculo
			,TipoVeiculo
			,IdTipoVeiculo
			,PlacaVeiculo
			,CapacidadeVeiculo
			,IdMotorista
			,NomeMotorista
			,DiaAtual
			,ColetadoParcialmente
			,Perfomance
			,ChegouNaInstalacao
			,IniciouEntrada
			,CaminhoParaInstalacao
			,DataConclusao
			,DataInicio
			,VolumeCarregado
			,DataHoraColeta
			,DataAtualizacao
			,Excluido
	)
	values (
		i.IdRota
		,i.IdTransportadora
		,i.DataReferencia
		,i.NomeRota
		,i.TipoRota
		,i.Tipo
		,i.OrigemSaida
		,i.NomeOrigemSaida
		,i.QuantidadeParadas
		,i.QuantidadeParadasComSucesso
		,i.QuantidadeParadasComFalha
		,i.QuantidadeParadasComProblema
		,i.QuantidadeParadasParcialmenteColetadas
		--,i.PorcentagemParadas
		,i.QuantidadePacotesEstimados
		,i.QuantidadePacotesColetados
		,i.QuantidadePacotesPreparados
		,i.Status
		,i.NomeVeiculo
		,i.TipoVeiculo
		,i.IdTipoVeiculo
		,i.PlacaVeiculo
		,i.CapacidadeVeiculo
		,i.IdMotorista
		,i.NomeMotorista
		,i.DiaAtual
		,i.ColetadoParcialmente
		,i.Perfomance
		,i.ChegouNaInstalacao
		,i.IniciouEntrada
		,i.CaminhoParaInstalacao
		,i.DataConclusao
		,i.DataInicio
		,i.VolumeCarregado
		,i.DataHoraColeta
		,i.DataAtualizacao
		,i.Excluido
	);


	-- **************** ATUALIZA AS PARADAS ****************
	DECLARE @IdRota int = (SELECT IdRota FROM OPENJSON (@JSON) WITH (IdRota int  '$.id'	))

	DECLARE @JsonStops nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'stops') --line_hauls_by_id
	
	drop table if exists #paradas
	select 
		@IdRota IdRota
		,@IdTransportadora IdTransportadora
		,cast(@DataReferencia as date) DataReferencia
		,IdParada 
		,ISNULL(IdVendedor,0) AS IdVendedor
		,Vendedor
		,Agente
		,VendedorTop
		,ISNULL(Ordem, 0) AS Ordem
		,Status
		,Tipo
		,dateadd(second,((cast(DataHoraInicio as bigint))) - 10800,'1970-01-01') DataHoraInicio
		,case when DataHoraFim > 0 then dateadd(second,((cast(DataHoraFim as bigint))) - 10800,'1970-01-01') else cast(null as datetime) end DataHoraFim
		,dateadd(second,((cast(TempoColeta as bigint))) - 10800,'1970-01-01') TempoColeta
		,dateadd(second,((cast(TempoInicioMilkrun as bigint))) - 10800,'1970-01-01') TempoInicioMilkrun
		,dateadd(second,((cast(TempoFimMilkrun as bigint))) - 10800,'1970-01-01') TempoFimMilkrun
		,QuantidadePacotesEstimados
		,QuantidadePacotesColetados
		,QuantidadePacotesPreparados
		,QuantidadePacotesFalhos
		,StatusTempo
		,TipoIncidente
		,Retentativa
		,ColetaParcial
		,EtaEstimado
		,RetiradaForaDoIntervalo
		,Endereco
		,NomeRua
		,NumeroRua
		,Referencia
		,Bairro
		,Cidade
		,Estado
		,CEP
		,cast(Latitude as decimal(18,8)) Latitude
		,cast(Longitude as decimal(18,8)) Longitude
		,Precisao
		,cast(LatitudePlanejada as decimal(18,8)) LatitudePlanejada
		,cast(LongitudePlanejada as decimal(18,8)) LongitudePlanejada
		,PrecisaoPlanejada
		,TipoGeolocalizacaoPlanejada
		,cast(LatitudePlanejadaLocalizacao as decimal(18,8)) LatitudePlanejadaLocalizacao
		,cast(LongitudePlanejadaLocalizacao as decimal(18,8)) LongitudePlanejadaLocalizacao
		,ForaDoIntervaloGeolocalizacaoPlanejada
		,cast(DistanciaForaIntervaloGeolocalizacaoPlanejada as decimal(18,8)) DistanciaForaIntervaloGeolocalizacaoPlanejada
		,TipoGeolocalizacaoForaIntervalo
		,cast(LatitudeGPS as decimal(18,8)) LatitudeGPS
		,cast(LongitudeGPS as decimal(18,8)) LongitudeGPS
		,@DataColeta DataHoraColeta
		,getdate() DataAtualizacao
		,0 Excluido
		into #paradas
	from 
		OPENJSON (@JsonStops)
	with
	(
		IdParada bigint '$.id' 
		,IdVendedor varchar(60) '$.sellerId'
		,Vendedor varchar(60) '$.sellerNickname'
		,TelefoneVendedor varchar(60) '$.sellerPhone' --precisa achar algum json que contenha
		,Agente bit '$.isAgent'
		,VendedorTop bit '$.isTopSeller'
		,Ordem int '$.order'
		,Status varchar(60) '$.status'
		,Tipo varchar(60) '$.type'
		,DataHoraInicio bigint '$.timeFrom'
		,DataHoraFim bigint '$.timeTo'
		,TempoColeta bigint '$.collectedTime'
		,TempoInicioMilkrun bigint '$.startMilkrunTime'
		,TempoFimMilkrun bigint '$.finishMilkrunTime'
		,QuantidadePacotesEstimados int '$.estimatedPackages'
		,QuantidadePacotesColetados int '$.collectedPackages'
		,QuantidadePacotesPreparados int '$.preparedPackages'
		,QuantidadePacotesFalhos int '$.failedPackages'
		,StatusTempo varchar(60) '$.timeStatus'
		,TipoIncidente varchar(60) '$.incidentType'
		,Retentativa bit '$.retry'
		,ColetaParcial bit '$.etaEstimated'
		,EtaEstimado bit '$.etaEstimated'
		,RetiradaForaDoIntervalo bit '$.pickedUpOutOfRange'
		--,StatusToc varchar(60) '$.statusId' --precisa achar algum json que contenha
		--,CasoToc varchar(60) '$.caseId' --precisa achar algum json que contenha
		,Endereco varchar(100) '$.address.address_line'
		,NomeRua varchar(100) '$.address.street_name'
		,NumeroRua varchar(30) '$.address.street_number'
		,Referencia varchar(100) '$.address.comment'
		,Bairro varchar(60) '$.address.neighborhood'
		,Cidade varchar(60) '$.address.city'
		,Estado varchar(60) '$.address.state'
		,CEP varchar(10) '$.address.zip_code'
		,Latitude varchar(20) '$.location.lat'
		,Longitude varchar(20) '$.location.lng'
		,Precisao varchar(60) '$.location.precision'
		,LatitudePlanejada varchar(20) '$.plannedLocation.lat'
		,LongitudePlanejada varchar(20) '$.plannedLocation.lng'
		,PrecisaoPlanejada varchar(60) '$.plannedLocation.precision'
		,TipoGeolocalizacaoPlanejada varchar(60) '$.address.planned_geolocation.type'
		,LatitudePlanejadaLocalizacao varchar(20) '$.address.planned_geolocation.latitude'
		,LongitudePlanejadaLocalizacao varchar(20) '$.address.planned_geolocation.longitude'
		,ForaDoIntervaloGeolocalizacaoPlanejada bit '$.address.planned_geolocation.out_of_range.is_out'
		,DistanciaForaIntervaloGeolocalizacaoPlanejada varchar(60) '$.address.planned_geolocation.out_of_range.distance'
		,TipoGeolocalizacaoForaIntervalo varchar(60) '$.address.planned_geolocation.out_of_range.geolocation_type'
		,LatitudeGPS varchar(20) '$.address.gps_geolocation.latitude'
		,LongitudeGPS varchar(20) '$.address.gps_geolocation.longitude'
	)


	update
		r
	set 
		DataReferencia = CASE
							WHEN p.prm_ds_valor = 1159 THEN cast(DataHoraInicio as date)
							WHEN isnull(p.prm_ds_valor,1162) = 1162 THEN CASE WHEN DataHoraFim is null THEN r.DataReferencia ELSE cast(DataHoraFim as date) END
						END
	from 
		#paradas r
		left join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_logistics and c.cli_id_logistics <> 7
		left join tb_parametros p with(nolock) on p.prm_cod_cliente = c.cli_cd_codigo_cliente and p.prm_nm_parametro = 'Data do Monitoramento FM'


	merge tb_ml_fm_paradas as r
	using #paradas as i ON r.IdRota = i.IdRota and r.IdTransportadora = i.IdTransportadora and r.IdParada = i.IdParada -- and r.DataReferencia = i.DataReferencia
	when matched then
	update set
		r.DataReferencia = i.DataReferencia
		,r.IdVendedor = i.IdVendedor
		,r.Vendedor = i.Vendedor
		,r.Agente = i.Agente
		,r.VendedorTop = i.VendedorTop
		,r.Ordem = i.Ordem
		,r.Status = i.Status
		,r.Tipo = i.Tipo
		,r.DataHoraInicio = i.DataHoraInicio
		,r.DataHoraFim = i.DataHoraFim
		,r.TempoColeta = i.TempoColeta
		,r.TempoInicioMilkrun = i.TempoInicioMilkrun
		,r.TempoFimMilkrun = i.TempoFimMilkrun
		,r.QuantidadePacotesEstimados = i.QuantidadePacotesEstimados
		,r.QuantidadePacotesColetados = i.QuantidadePacotesColetados
		,r.QuantidadePacotesPreparados = i.QuantidadePacotesPreparados
		,r.QuantidadePacotesFalhos = i.QuantidadePacotesFalhos
		,r.StatusTempo = i.StatusTempo
		,r.TipoIncidente = i.TipoIncidente
		,r.Retentativa = i.Retentativa
		,r.ColetaParcial = i.ColetaParcial
		,r.EtaEstimado = i.EtaEstimado
		,r.RetiradaForaDoIntervalo = i.RetiradaForaDoIntervalo
		,r.Endereco = i.Endereco
		,r.NomeRua = i.NomeRua
		,r.NumeroRua = i.NumeroRua
		,r.Referencia = i.Referencia
		,r.Bairro = i.Bairro
		,r.Cidade = i.Cidade
		,r.Estado = i.Estado
		,r.CEP = i.CEP
		,r.Latitude = i.Latitude
		,r.Longitude = i.Longitude
		,r.Precisao = i.Precisao
		,r.LatitudePlanejada = i.LatitudePlanejada
		,r.LongitudePlanejada = i.LongitudePlanejada
		,r.PrecisaoPlanejada = i.PrecisaoPlanejada
		,r.TipoGeolocalizacaoPlanejada = i.TipoGeolocalizacaoPlanejada
		,r.LatitudePlanejadaLocalizacao = i.LatitudePlanejadaLocalizacao
		,r.LongitudePlanejadaLocalizacao = i.LongitudePlanejadaLocalizacao
		,r.ForaDoIntervaloGeolocalizacaoPlanejada = i.ForaDoIntervaloGeolocalizacaoPlanejada
		,r.DistanciaForaIntervaloGeolocalizacaoPlanejada = i.DistanciaForaIntervaloGeolocalizacaoPlanejada
		,r.TipoGeolocalizacaoForaIntervalo = i.TipoGeolocalizacaoForaIntervalo
		,r.LatitudeGPS = i.LatitudeGPS
		,r.LongitudeGPS = i.LongitudeGPS
		,r.DataHoraColeta = i.DataHoraColeta
		,r.DataAtualizacao = i.DataAtualizacao
		,r.Excluido = i.Excluido

	when not matched by target then 
	insert (
			IdRota
			,IdTransportadora
			,DataReferencia
			,IdParada
			,IdVendedor
			,Vendedor
			,Agente
			,VendedorTop
			,Ordem
			,Status
			,Tipo
			,DataHoraInicio
			,DataHoraFim
			,TempoColeta
			,TempoInicioMilkrun
			,TempoFimMilkrun
			,QuantidadePacotesEstimados
			,QuantidadePacotesColetados
			,QuantidadePacotesPreparados
			,QuantidadePacotesFalhos
			,StatusTempo
			,TipoIncidente
			,Retentativa
			,ColetaParcial
			,EtaEstimado
			,RetiradaForaDoIntervalo
			,Endereco
			,NomeRua
			,NumeroRua
			,Referencia
			,Bairro
			,Cidade
			,Estado
			,CEP
			,Latitude
			,Longitude
			,Precisao
			,LatitudePlanejada
			,LongitudePlanejada
			,PrecisaoPlanejada
			,TipoGeolocalizacaoPlanejada
			,LatitudePlanejadaLocalizacao
			,LongitudePlanejadaLocalizacao
			,ForaDoIntervaloGeolocalizacaoPlanejada
			,DistanciaForaIntervaloGeolocalizacaoPlanejada
			,TipoGeolocalizacaoForaIntervalo
			,LatitudeGPS
			,LongitudeGPS
			,DataHoraColeta
			,DataAtualizacao
			,Excluido
	)
	values (
			i.IdRota
			,i.IdTransportadora
			,i.DataReferencia
			,i.IdParada
			,i.IdVendedor
			,i.Vendedor
			,i.Agente
			,i.VendedorTop
			,i.Ordem
			,i.Status
			,i.Tipo
			,i.DataHoraInicio
			,i.DataHoraFim
			,i.TempoColeta
			,i.TempoInicioMilkrun
			,i.TempoFimMilkrun
			,i.QuantidadePacotesEstimados
			,i.QuantidadePacotesColetados
			,i.QuantidadePacotesPreparados
			,i.QuantidadePacotesFalhos
			,i.StatusTempo
			,i.TipoIncidente
			,i.Retentativa
			,i.ColetaParcial
			,i.EtaEstimado
			,i.RetiradaForaDoIntervalo
			,i.Endereco
			,i.NomeRua
			,i.NumeroRua
			,i.Referencia
			,i.Bairro
			,i.Cidade
			,i.Estado
			,i.CEP
			,i.Latitude
			,i.Longitude
			,i.Precisao
			,i.LatitudePlanejada
			,i.LongitudePlanejada
			,i.PrecisaoPlanejada
			,i.TipoGeolocalizacaoPlanejada
			,i.LatitudePlanejadaLocalizacao
			,i.LongitudePlanejadaLocalizacao
			,i.ForaDoIntervaloGeolocalizacaoPlanejada
			,i.DistanciaForaIntervaloGeolocalizacaoPlanejada
			,i.TipoGeolocalizacaoForaIntervalo
			,i.LatitudeGPS
			,i.LongitudeGPS
			,i.DataHoraColeta
			,i.DataAtualizacao
			,i.Excluido
	);

	
end

GO
