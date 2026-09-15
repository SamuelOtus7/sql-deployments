-- ============================================================
-- BASELINE: dbo.UspSPELoadPacotesReprocessar
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadPacotesReprocessar]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadPacotesReprocessar] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@CodigoPacote varchar(30)
)
as
begin
	
	SET NOCOUNT ON;

	--declare @JSON VARCHAR(max)
	--declare @IdTransportadora int
	--declare @CodigoPacote varchar(30)
	

	--select
	--	@JSON = dac_ds_contexto_json,
	--	@IdTransportadora = 2087146923,
	--  @CodigoPacote = dac_ds_contexto
	--from
	--	db_Irisys_Json.dbo.tb_dra_coleta
	--where
	--	dac_cd_coleta=113437

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'tracking')
	DECLARE @JsonList2 nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'recipient')
	

	drop table if exists #pacotes
	create table #pacotes(
		CodigoPacote varchar(30) not null,
		IdTransportadora int not null,
		DataReferencia date not null,
		DataHoraEntrega datetime not null,
		RecebidoPor varchar(60) null,
		Latitude varchar(15) null,
		Longitude varchar(15) null,
		URLImagem varchar(200) null,
		DataAtualizacao datetime null,
		ChildrenJson varchar(max) null
	)

	
	--*************** PACOTES QUE CHEGARAM NO DESTINATÁRIO ***************
	drop table if exists #pacotes_status
	select 
		[key] StatusEntrega
		,[value] PacotesJson
		into #pacotes_status
	from 
		openjson(@JsonList2)
	
	declare @station_id int = (select [value] from openjson(@JsonData) where [key]='station_id')
	declare @idRota varchar(30) = (select [value] from openjson(@JsonData) where [key]='receive_task_id')

	DECLARE @JsonStatus nvarchar(max) 
	DECLARE @StatusEntrega varchar(50)
	
	DECLARE cursor_pacotes_status CURSOR FOR select StatusEntrega, PacotesJson from #pacotes_status
	OPEN cursor_pacotes_status FETCH NEXT FROM cursor_pacotes_status INTO @StatusEntrega, @JsonStatus
	WHILE @@FETCH_STATUS = 0  
	BEGIN 
		
		declare @QtdeRegistros int = (select count(1) from openjson(@JsonStatus))
		
		--quando retorna mais de um registros é no status não possui vários pacotes
		if @QtdeRegistros > 1 
		begin
			insert into #pacotes
			select
				CodigoPacote
				,@IdTransportadora IdTransportadora
				,cast(dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') as date) DataReferencia
				,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
				,RecebidoPor
				,Latitude
				,Longitude
				,URLImagem
				,getdate() DataAtualizacao
				,null ChildrenJson
			from
				OPENJSON(@JsonStatus)
				WITH 
				(
					IdPacote int '$.id'
					,CodigoPacote varchar(30) '$.order_id'
					,DataHoraEntrega int '$.ctime'
					,IdMotorista int '$.driver_id'
					,NomeMotorista varchar(60) '$.driver_name'
					,RecebidoPor varchar(60) '$.recipient_name'
					,Latitude varchar(15) '$.geo.lat'
					,Longitude varchar(15) '$.geo.lng'
					,URLImagem varchar(200) '$.photo_list[0]'
				)
		end

		--quando retorna apenas um registro é que no status possui vários filhos
		if @QtdeRegistros = 1 
		begin
			DECLARE @JsonStatusFilhos nvarchar(max) = (select [value] from OPENJSON(@JsonStatus))
			insert into #pacotes
			select
				CodigoPacote
				,@IdTransportadora IdTransportadora
				,cast(dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') as date) DataReferencia
				,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
				,RecebidoPor
				,Latitude
				,Longitude
				,URLImagem
				,getdate() DataAtualizacao
				,null ChildrenJson
			from
				OPENJSON(@JsonStatusFilhos)
				WITH 
				(
					IdPacote int '$.id'
					,CodigoPacote varchar(30) '$.order_id'
					,DataHoraEntrega int '$.ctime'
					,IdMotorista int '$.driver_id'
					,NomeMotorista varchar(60) '$.driver_name'
					,RecebidoPor varchar(60) '$.recipient_name'
					,Latitude varchar(15) '$.geo.lat'
					,Longitude varchar(15) '$.geo.lng'
					,URLImagem varchar(200) '$.photo_list[0]'
				)
		end

	FETCH NEXT FROM cursor_pacotes_status INTO @StatusEntrega, @JsonStatus
	END   
	CLOSE cursor_pacotes_status;  
	DEALLOCATE cursor_pacotes_status;  
		

	--*************** FIM QUE CHEGARAM NO DESTINATÁRIO ***************


	--*************** PACOTES EM ROTA ***************
	--INSERT INTO #pacotes
	--SELECT 
	--	IdPacote
	--	,CodigoPacote
	--	,IdStation
	--	,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
	--	,IdStatus
	--	,'tracking' StatusEntrega
	--	,null IdMotorista
	--	,NomeMotorista
	--	,null RecebidoPor
	--	,null Latitude
	--	,null Longitude
	--	,getdate() DataAtualizacao
	--	,ChildrenJson
	--FROM 
	--	OPENJSON (@JsonList)
	--WITH 
	--	(
	--		IdPacote int '$.id'
	--		,CodigoPacote varchar(30) '$.shipment_id'
	--		,IdStation int '$.station_id'
	--		,DataHoraEntrega int '$.timestamp'
	--		,IdStatus int '$.status'
	--		,NomeMotorista varchar(60) '$.operator'
	--		,ChildrenJson nvarchar(max) '$.children' as json
	--	)
	--where
	--	IdStation <> 0
	

	--DECLARE @JsonChildren nvarchar(max) 
	--DECLARE cursor_pacotes CURSOR FOR select ChildrenJson from #pacotes
	--OPEN cursor_pacotes FETCH NEXT FROM cursor_pacotes INTO @JsonChildren
	--WHILE @@FETCH_STATUS = 0  
	--BEGIN 
		
	--	INSERT INTO #pacotes
	--	SELECT 
	--		IdPacote
	--		,CodigoPacote
	--		,IdStation
	--		,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
	--		,IdStatus
	--		,'tracking' StatusEntrega
	--		,null IdMotorista
	--		,NomeMotorista
	--		,null RecebidoPor
	--		,null Latidude
	--		,null Longitude
	--		,getdate() DataAtualizacao
	--		,ChildrenJson
	--	FROM 
	--		OPENJSON (@JsonChildren)
	--	WITH 
	--		(
	--			IdPacote int '$.id'
	--			,CodigoPacote varchar(30) '$.shipment_id'
	--			,IdStation int '$.station_id'
	--			,DataHoraEntrega int '$.timestamp'
	--			,IdStatus int '$.status'
	--			,NomeMotorista varchar(60) '$.operator'
	--			,ChildrenJson nvarchar(max) '$.children' as json
	--		)

	--FETCH NEXT FROM cursor_pacotes INTO @JsonChildren
	--END   
	--CLOSE cursor_pacotes;  
	--DEALLOCATE cursor_pacotes;  
	--*************** FIM PACOTES EM ROTA ***************

	update
		p
	set
		p.RecebidoPor = i.RecebidoPor
		,p.Latitude = i.Latitude
		,p.Longitude = i.Longitude
		,p.URLImagem = i.URLImagem
		,p.DataAtualizacaoDetalhe = i.DataAtualizacao
		,p.DataHoraEntrega = i.DataHoraEntrega
	from
		tb_spe_pacotes_novo p
		join #pacotes i ON p.CodigoPacote = i.CodigoPacote and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia


	update
		p
	set
		p.RecebidoPor = i.RecebidoPor
		,p.Latitude = i.Latitude
		,p.Longitude = i.Longitude
		,p.URLImagem = i.URLImagem
		,p.DataAtualizacao = i.DataAtualizacao
	from
		tb_spe_pacotes p
		join #pacotes i ON p.CodigoPacote = i.CodigoPacote and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia

	

end
GO
