-- ============================================================
-- BASELINE: dbo.UspSPELoadPacotesDetalhes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadPacotesDetalhes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadPacotesDetalhes] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@CodigoPacote varchar(30),
	@DataReferencia date
)
as
begin
	
	SET NOCOUNT ON;

	--declare @JSON VARCHAR(max)
	--declare @IdTransportadora int
	--declare @CodigoPacote varchar(30)
	--declare @DataReferencia date
	

	--select
	--	@JSON = dac_ds_contexto_json,
	--	@IdTransportadora = dac_cd_transportadora,
	--	@CodigoPacote = dac_ds_contexto,
	--	@DataReferencia = dac_dh_referencia
	--from
	--	db_Irisys_Json.dbo.tb_dra_coleta
	--where
	--	dac_cd_coleta=14455814

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'tracking')
	DECLARE @JsonList2 nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'recipient')
	DECLARE @JsonStatusPacote nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'status')
	
	drop table if exists #pacotes
	create table #pacotes(
		CodigoPacote varchar(30) not null,
		IdTransportadora int not null,
		DataReferencia date not null,
		DataHoraEntrega datetime not null,
		StatusEntrega varchar(50) null,
		RecebidoPor varchar(60) null,
		IdMotorista int null,
		Latitude varchar(15) null,
		Longitude varchar(15) null,
		URLImagem varchar(200) null,
		DataAtualizacao datetime null,
		ChildrenJson varchar(max) null,
		StatusPacote int null
	)

	
	--*************** PACOTES QUE CHEGARAM NO DESTINATÁRIO ***************
	drop table if exists #pacotes_status
	select 
		[key] StatusEntrega
		,[value] PacotesJson
		,@JsonStatusPacote as StatusPacote
		into #pacotes_status
	from 
		openjson(@JsonList2)


	
	declare @station_id int = (select [value] from openjson(@JsonData) where [key]='station_id')
	declare @idRota varchar(30) = (select [value] from openjson(@JsonData) where [key]='receive_task_id')

	DECLARE @JsonStatus nvarchar(max) 
	DECLARE @StatusEntrega varchar(50)
	DECLARE @StatusPacote int

	
	DECLARE cursor_pacotes_status CURSOR FOR select StatusEntrega, PacotesJson,StatusPacote from #pacotes_status
	OPEN cursor_pacotes_status FETCH NEXT FROM cursor_pacotes_status INTO @StatusEntrega, @JsonStatus, @StatusPacote
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
				,@StatusEntrega
				,RecebidoPor
				,IdMotorista
				,Latitude
				,Longitude
				,URLImagem
				,getdate() DataAtualizacao
				,null ChildrenJson
				,@StatusPacote
				
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
				,@StatusEntrega
				,RecebidoPor
				,IdMotorista
				,Latitude
				,Longitude
				,URLImagem
				,getdate() DataAtualizacao
				,null ChildrenJson
				,@StatusPacote
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

	FETCH NEXT FROM cursor_pacotes_status INTO @StatusEntrega, @JsonStatus, @StatusPacote
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
		p.RecebidoPor				= i.RecebidoPor
		,p.Latitude					= i.Latitude
		,p.Longitude				= i.Longitude
		,p.URLImagem				= i.URLImagem
		,p.DataAtualizacaoDetalhe	= i.DataAtualizacao
		,p.DataHoraEntrega			= i.DataHoraEntrega
		,p.StatusEntrega			= i.StatusEntrega
		,p.StatusPacote				= sts.stp_descricao

	from
		tb_spe_pacotes_v4 p with(nolock)
		join #pacotes i ON p.CodigoPacote = i.CodigoPacote and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia
		join tb_spe_status_pacote as sts on i.StatusPacote = sts.stp_json_codigo


	--CRIADO EM 27/09/2023 para incluir pacotes em que não foi coletado nenhuma rota em que a data de referencia seja a mesma data em que foi entregue
	drop table if exists #pacote_semrota
	select
		i.*
		into #pacote_semrota
	from
		#pacotes i 
		left join tb_spe_pacotes_v4 p with(nolock) ON p.CodigoPacote = i.CodigoPacote and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia
	where
		p.Id is null
		and i.DataHoraEntrega = (
			select
				max(DataHoraEntrega)
			from
				#pacotes i2
			where
				i.CodigoPacote = i2.CodigoPacote
		)

	
	drop table if exists #pacote_incluirotas
	select
		distinct
		p.*
		,rotas.CodigoRota
		,rotas.IdStation
		into #pacote_incluirotas
	from
		#pacote_semrota p
		left join tb_spe_pacotes_v4 pacotes with(nolock) on p.CodigoPacote = pacotes.CodigoPacote
												and p.IdTransportadora = pacotes.IdTransportadora
												and pacotes.Excluido = 0
												and pacotes.DataReferencia = (
													select
														max(DataReferencia)
													from
														tb_spe_pacotes_v4 aux with(nolock)
													where
														pacotes.CodigoPacote = aux.CodigoPacote
														and pacotes.IdTransportadora = aux.IdTransportadora
														and aux.Excluido = 0
												)
		left join tb_spe_rotas_v4 rotas with(nolock) on pacotes.CodigoRota = rotas.CodigoRota
												and pacotes.IdTransportadora = rotas.IdTransportadora
												and rotas.Excluido = 0
												and rotas.IdMotorista = p.IdMotorista


	
	insert into tb_spe_rotas_v4 (CodigoRota, IdTransportadora, DataReferencia, DataHoraInicio, IdStation, IdMotorista, DataAtualizacao, Excluido)
	select
		distinct
		CodigoRota
		,IdTransportadora
		,cast(DataHoraEntrega as date) DataReferencia
		,DataHoraEntrega DataHoraInicio
		,IdStation
		,IdMotorista
		,getdate() DataAtualizacao
		,0 Excluido
	from
		#pacote_incluirotas p
	where
		CodigoRota is not null
		and not exists (select 
							1 
						from 
							tb_spe_rotas_v4 r with(nolock) 
						where 
							p.CodigoRota = r.CodigoRota
							and p.IdTransportadora = r.IdTransportadora
							and cast(p.DataHoraEntrega as date) = p.DataReferencia
						)


	--insert into tb_spe_rotas_v4 (CodigoRota, IdTransportadora, DataReferencia, DataHoraInicio, IdStation, IdMotorista, DataAtualizacao, Excluido)
	--select
	--	rotas.CodigoRota
	--	,rotas.IdTransportadora
	--	,rotas.DataReferencia
	--	,rotas.DataHoraInicio
	--	,rotas.IdStation
	--	,rotas.IdMotorista
	--	,getdate() DataAtualizacao
	--	,0 Excluido
	--from
	--	#pacote_semrota p
	--	join tb_spe_rotas_v4 rotas with(nolock) on p.IdTransportadora = rotas.IdTransportadora
	--											and rotas.IdMotorista = p.IdMotorista
	--											and rotas.DataReferencia = cast(p.DataHoraEntrega as date)
	--											and rotas.Excluido = 0

	
	insert into tb_spe_pacotes_v4 (CodigoRota, CodigoPacote, IdTransportadora, DataReferencia, DataHoraEntrega, StatusEntrega, IdMotorista, RecebidoPor, Latitude, Longitude, URLImagem, DataAtualizacao, DataAtualizacaoDetalhe, Excluido)
	select
		CodigoRota
		,CodigoPacote
		,IdTransportadora
		,DataReferencia
		,DataHoraEntrega
		,StatusEntrega
		,IdMotorista
		,RecebidoPor
		,Latitude
		,Longitude
		,URLImagem
		,dateadd(minute,-1,DataAtualizacao) DataAtualizacao --retira um minuto para este pacote não ser atualizado novamente por conta da data de detalhe
		,DataAtualizacao DataAtualizacaoDetalhe
		,0 Excluido
	from
		#pacote_incluirotas


--inclui a rota nos pacotes de itapetininga
-- update b
-- set b.codigorota = a.codigorota
-- from tb_spe_pacotes_para_reprocessar_v4_TO as a with(nolock)
-- inner join tb_spe_pacotes_v4 as b with(nolock)
-- on a.codigopacote = b.codigopacote
-- where b.DataReferencia >=GETDATE()-1
-- and b.codigorota is null



----inclui o codigo da rota nos pacotes do XP de itapetiniga da Fcargo
--update a
--set a.codigorota =  b.codigorota  
--from tb_spe_pacotes_v4 as a
--left join tb_spe_pacotes_para_reprocessar_v4_TO  as b
--on a.codigopacote = b.codigopacote
--where a.excluido = 0
--and  b.codigorota is not null


	--FIM CRIADO EM 27/09/2023...

end
GO
