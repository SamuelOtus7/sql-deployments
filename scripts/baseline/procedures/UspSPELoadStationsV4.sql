-- ============================================================
-- BASELINE: dbo.UspSPELoadStationsV4
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadStationsV4]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPELoadStationsV4]  (
	@JSON VARCHAR(max)
)
as
begin
	
	SET NOCOUNT ON;

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'station_list')
	

	drop table if exists #stations
	create table #stations (
		IdStation int not null,
		CodigoStation varchar(10) not null,
		NomeStation varchar(60) not null,
		IdCidade int not null,
		IdCidadeReferencia int not null,
		Cidade varchar(60) null,
		Estado varchar(30) null,
		Cep varchar(8) null,
		Latitude varchar(15) null,
		Longitude varchar(15) null,
		Endereco varchar(100) not null,
		NomeContato varchar(60) not null,
		EmailContato varchar(60) not null,
		TelefoneContato varchar(15) not null,
		PropriaFrota bit not null
	)

	INSERT INTO #stations
	SELECT 
		IdStation
		,CodigoStation
		,NomeStation
		,IdCidade
		,IdCidadeReferencia
		,Cidade
		,Estado
		,Cep
		,Latitude
		,Longitude
		,Endereco
		,NomeContato
		,EmailContato
		,TelefoneContato
		,PropriaFrota
	FROM 
		OPENJSON (@JsonList)
	WITH 
		(
			IdStation int '$.id'
			,CodigoStation varchar(10) '$.station_code'
			,NomeStation varchar(60) '$.station_name'
			,IdCidade int '$.city_id'
			,IdCidadeReferencia int '$.uptown_id'
			,Cidade varchar(60) '$.city_name'
			,Estado varchar(30) '$.state_name'
			,Cidade varchar(60) '$.city'
			,Cep varchar(8) '$.zipcode'
			,Latitude varchar(15) '$.latitude'
			,Longitude varchar(15) '$.longitude'
			,Endereco varchar(100) '$.address'
			,NomeContato varchar(60) '$.contact_person'
			,EmailContato varchar(60) '$.contact_person_email'
			,TelefoneContato varchar(15) '$.contact_person_phone'
			,PropriaFrota bit '$.id'
		)

		

	merge tb_spe_station as s
	using (select * from #stations where CodigoStation <> '') as i
			ON s.IdStation = i.IdStation
	when matched then
	update set
		s.CodigoStation = i.CodigoStation
		,s.NomeStation = i.NomeStation
		,s.IdCidade = i.IdCidade
		,s.IdCidadeReferencia = i.IdCidadeReferencia
		,s.Cidade = i.Cidade
		,s.Estado = i.Estado
		,s.Cep = i.Cep
		,s.Latitude = i.Latitude
		,s.Longitude = i.Longitude
		,s.Endereco = i.Endereco
		,s.NomeContato = i.NomeContato
		,s.EmailContato = i.EmailContato
		,s.TelefoneContato = i.TelefoneContato
		,s.PropriaFrota = i.PropriaFrota
	when not matched by target then 
	insert (
			IdStation
			,CodigoStation
			,NomeStation
			,IdCidade
			,IdCidadeReferencia
			,Cidade
			,Estado
			,Cep
			,Latitude
			,Longitude
			,Endereco
			,NomeContato
			,EmailContato
			,TelefoneContato
			,PropriaFrota
	)
	values (
			i.IdStation
			,i.CodigoStation
			,i.NomeStation
			,i.IdCidade
			,i.IdCidadeReferencia
			,i.Cidade
			,i.Estado
			,i.Cep
			,i.Latitude
			,i.Longitude
			,i.Endereco
			,i.NomeContato
			,i.EmailContato
			,i.TelefoneContato
			,i.PropriaFrota
	);

end
GO
