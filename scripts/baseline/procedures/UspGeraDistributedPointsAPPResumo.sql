-- ============================================================
-- BASELINE: dbo.UspGeraDistributedPointsAPPResumo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraDistributedPointsAPPResumo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraDistributedPointsAPPResumo] 
as 

begin 

drop table if exists #tb_ml_gps_maps_app
select top 1000
	 a.Rota	
	,a.IdTransportadora	
	,a.DataReferencia	
	,a.Latitude	
	,a.Longitude

into #tb_ml_gps_maps_app

from tb_ml_gps_maps_app as a
left join tb_ml_gps_maps_app_resumo as b

on a.rota = b.rota
and a.IdTransportadora = b.IdTransportadora

where a.DataReferencia >= cast(getdate()-2 as date)
and a.IdTransportadora = 2087146923
and b.rota is null
--and rota = 181148703


	declare @Rota int
	declare @IdTransportadora int
	declare @DataReferencia date
	declare @IdUsuario int
	declare @Origem varchar(100)

	while exists (select 1 from #tb_ml_gps_maps_app)
	begin
		select
			top 1
			@Rota = Rota,
			@IdTransportadora = IdTransportadora,
			@DataReferencia = DataReferencia

		from
			#tb_ml_gps_maps_app

		exec UspGetpDistributedPointsAppResumo 	@rota ,	@IdTransportadora ,	@DataReferencia 

		delete #tb_ml_gps_maps_app where Rota = @Rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia

	end


end
GO
