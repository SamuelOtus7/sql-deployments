-- ============================================================
-- BASELINE: dbo.UspGetpDistributedPointsGEO
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetpDistributedPointsGEO]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGetpDistributedPointsGEO]
(
	@NomeMotorista varchar(100),
	@rota int,
	@IdTransportadora int,
	@DataReferencia date
)
as

begin

    DROP TABLE if exists #temp
	DROP TABLE if exists #aux
	
	declare @n int = 23
    DECLARE @lat AS FLOAT
    DECLARE @lon AS FLOAT

	select 
		round(cast(apg_latitude as float),4) as LatitudeEnderecoParada,
		round(cast(apg_longitude as float),4) as LongitudeEnderecoParada,
		max((dateadd(hour,-3,apg_dh_apontamento))) as SequenciaParada,
		cast(0 as decimal(18,9)) as DistanciaCentro
	into #aux

	FROM 
		vw_tb_apontamento_geo
	where
		apg_cd_motorista = @NomeMotorista
		and DataHoraReferencia >= @DataReferencia and DataHoraReferencia < dateadd(day,1,@DataReferencia)
	
	group by cast(apg_latitude as float),
		     cast(apg_longitude as float)

	declare @lat_center decimal(18,9), @long_center decimal(18,9)
	select @lat_center = avg(LatitudeEnderecoParada), @long_center = avg(LongitudeEnderecoParada) from #aux

	update #aux 
	set DistanciaCentro = 
		ABS(2 * 6335 
			* asin(sqrt(
				power(sin((radians(LatitudeEnderecoParada) - radians(@lat_center)) / 2), 2)
				+ cos(radians(@lat_center))
				* cos(radians(LatitudeEnderecoParada))
				* power(sin((radians(LongitudeEnderecoParada) - radians(@long_center)) / 2), 2)
			)))

	delete from #aux where DistanciaCentro > 400

	delete from tb_ml_gps_maps_geo where rota = @rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia
	
	--declare @k int = case when (select COUNT(*) from #aux) <= 23 then (select COUNT(*) from #aux) else (select COUNT(*) from #aux) / @n end

	insert into tb_ml_gps_maps_geo
	select 
		@rota as IdRota,
		@IdTransportadora IdTransportadora,
		@DataReferencia DataReferencia,
		LatitudeEnderecoParada,
		LongitudeEnderecoParada,
		ROW_NUMBER () over(order by SequenciaParada) as SequenciaParada
	from #aux
	order by 6
	
	
	DROP TABLE if exists #temp
	DROP TABLE if exists #aux
	
end
GO
