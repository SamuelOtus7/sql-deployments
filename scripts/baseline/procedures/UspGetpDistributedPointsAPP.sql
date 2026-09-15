-- ============================================================
-- BASELINE: dbo.UspGetpDistributedPointsAPP
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetpDistributedPointsAPP]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGetpDistributedPointsAPP]
(
	@IdUsuario int,
	@rota int,
	@IdTransportadora int,
	@DataReferencia date,
	@Origem varchar(100)
)
as

begin

    DROP TABLE if exists #temp
	DROP TABLE if exists #aux
	
	declare @n int = 23
    DECLARE @lat AS FLOAT
    DECLARE @lon AS FLOAT


	--verifica a última data em que foi entregue algum pacote para considerar apenas esse ponto 
	declare @ultimaHora datetime = (select 
										max(DataHoraEntrega) 
									FROM 
										tb_ml_pacotes p with(Nolock)
									where 
										IdRota = @rota
										and DataReferencia = @DataReferencia
										and IdTransportadora = @IdTransportadora
										and Excluido = 0
										and StatusEntrega in ('delivered', 'not_delivered')
										and isnull(SubStatus,'') not in ('transferred','unvisited_address','cancelled','missing','return')
										and LatitudeEnderecoParada <> ''
									)

	create table #aux (
		LatitudeEnderecoParada float null,
		LongitudeEnderecoParada float null,
		SequenciaParada datetime null,
		DistanciaCentro decimal(18,9) null
	)

	if @Origem = 'DA'
	begin
		insert into #aux
		select 
			round(cast(rgp_dc_latitude as float),4) as LatitudeEnderecoParada,
			round(cast(rgp_dc_longitude as float),4) as LongitudeEnderecoParada,
			max(dateadd(hour,-3,rgp_dh_data_hora)) as SequenciaParada,
			cast(0 as decimal(18,9)) as DistanciaCentro
		FROM 
			tb_registro_gps
		where
			rgp_cd_usuario = @IdUsuario
			and dateadd(hour,-3,rgp_dh_data_hora) >= @DataReferencia and dateadd(hour,-3,rgp_dh_data_hora) < dateadd(day,1,@DataReferencia)
			--and (dateadd(hour,-3,rgp_dh_data_hora) <= @ultimaHora or @ultimaHora is null)
		group by cast(rgp_dc_latitude as float),
				 cast(rgp_dc_longitude as float)
	end



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

	delete from tb_ml_gps_maps_app where rota = @rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia

	if (select count(1) from #aux) > 3
	begin
		--declare @k int = case when (select COUNT(*) from #aux) <= 23 then (select COUNT(*) from #aux) else (select COUNT(*) from #aux) / @n end

		--delete from tb_ml_gps_maps_app where rota = @rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia
		insert into tb_ml_gps_maps_app
		select 
			@rota as IdRota,
			@IdTransportadora IdTransportadora,
			@DataReferencia DataReferencia,
			LatitudeEnderecoParada,
			LongitudeEnderecoParada,
			ROW_NUMBER () over(order by SequenciaParada) as SequenciaParada
		from #aux
		order by SequenciaParada
	end
	
	DROP TABLE if exists #temp
	DROP TABLE if exists #aux
	
end
GO
