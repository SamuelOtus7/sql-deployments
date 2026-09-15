-- ============================================================
-- BASELINE: dbo.UspMLFMLoadRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLFMLoadRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLFMLoadRotas] (
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
	-- 	dac_cd_coleta = 50249858
	
	DECLARE @JsonRoutes nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'routes')
	
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
		,cast(cast(replace(PorcentagemParadas,',','.') as decimal(5,2)) / 100.00 as decimal(5,4)) PorcentagemParadas
		,QuantidadePacotesEstimados
		,QuantidadePacotesColetados
		,QuantidadePacotesPreparados
		,Status
		,NomeVeiculo
		,TipoVeiculo
		,IdTipoVeiculo
		,PlacaVeiculo
		,ISNULL(CapacidadeVeiculo,0) CapacidadeVeiculo
		,IdMotorista 
		,NomeMotorista
		,DiaAtual
		,ColetadoParcialmente
		,cast(cast(replace(Perfomance,',','.') as decimal(5,2)) / 100.00 as decimal(5,4)) Perfomance
		,ChegouNaInstalacao
		,IniciouEntrada
		,CaminhoParaInstalacao
		,case when DataConclusao > 0 then dateadd(second,((cast(DataConclusao as bigint))) - 10800,'1970-01-01') else cast(null as datetime) end DataConclusao
		,case when DataInicio > 0 then dateadd(second,((cast(DataInicio as bigint))) - 10800,'1970-01-01') else cast(null as datetime) end DataInicio
		,cast(replace(VolumeCarregado,',','.') as decimal(5,2)) VolumeCarregado
		,@DataColeta DataHoraColeta
		,getdate() DataAtualizacao
		,0 Excluido
		into #rotas
	from
		OPENJSON (@JsonRoutes)
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
		,PorcentagemParadas varchar(50) '$.stopsPercentage'
		,QuantidadePacotesEstimados int '$.estimatedPackages'
		,QuantidadePacotesColetados int '$.collectedPackages'
		,QuantidadePacotesPreparados int '$.preparedPackages'
		,Status varchar(60) '$.status'
		,NomeVeiculo varchar(10) '$.vehicleName'
		,TipoVeiculo varchar(60) '$.vehicleType'
		,IdTipoVeiculo int '$.vehicleTypeID'
		,PlacaVeiculo varchar(60) '$.vehicleLicensePlate'
		,CapacidadeVeiculo int '$.vehicleCapacity'
		,IdMotorista int '$.driverId'
		,NomeMotorista varchar(60) '$.driverName'
		--,NomeTransportadora varchar(60) '$.carrierName'
		,DiaAtual bit '$.currentDay'
		,ColetadoParcialmente bit '$.isPartiallyCollected'
		,Perfomance varchar(50) '$.performance'
		,ChegouNaInstalacao bit '$.arrivedAtFacility'
		,IniciouEntrada bit '$.inboundStarted'
		,CaminhoParaInstalacao bit '$.wayToFacility'
		,DataConclusao int '$.finishDate'
		,VolumeCarregado varchar(50) '$.loadedVolume'
		,DataInicio int '$.initDate'
	)


	update
		r
	set 
		datareferencia = CASE
							WHEN p.prm_ds_valor = 1159 THEN CASE WHEN DataInicio is null THEN r.DataReferencia ELSE DataInicio END 
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
	then
	update set
		r.DataReferencia = i.DataReferencia,
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
		,r.PorcentagemParadas = i.PorcentagemParadas
		,r.QuantidadePacotesEstimados = i.QuantidadePacotesEstimados
		,r.QuantidadePacotesColetados = i.QuantidadePacotesColetados
		,r.QuantidadePacotesPreparados = i.QuantidadePacotesPreparados
		,r.Status = i.Status
		,r.NomeVeiculo = i.NomeVeiculo
		,r.TipoVeiculo = i.TipoVeiculo
		,r.IdTipoVeiculo = i.IdTipoVeiculo
		,r.PlacaVeiculo = i.PlacaVeiculo
		,r.CapacidadeVeiculo = i.CapacidadeVeiculo
		,r.IdMotorista = i.IdMotorista
		,r.NomeMotorista = i.NomeMotorista
		,r.DiaAtual = i.DiaAtual
		,r.ColetadoParcialmente = i.ColetadoParcialmente
		,r.Perfomance = i.Perfomance
		,r.ChegouNaInstalacao = i.ChegouNaInstalacao
		,r.IniciouEntrada = i.IniciouEntrada
		,r.CaminhoParaInstalacao = i.CaminhoParaInstalacao
		,r.DataConclusao = i.DataConclusao
		,r.DataInicio = i.DataInicio
		,r.VolumeCarregado = i.VolumeCarregado
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
		,i.PorcentagemParadas
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
	
end
GO
