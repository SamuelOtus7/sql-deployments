-- ============================================================
-- BASELINE: dbo.UspSPELoadRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadRotas] (
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
	--	@IdStations = try_cast(replace(dac_ds_contexto,'station:','') as int),
	--	@DataColeta = dac_dh_coleta
	--FROM 
	--	db_Irisys_Json.dbo.tb_dra_coleta WITH (nolock)
	--WHERE 
	--	dac_cd_coleta = 788836


	drop table if exists #rotas
	create table #rotas(
		CodigoRota varchar(30) NOT NULL,
		IdTransportadora int NOT NULL,
		DataReferencia date not null,
		DataHoraColeta datetime NOT NULL,
		IdStation int NOT NULL,
		IdMotorista int null
	)

	INSERT INTO #rotas
	SELECT 
		IdRota
		,@IdTransportadora IdTransportadora
		,cast(dateadd(second,((cast(DataRerencia as bigint))) - 10800,'1970-01-01') as date) DataReferencia
		,@DataColeta DataHoraColeta
		,@IdStations IdStation
		,IdMotorista
	FROM 
		OPENJSON (@Json)
	WITH 
		(
			IdRota varchar(30) '$.assignment_task_id'
			,IdMotorista int '$.driver_id'
			,DataRerencia varchar(1000) '$.assigned_time'
			--,DataRerencia varchar(1000) '$.ctime'
			--,DataRerencia2 varchar(1000) '$.mtime'
			--,DataRerencia3 varchar(1000) '$.delivery_time'
			--,DataRerencia4 varchar(1000) '$.processing_time'
			--,DataRerencia5 varchar(1000) '$.assigned_time'
			--,DataRerencia6 varchar(1000) '$.processed_time'
			--,DataRerencia7 varchar(1000) '$.partially_assigned_time'
		)

		
	merge tb_spe_rotas_novo as r
	using (
			select
				distinct
				CodigoRota
				,IdTransportadora
				,DataReferencia
				,DataHoraColeta
				,IdStation
				,IdMotorista
			from
				#rotas
			where
				CodigoRota <> ''
		) as i
			ON r.CodigoRota = i.CodigoRota and r.IdTransportadora = i.IdTransportadora and r.DataReferencia = i.DataReferencia
	when matched then
	update set
		r.DataHoraColeta = i.DataHoraColeta
		,r.IdStation = i.IdStation
		,r.DataAtualizacao = getdate()
		,r.Excluido = 0
	when not matched by target then 
	insert (
			CodigoRota
			,IdTransportadora
			,DataReferencia
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
			,i.DataHoraColeta
			,i.IdStation
			,i.IdMotorista
			,getdate()
			,0
	);
end
GO
