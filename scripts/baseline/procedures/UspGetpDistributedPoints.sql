-- ============================================================
-- BASELINE: dbo.UspGetpDistributedPoints
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetpDistributedPoints]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGetpDistributedPoints]
(
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



	select round(cast(LatitudeEnderecoParada as float),4) as LatitudeEnderecoParada,
		   round(cast(LongitudeEnderecoParada as float),4) as LongitudeEnderecoParada,
		   max(DataHoraEntrega) as SequenciaParada,
		   cast(0 as decimal(18,9)) as DistanciaCentro
	into #aux
	FROM 
		tb_ml_pacotes p
		left join tb_ml_cidades_excecao_maps exc on isnull(p.Cidade,'') = exc.cem_nm_cidade
	where 
		IdRota = @rota
		and exc.cem_cd_cidades_excecao_maps is null
		and DataReferencia = @DataReferencia
		and IdTransportadora = @IdTransportadora
		and Excluido = 0
		and StatusEntrega in ('delivered', 'not_delivered')
		and isnull(SubStatus,'') not in ('transferred','unvisited_address','cancelled','missing','return')
		and LatitudeEnderecoParada <> ''
		--verifica qual é a latitude (considerando só a parte inteira) mais comum entre os pacotes e considera apenas ela
		/*and CEILING(p.LatitudeEnderecoParada) in (
												select 
													Latitude
												from
													(
														select
															IdRota,
															IdTransportadora,
															DataReferencia,
															CEILING(LatitudeEnderecoParada) Latitude,
															count(1) Qtde
														from
															tb_ml_pacotes
														where
															Excluido = 0
															and StatusEntrega in ('delivered', 'not_delivered')
															and isnull(SubStatus,'') <> 'transferred'
														group by 
															IdRota,
															IdTransportadora,
															DataReferencia,
															CEILING(LatitudeEnderecoParada)
													) b
												where
													Qtde = (
														select
															max(Qtde)
														from
															(
															select
																IdRota,
																IdTransportadora,
																DataReferencia,
																CEILING(LatitudeEnderecoParada) Latitude,
																count(1) Qtde
															from
																tb_ml_pacotes
															where
																Excluido = 0
																and StatusEntrega in ('delivered', 'not_delivered')
																and isnull(SubStatus,'') <> 'transferred'
															group by 
																IdRota,
																IdTransportadora,
																DataReferencia,
																CEILING(LatitudeEnderecoParada)
															) t
														where
															b.IdRota = t.IdRota
															and b.IdTransportadora = t.IdTransportadora
															and b.DataReferencia = t.DataReferencia
													)
													and b.IdRota = p.IdRota
													and b.IdTransportadora = p.IdTransportadora
													and b.DataReferencia = p.DataReferencia

									)*/
		
	group by cast(LatitudeEnderecoParada as float),
		     cast(LongitudeEnderecoParada as float)

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

		delete from tb_ml_pacotes_maps where rota = @rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia
		insert into tb_ml_pacotes_maps

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
