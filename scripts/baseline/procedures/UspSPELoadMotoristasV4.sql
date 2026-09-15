-- ============================================================
-- BASELINE: dbo.UspSPELoadMotoristasV4
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadMotoristasV4]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadMotoristasV4]  (
	@JSON VARCHAR(max),
	@IdTransportadora int
)
as
begin
	SET NOCOUNT ON;


--declare @QueueID bigint = NULL
--	declare @Json varchar(max)
--	declare @IdTransportadora int
--	declare @VerificaJson bit

--	--begin tran
--	--commit
--select 
--		@QueueID = Q.dac_cd_coleta, 
--		@Json = Q.dac_ds_contexto_json,
--		@IdTransportadora = Q.dac_cd_transportadora,
--		@VerificaJson = Q.verifica_json
--	FROM 
--		(
--			SELECT 
--				TOP 1 dac_cd_coleta, dac_in_processado, dac_ds_contexto, dac_ds_contexto_json, dac_cd_transportadora,
--				case when left(dac_ds_contexto_json,1) in ('{','[') and dac_ds_contexto_json <> '[]' then 1 else 0 end verifica_json
--			FROM 
--				db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
--			WHERE 
--				dac_ds_tipo_coleta = 'SPE4_DRIVERS'
--				and dac_cd_coleta = 30692144
--				--and dac_in_processado = 0
--			ORDER BY 
--				dac_cd_coleta
--	) Q
--	--waitfor delay '00:00:03'
	

	
	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'list')
	
		

	drop table if exists #motoristas
	create table #motoristas (
		IdMotorista int not null,
		IdTransportadora int not null,
		IdStation int null,
		Nome varchar(60) not null,
		TipoVeiculo int not null,
		NomeTipoVeiculo varchar(60) null,
		FotoMotorista varchar(100) null,
		status varchar(100) ,
		email varchar(100) ,
		sub_status varchar(100) ,
		login_status varchar(100) ,
		cpf varchar(100),
		renavam varchar(100),
		last_updated_timestamp varchar(100),
		driver_agency_display_status varchar(100),
		birth_day varchar(100),
		delivery_station_name varchar(100),
		last_login_time varchar(100),
		city_name				varchar(100),
		neighbourhood_name		varchar(100),
		street_name				varchar(100),
		address_number			varchar(100),
		zip_code				varchar(100),
		is_agency_driver_flag   varchar(100)



	)

	INSERT INTO #motoristas
	SELECT 
		IdMotorista
		,@IdTransportadora
		,IdStations
		,Nome
		,TipoVeiculo
		,NomeTipoVeiculo
		,FotoMotorista
		,status
		,email
		,sub_status
		,login_status
		,cpf
		,renavam 
		, cast(dateadd(second,((cast(last_updated_timestamp as bigint))) - 10800,'1970-01-01') as date) as last_updated_timestamp
		,driver_agency_display_status 
		,cast(dateadd(second,((cast(birth_day as bigint))) - 10800,'1970-01-01') as date) birth_day
		,delivery_station_name 
		,cast(dateadd(second,((cast(last_login_time as bigint))) - 10800,'1970-01-01') as date) last_login_time
		,city_name			
		,neighbourhood_name	
		,street_name			
		,address_number		
		,zip_code			
		,is_agency_driver_flag

	FROM 
		OPENJSON (@JsonList)
	WITH 
		(
			IdMotorista int '$.driver_id'
			,IdStations int '$.station_id'
			,Nome varchar(60) '$.driver_name'
			,TipoVeiculo int '$.driver_vehicle_type'
			,NomeTipoVeiculo varchar(60) '$.driver_vehicle_type_name'
			,FotoMotorista varchar(100)  '$.image'
			,status varchar(100)  '$.status'
			,email varchar(100)  '$.email'
			,sub_status varchar(100)  '$.sub_status'
			,login_status varchar(100)  '$.login_status'
			,cpf varchar(100)  '$.cpf'
			,renavam varchar(100) '$.renavam'
			,last_updated_timestamp varchar(100) '$.last_updated_timestamp'
			,driver_agency_display_status varchar(100) '$.driver_agency_display_status'
			,birth_day varchar(100) '$.birth_day'
			,delivery_station_name varchar(100) '$.delivery_station_name'
			,last_login_time varchar(100) '$.last_login_time'
			,city_name			varchar(100) '$.city_name'
			,neighbourhood_name	varchar(100) '$.neighbourhood_name'
			,street_name		varchar(100) '$.street_name'	
			,address_number		varchar(100) '$.address_number'
			,zip_code			varchar(100) '$.zip_code'
			,is_agency_driver_flag   varchar(100) '$.is_agency_driver_flag'
					   	
		)
		
--select 
--* 
--from #motoristas where idmotorista = 90895

	merge tb_spe_motoristas as m
	using #motoristas as i
			ON m.IdMotorista = i.IdMotorista
			and m.IdTransportadora = i.IdTransportadora

	when matched then
	update set
		m.IdStation = i.IdStation
		,m.Nome = i.Nome
		,m.IdTransportadora = i.IdTransportadora
		,m.TipoVeiculo = i.TipoVeiculo
		,m.NomeTipoVeiculo = i.NomeTipoVeiculo
		,m.FotoMotorista = i.FotoMotorista
		,m.NomeMotorista = case when CHARINDEX(')', i.Nome) > 1 then ltrim(rtrim(right(ltrim(rtrim(i.Nome)), len(ltrim(rtrim(i.Nome)))-CHARINDEX(')', ltrim(rtrim(i.Nome)))))) else  ltrim(rtrim(i.Nome)) end
		,m.Status	= i.Status						 
		,m.Email	 = i.Email							 
		,m.SubStatus = i.sub_status					 
		,m.StatusLogin = i.login_status					 
		,m.Renavam	 = i.Renavam						 
		,m.ModificacaoSPX = i.last_updated_timestamp		 
		,m.DisplayStatus	 = i.driver_agency_display_status   
		,m.Aniversario = i.birth_day						 
		,m.NomeStation = i.delivery_station_name			 
		,m.UltimoLoginSPX = i.last_login_time				 
		,m.Cidade = i.city_name						 
		,m.Rua = i.street_name					 
		,m.Numero = i.address_number				 
		,m.Cep = i.zip_code						 
		,m.FlagAgencia = i.is_agency_driver_flag			 




	when not matched by target then 
	insert (
			IdMotorista
			,IdTransportadora
			,IdStation
			,Nome
			,TipoVeiculo
			,NomeTipoVeiculo
			,FotoMotorista
			,NomeMotorista
			,Status			
			,Email			
			,SubStatus		
			,StatusLogin		
			,Renavam			
			,ModificacaoSPX	
			,DisplayStatus	
			,Aniversario		
			,NomeStation		
			,UltimoLoginSPX	
			,Cidade			
			,Rua				
			,Numero			
			,Cep				
			,FlagAgencia		

	)
	values (
		i.IdMotorista
		,i.IdTransportadora
		,i.IdStation
		,i.Nome
		,i.TipoVeiculo
		,i.NomeTipoVeiculo
		,i.FotoMotorista
		,case when CHARINDEX(')', i.Nome) > 1 then ltrim(rtrim(right(ltrim(rtrim(i.Nome)), len(ltrim(rtrim(i.Nome)))-CHARINDEX(')', ltrim(rtrim(i.Nome)))))) else  ltrim(rtrim(i.Nome)) end
		,i.Status						
		,i.Email						
		,i.sub_status					
		,i.login_status					
		,i.Renavam						
		,i.last_updated_timestamp		
		,i.driver_agency_display_status 
		,i.birth_day					
		,i.delivery_station_name		
		,i.last_login_time				
		,i.city_name					
		,i.street_name					
		,i.address_number				
		,i.zip_code						
		,i.is_agency_driver_flag
	);	

	end
GO
