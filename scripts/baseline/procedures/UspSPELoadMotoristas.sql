-- ============================================================
-- BASELINE: dbo.UspSPELoadMotoristas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadMotoristas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPELoadMotoristas]  (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@IdStations int
)
as
begin
	
	SET NOCOUNT ON;

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'list')

	drop table if exists #motoristas
	create table #motoristas (
		IdMotorista int not null,
		--IdTransportadora int not null,
		IdStation int null,
		Nome varchar(60) not null,
		TipoVeiculo int not null,
		TotalEntregas smallint not null,
		Latitude varchar(15) null,
		Longitude varchar(15) null
	)

	INSERT INTO #motoristas
	SELECT 
		IdMotorista
		--,@IdTransportadora
		,@IdStations
		,Nome
		,TipoVeiculo
		,TotalEntregas
		,Latitude
		,Longitude
	FROM 
		OPENJSON (@JsonList)
	WITH 
		(
			IdMotorista int '$.driver_id'
			,Nome varchar(60) '$.driver_name'
			,TipoVeiculo int '$.driver_vehicle_type'
			,TotalEntregas int '$.total'
			,Latitude varchar(15) '$.latitude'
			,Longitude varchar(15) '$.longitude'
		)


	merge tb_spe_motoristas as m
	using #motoristas as i
			ON m.IdMotorista = i.IdMotorista
	when matched then
	update set
		m.IdStation = i.IdStation
		,m.Nome = i.Nome
		,m.TipoVeiculo = i.TipoVeiculo
		,m.TotalEntregas = i.TotalEntregas
		,m.Latitude = i.Latitude
		,m.Longitude = i.Longitude
		,m.NomeMotorista = case when CHARINDEX(')', i.Nome) > 1 then ltrim(rtrim(right(ltrim(rtrim(i.Nome)), len(ltrim(rtrim(i.Nome)))-CHARINDEX(')', ltrim(rtrim(i.Nome)))))) else  ltrim(rtrim(i.Nome)) end
		,m.Transportadora = case when CHARINDEX(')', i.Nome) > 1 then rtrim(ltrim(replace(left(i.Nome, CHARINDEX(')', i.Nome)-1),'(',''))) end
	when not matched by target then 
	insert (
			IdMotorista
			--,IdTransportadora
			,IdStation
			,Nome
			,TipoVeiculo
			,TotalEntregas
			,Latitude
			,Longitude
			,NomeMotorista
			,Transportadora
	)
	values (
		i.IdMotorista
		--,i.IdTransportadora
		,i.IdStation
		,i.Nome
		,i.TipoVeiculo
		,i.TotalEntregas
		,i.Latitude
		,i.Longitude
		,case when CHARINDEX(')', i.Nome) > 1 then ltrim(rtrim(right(ltrim(rtrim(i.Nome)), len(ltrim(rtrim(i.Nome)))-CHARINDEX(')', ltrim(rtrim(i.Nome)))))) else  ltrim(rtrim(i.Nome)) end
		,case when CHARINDEX(')', i.Nome) > 1 then rtrim(ltrim(replace(left(i.Nome, CHARINDEX(')', i.Nome)-1),'(',''))) end
	);

	
	--insert into tb_spe_motoristas
	--select
	--	distinct 
	--	rotas.ser_driver_id,
	--	null IdTransportadora,
	--	rotas.ser_station_id,
	--	rotas.ser_driver_name,
	--	null TipoVeiculo,
	--	null TotalEntregas,
	--	null Latitude,
	--	null Longitude,
	--	case when CHARINDEX(')', rotas.ser_driver_name) > 1 then rtrim(ltrim(replace(left(rotas.ser_driver_name, CHARINDEX(')', rotas.ser_driver_name)-1),'(',''))) end Transportadora,
	--	case when CHARINDEX(')', rotas.ser_driver_name) > 1 then rtrim(ltrim(replace(right(rotas.ser_driver_name, len(rotas.ser_driver_name)-CHARINDEX(')', rotas.ser_driver_name)),'(',''))) else rotas.ser_driver_name end NomeMotorista
	--from
	--	tb_spe_export_rotas rotas with(nolock)
	--	left join tb_spe_motoristas motoristas with(nolock) on rotas.ser_driver_id = motoristas.IdMotorista
	--where
	--	motoristas.IdMotorista is null

	--Vincula transportadora
	drop table if exists #transportadoras
	SELECT 
		cli_id_shopee, 
		value transportadora
		into #transportadoras
	FROM 
		tb_clientes  
		CROSS APPLY STRING_SPLIT(cli_nm_shopee, ',')
	where
		cli_id_shopee <> 0

	update
		m
	set
		IdTransportadora = t.cli_id_shopee
	from
		tb_spe_motoristas m
		join #transportadoras t on m.Transportadora like '%' + t.transportadora + '%'


end
GO
