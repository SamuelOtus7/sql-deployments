-- ============================================================
-- BASELINE: dbo.UspGetpDistributedPointsShopee
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetpDistributedPointsShopee]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspGetpDistributedPointsShopee]
(
	@rota varchar(30),
	@IdTransportadora int,
	@DataReferencia date,
	@Versao varchar(30)
)
as

begin

    DROP TABLE if exists #temp
	DROP TABLE if exists #aux
	
	declare @n int = 23
    DECLARE @lat AS FLOAT
    DECLARE @lon AS FLOAT


	create table #aux (
		LatitudeEnderecoParada float null,
		LongitudeEnderecoParada float null,
		SequenciaParada datetime null,
		DistanciaCentro decimal(18,9) null
	)

	if @Versao = 'Novo'
	begin
		insert into #aux
		select round(cast(Latitude as float),4) as LatitudeEnderecoParada,
			   round(cast(Longitude as float),4) as LongitudeEnderecoParada,
			   max(DataHoraEntrega) as SequenciaParada,
			   cast(0 as decimal(18,9)) as DistanciaCentro
		FROM tb_spe_pacotes_novo p with(nolock)
		where CodigoRota = @rota
			and DataReferencia = @DataReferencia
			and IdTransportadora = @IdTransportadora
			--and Excluido = 0
			and StatusEntrega in ('Delivered', 'On Hold')
			--and isnull(SubStatus,'') not in ('transferred','unvisited_address','cancelled','missing','return')
			and Latitude <> ''
			and Longitude <> ''
		
		group by cast(Latitude as float),
				 cast(Longitude as float)
	end
	else if @Versao = 'V4'
	begin
		insert into #aux
		select round(cast(Latitude as float),4) as LatitudeEnderecoParada,
			   round(cast(Longitude as float),4) as LongitudeEnderecoParada,
			   max(DataHoraEntrega) as SequenciaParada,
			   cast(0 as decimal(18,9)) as DistanciaCentro
		FROM tb_spe_pacotes_v4 p with(nolock)
		where CodigoRota = @rota
			and DataReferencia = @DataReferencia
			and IdTransportadora = @IdTransportadora
			and Excluido = 0
			and StatusEntrega in ('Delivered', 'Cancelled', 'On Hold')
			and isnull(SubStatus,'') <> 'transferred'
			and Latitude <> ''
			and Longitude <> ''
		
		group by cast(Latitude as float),
				 cast(Longitude as float)

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

	--if exists (select top 1 SequenciaParada from #aux)	
	--begin
		declare @k int = case when (select COUNT(*) from #aux) <= 23 then (select COUNT(*) from #aux) else (select COUNT(*) from #aux) / @n end

		delete from tb_spe_pacotes_maps where rota = @rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia
		insert into tb_spe_pacotes_maps

		select 
			@rota as IdRota,
			@IdTransportadora IdTransportadora,
			@DataReferencia DataReferencia,
			LatitudeEnderecoParada,
			LongitudeEnderecoParada,
			ROW_NUMBER () over(order by SequenciaParada) as SequenciaParada
		from (
		select top (@n) *
		from (
				select *,
					   ROW_NUMBER () over(order by SequenciaParada) % @k as resto
				from #aux
			 ) as base
		where case when @k <=23 then 1 else 0 end = 1 or resto = 0
		order by NEWID()
		) as base
		order by SequenciaParada
	--end
	DROP TABLE if exists #temp
	DROP TABLE if exists #aux
	
end
GO
