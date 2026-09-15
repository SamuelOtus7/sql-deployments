-- ============================================================
-- BASELINE: dbo.UspSPELoadRotasV4_Arquivo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadRotasV4_Arquivo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadRotasV4_Arquivo] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@IdStations int,
	@DataColeta datetime
)
as
begin
	
	SET NOCOUNT ON;

	--declare @JSON VARCHAR(max)
	--declare @IdTransportadora int
	--declare @IdStations int
	--declare @DataColeta datetime

	--SELECT 
	--	@JSON = dac_ds_contexto_json,
	--	@IdTransportadora = dac_cd_transportadora,
	--	@IdStations = dac_ds_contexto,
	--	@DataColeta = dac_dh_coleta
	--FROM 
	--	db_Irisys_Json.dbo.tb_dra_coleta WITH (nolock)
	--WHERE 
	--	dac_cd_coleta = 3529808

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'assignmentTasks')
	--DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'list')

	drop table if exists #rotas
	create table #rotas(
		CodigoRota varchar(30) not null,
		IdTransportadora int not null,
		DataReferencia date not null,
		DataHoraInicio date not null,
		DataHoraFim datetime null,
		DataHoraColeta datetime not null,
		IdStation int not null,
		IdMotorista int null,
		IdStatus int null
	)

	INSERT INTO #rotas
	SELECT 
		IdRota
		,@IdTransportadora IdTransportadora
		,cast(dateadd(second,((cast(DataRerencia as bigint))) - 10800,'1970-01-01') as date) DataReferencia
		,dateadd(second,((cast(DataRerencia as bigint))) - 10800,'1970-01-01') DataHoraInicio
		,case when DataHoraFim = '' or DataHoraFim = 0 then null else dateadd(second,((cast(DataHoraFim as bigint))) - 10800,'1970-01-01') end DataHoraFim
		,@DataColeta DataHoraColeta
		,@IdStations IdStation
		,IdMotorista
		,IdStatus
	FROM 
		OPENJSON (@JsonData)
	WITH 
		(
			IdRota varchar(30) '$.assignment_task_id'
			,IdMotorista int '$.driver_id'
			,DataRerencia varchar(1000) '$.assigned_time'
			,DataHoraFim varchar(1000) '$.complete_time'
			,IdStatus int '$.status'
			--,DataRerencia varchar(1000) '$.ctime'
			--,DataRerencia2 varchar(1000) '$.mtime'
			--,DataRerencia3 varchar(1000) '$.delivery_time'
			--,DataRerencia4 varchar(1000) '$.processing_time'
			--,DataRerencia5 varchar(1000) '$.assigned_time'
			--,DataRerencia6 varchar(1000) '$.processed_time'
			--,DataRerencia7 varchar(1000) '$.partially_assigned_time'
		)

		
		
	merge tb_spe_rotas_v4 as r
	using #rotas as i ON r.CodigoRota = i.CodigoRota and r.IdTransportadora = i.IdTransportadora and r.DataReferencia = i.DataReferencia
	when matched then
	update set
		r.DataHoraColeta = i.DataHoraColeta
		,r.IdStation = i.IdStation
		,r.DataHoraInicio = i.DataHoraInicio
		,r.DataHoraFim = i.DataHoraFim
		,r.DataAtualizacao = getdate()
		,r.Excluido = 0
	when not matched by target then 
	insert (
			CodigoRota
			,IdTransportadora
			,DataReferencia
			,DataHoraInicio
			,DataHoraFim
			,DataHoraColeta
			,IdStation
			,IdMotorista
			,DataAtualizacao
			,Excluido
	)
	values (
			i.CodigoRota
			,i.IdTransportadora
			,i.DataReferencia
			,i.DataHoraInicio
			,i.DataHoraFim
			,i.DataHoraColeta
			,i.IdStation
			,i.IdMotorista
			,getdate()
			,0
	);

end
GO
