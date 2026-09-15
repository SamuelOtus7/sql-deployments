-- ============================================================
-- BASELINE: dbo.UspGetpDistributedPointsAppResumo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetpDistributedPointsAppResumo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspGetpDistributedPointsAppResumo]
(
	@rota varchar(50),
	@IdTransportadora int,
	@DataReferencia date
)
as


--declare 
--	@Rota varchar(50) = '181148703' ,
--	@IdTransportadora int = 2087146923 ,
--	@DataReferencia  date = '2024-10-31'
begin 

DROP TABLE if exists #base
select *
	into #base
from tb_ml_gps_maps_app
where DataReferencia = @DataReferencia
and cast(rota as varchar(50)) = @Rota
and IdTransportadora = @IdTransportadora


declare @qtd int = (select count(*) from  #base)
declare @n int = 30
declare @k int = case when (select COUNT(*) from tb_ml_gps_maps_app) <= 23 then (@qtd) else (@qtd) / @n end


delete from tb_ml_gps_maps_app_resumo where rota = @rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia

insert into tb_ml_gps_maps_app_resumo
select 
	Rota	
	,IdTransportadora	
	,DataReferencia	
	,Latitude	
	,Longitude
	,ROW_NUMBER() over (order by Sequencia) as Sequencia

from 
(
		select top (@n) *
		from (
				select *,
					   ROW_NUMBER () over(order by Sequencia) % @k as resto
				from #base 
			 ) as base
		where case when @k <=23 then 1 else 0 end = 1 or resto = 0
		order by NEWID()
) as base
order by Sequencia

end
GO
