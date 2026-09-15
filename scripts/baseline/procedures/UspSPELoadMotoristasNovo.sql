-- ============================================================
-- BASELINE: dbo.UspSPELoadMotoristasNovo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadMotoristasNovo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadMotoristasNovo]  (
	@JSON VARCHAR(max),
	@DataColeta datetime
)
as
begin
	
	SET NOCOUNT ON;

	--declare @JSON VARCHAR(max)
	--declare @DataColeta datetime
	--SELECT
	--	@JSON = dac_ds_contexto_json,
	--	@DataColeta = dac_dh_coleta
	--FROM 
	--	db_Irisys_Json.dbo.tb_dra_coleta WITH (nolock)
	--WHERE 
	--	dac_cd_coleta = 772672


	drop table if exists #motoristas
	create table #motoristas (
		[IdMotorista] [int] NOT NULL,
		[IdTransportadora] [int] NULL,
		[IdStation] [int] NULL,
		[Nome] [varchar](80) NOT NULL,
		[TipoVeiculo] varchar(60) NULL,
		[Placa] varchar(7) NULL,
		[Transportadora] [varchar](60) NULL,
		[NomeMotorista] [varchar](60) NULL,
	)

	INSERT INTO #motoristas
	SELECT 
		IdMotorista
		,null
		,IdStation
		,Nome
		,TipoVeiculo
		,left(replace(rtrim(ltrim(Placa)),' ', ''),7) Placa
		,Transportadora
		,null
	FROM 
		OPENJSON (@JSON)
	WITH 
		(
			IdMotorista int '$.driver_id'
			,IdStation int '$.station_id'
			,Nome varchar(60) '$.driver_name'
			,TipoVeiculo varchar(60) '$.driver_vehicle_type_name'
			,Placa varchar(8) '$.email'
			,Transportadora varchar(60) '$.agency'
		)


	merge tb_spe_motoristas_novo as m
	using (select * from #motoristas where Transportadora='TRANSITARIOLOG') as i
			ON m.IdMotorista = i.IdMotorista
	when matched then
	update set
		m.IdStation = i.IdStation
		,m.Nome = i.Nome
		,m.TipoVeiculo = i.TipoVeiculo
		,m.Placa = i.Placa
		,m.Transportadora = i.Transportadora
		,m.NomeMotorista = case when CHARINDEX(')', i.Nome) > 1 then ltrim(rtrim(right(ltrim(rtrim(i.Nome)), len(ltrim(rtrim(i.Nome)))-CHARINDEX(')', ltrim(rtrim(i.Nome)))))) else  ltrim(rtrim(i.Nome)) end
	when not matched by target then 
	insert (
			IdMotorista
			,IdTransportadora
			,IdStation
			,Nome
			,TipoVeiculo
			,Placa
			,Transportadora
			,NomeMotorista
	)
	values (
		i.IdMotorista
		,20230006
		,i.IdStation
		,i.Nome
		,i.TipoVeiculo
		,i.Placa
		,case when CHARINDEX(')', i.Nome) > 1 then ltrim(rtrim(right(ltrim(rtrim(i.Nome)), len(ltrim(rtrim(i.Nome)))-CHARINDEX(')', ltrim(rtrim(i.Nome)))))) else  ltrim(rtrim(i.Nome)) end
		,case when CHARINDEX(')', i.Nome) > 1 then rtrim(ltrim(replace(left(i.Nome, CHARINDEX(')', i.Nome)-1),'(',''))) end
	);

	

	--Vincula transportadora
	--drop table if exists #transportadoras
	--SELECT 
	--	cli_id_shopee, 
	--	value transportadora
	--	into #transportadoras
	--FROM 
	--	tb_clientes  
	--	CROSS APPLY STRING_SPLIT(cli_nm_shopee, ',')
	--where
	--	cli_id_shopee <> 0

	--update
	--	m
	--set
	--	IdTransportadora = t.cli_id_shopee
	--from
	--	tb_spe_motoristas m
	--	join #transportadoras t on m.Transportadora like '%' + t.transportadora + '%'


end
GO
