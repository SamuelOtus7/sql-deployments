-- ============================================================
-- BASELINE: dbo.UspSPELoadRotasV4
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadRotasV4]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadRotasV4] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@IdStations int,
	@DataColeta datetime
)
as
begin
	
	SET NOCOUNT ON;


	-- declare @JSON VARCHAR(max)
	-- declare @IdTransportadora int
	-- declare @IdStations int
	-- declare @DataColeta datetime

	-- SELECT 
	-- 	@JSON = dac_ds_contexto_json,
	-- 	@IdTransportadora = dac_cd_transportadora,
	-- 	@IdStations = dac_ds_contexto,
	-- 	@DataColeta = dac_dh_coleta
	-- FROM 
	-- 	db_Irisys_Json.dbo.tb_dra_coleta WITH (nolock)
	-- WHERE 
	-- 	dac_cd_coleta = 13231922

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'list')




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
		IdStatus int null,
        DataHoraCarga datetime,
        Paradas int,
        CidadeReferencia VARCHAR(50),
        DistanciaTotal decimal(10,2),
        Pacotes VARCHAR(max)
	)

	INSERT INTO #rotas
	SELECT 
		CodigoRota
		,@IdTransportadora IdTransportadora
		,cast(dateadd(second,((cast(DataRerencia as bigint))) - 10800,'1970-01-01') as date) DataReferencia
		,dateadd(second,((cast(DataRerencia as bigint))) - 10800,'1970-01-01') DataHoraInicio
		,case when DataHoraFim = '' or DataHoraFim = 0 then null else dateadd(second,((cast(DataHoraFim as bigint))) - 10800,'1970-01-01') end DataHoraFim
		,@DataColeta DataHoraColeta
		,@IdStations IdStation
		,IdMotorista
		,IdStatus
        ,dateadd(second,((cast(DataHoraCarga as bigint))) - 10800,'1970-01-01') as DataHoraCarga
        ,Paradas
        ,CidadeReferencia
        ,DistanciaTotal        
        ,Pacotes

	FROM 
		OPENJSON (@JsonList)
	WITH 
		(
			CodigoRota varchar(30) '$.assignment_task_id'
			,IdMotorista int '$.driver_id'
			,DataRerencia varchar(1000) '$.assigned_time'
			,DataHoraFim varchar(1000) '$.complete_time'
			,IdStatus int '$.status'
            
            ,Paradas int '$.stops_number'
            ,CidadeReferencia varchar(50)  '$.city'
            ,DistanciaTotal decimal(10,5)  '$.total_distance'
			,Pacotes varchar(1000) '$.shipment_id'
			--,DataRerencia varchar(1000) '$.ctime'
			--,DataRerencia2 varchar(1000) '$.mtime'
			--,DataRerencia3 varchar(1000) '$.delivery_time'
			--,DataRerencia4 varchar(1000) '$.processing_time'
			,DataHoraCarga varchar(1000) '$.assigned_time'
			--,DataRerencia6 varchar(1000) '$.processed_time'
			--,DataRerencia7 varchar(1000) '$.partially_assigned_time'
		)

if @IdStations = 5055
begin 

	declare 
	  @pacotes varchar(max) 
	, @Station varchar(max) 
	, @DataReferencia date
	, @Transportadora int 
	, @CodigoRota varchar(max) ;

	DECLARE ExemploCursor CURSOR FOR
	SELECT CodigoRota, pacotes ,DataReferencia, IdStation, IdTransportadora
	FROM #rotas
	where CodigoRota like 'to%';

	-- Abrindo o cursor
	OPEN ExemploCursor;

	-- Buscando o próximo registro do cursor
	FETCH NEXT FROM ExemploCursor INTO @CodigoRota, @pacotes , @DataReferencia , @Station, @Transportadora;



	-- Loop para processar cada registro do cursor
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Aqui você pode fazer o que quiser com os dados, por exemplo, imprimir
		MERGE INTO tb_spe_pacotes_para_reprocessar_v4_TO AS target
		USING (
			SELECT 
				value AS Pacote,
				@CodigoRota as CodigoRota,
				@Transportadora AS IdTransportadora,
				@Station AS IdStation
			FROM STRING_SPLIT(@pacotes, ',')
		) AS source
		ON (target.CodigoPacote = source.Pacote)
		WHEN NOT MATCHED THEN
			INSERT (CodigoPacote,CodigoRota,  IdTransportadora, IdStation)
			VALUES ( source.Pacote,source.CodigoRota, source.IdTransportadora, source.IdStation);

		-- Buscando o próximo registro do cursor
		FETCH NEXT FROM ExemploCursor INTO @CodigoRota, @pacotes , @DataReferencia , @Station, @Transportadora;
	END

	-- Fechando o cursor
	CLOSE ExemploCursor;

	-- Liberando recursos do cursor
	DEALLOCATE ExemploCursor;

end;


	merge tb_spe_rotas_v4 as r
	using (
		select
			r.*,
			m.NomeTipoVeiculo TipoVeiculo
		from
			#rotas r
			left join tb_spe_motoristas m on r.IdMotorista = m.IdMotorista
			and r.idtransportadora = m.idtransportadora
			) as i ON r.CodigoRota = i.CodigoRota and r.IdTransportadora = i.IdTransportadora and r.DataReferencia = i.DataReferencia
	when matched then
	update set
		r.DataHoraColeta = i.DataHoraColeta
		,r.IdStation = i.IdStation
		,r.IdMotorista = i.IdMotorista
		,r.TipoVeiculo = i.TipoVeiculo
		,r.DataHoraInicio = i.DataHoraInicio
		,r.DataHoraFim = i.DataHoraFim
		,r.DataAtualizacao = getdate()
		,r.Excluido = 0
        ,r.DataHoraCarga = i.DataHoraCarga
        ,r.Paradas = i.Paradas
        ,r.CidadeReferencia = i.CidadeReferencia
        ,r.DistanciaTotal = i.DistanciaTotal

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
			,TipoVeiculo
			,DataAtualizacao
			,Excluido
            ,DataHoraCarga
            ,Paradas
            ,CidadeReferencia
            ,DistanciaTotal 
                
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
			,i.TipoVeiculo
			,getdate()
			,0
            ,i.DataHoraCarga
            ,i.Paradas
            ,i.CidadeReferencia
            ,i.DistanciaTotal 
	);



	--declare @count int = (select count(1) from #rotas)
	--if @count > 0
	--begin
		
	--	update
	--		r
	--	set
	--		Excluido = 1,
	--		DataAtualizacao = getdate()
	--	from
	--		tb_spe_rotas_v4 r
	--		left join #rotas as i on r.CodigoRota = i.CodigoRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora
	--	where
	--		i.CodigoRota is null
	--		and r.IdStation = @IdStations
	--		and r.IdTransportadora = @IdTransportadora
	--		and r.PacotesEntregues = 0
	--		and r.DataReferencia >= dateadd(day,-1,cast(getdate() as date))
		
			
	--end

end
GO
