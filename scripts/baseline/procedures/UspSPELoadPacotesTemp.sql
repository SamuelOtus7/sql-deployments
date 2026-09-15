-- ============================================================
-- BASELINE: dbo.UspSPELoadPacotesTemp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadPacotesTemp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPELoadPacotesTemp] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@IdStations int,
	@DataColeta datetime,
	@DataReferencia date
)
as
begin
	
	SET NOCOUNT ON;

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'fleet_order_list')
	
	drop table if exists #pacotes
	create table #pacotes(
		IdRota varchar(30) not null,
		CodigoPacote varchar(30) not null,
		IdTransportadora int not null,
		IdStation int null,
		DataReferencia date not null,
		DataHoraColeta datetime not null,
		DataHoraEntrega datetime not null,
		StatusEntrega varchar(50) null,
		IdMotorista int null,
		NomeMotorista varchar(100) not null,
		DataAtualizacao datetime null
	)

	INSERT INTO #pacotes
	SELECT 
		IdRota
		,CodigoPacote
		,@IdTransportadora IdTransportadora
		,@IdStations IdStation
		,@DataReferencia DataReferencia
		,@DataColeta DataHoraColeta
		,dateadd(second,((cast(case when DataHoraEntrega = 0 or DataHoraEntrega is null then DataHoraEntrega2 else DataHoraEntrega end as bigint))) - 10800,'1970-01-01') DataHoraEntrega
		,StatusEntrega
		,IdMotorista
		,NomeMotorista
		,getdate()
	FROM 
		OPENJSON (@JsonList)
	WITH 
		(
			IdRota varchar(30) '$.receive_task_id'
			,CodigoPacote varchar(30) '$.shipment_id'
			,DataHoraEntrega int '$.delivered_time'
			,DataHoraEntrega2 int '$.mtime' --quando o pacote não foi entregue, usar este campo como referencia de data
			,StatusEntrega int '$.status'
			,IdMotorista int '$.driver_id'
			,NomeMotorista varchar(100) '$.driver_name'
		)


	merge tb_spe_pacotes_temp as p
	using #pacotes as i
			ON p.CodigoPacote = i.CodigoPacote and p.IdRota = i.IdRota and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia
	when matched then
	update set
		p.IdStation = i.IdStation
		,p.DataHoraColeta = i.DataHoraColeta
		,p.DataHoraEntrega = i.DataHoraEntrega
		,p.StatusEntrega = i.StatusEntrega
		,p.IdMotorista = i.IdMotorista
		,p.NomeMotorista = i.NomeMotorista
		,p.DataAtualizacao = i.DataAtualizacao
	when not matched by target then 
	insert (
			IdRota
			,CodigoPacote
			,IdTransportadora
			,IdStation
			,DataReferencia
			,DataHoraColeta
			,DataHoraEntrega
			,StatusEntrega
			,IdMotorista
			,NomeMotorista
			,DataAtualizacao
	)
	values (
			i.IdRota
			,i.CodigoPacote
			,i.IdTransportadora
			,i.IdStation
			,i.DataReferencia
			,i.DataHoraColeta
			,i.DataHoraEntrega
			,i.StatusEntrega
			,i.IdMotorista
			,i.NomeMotorista
			,i.DataAtualizacao
	);
end
GO
