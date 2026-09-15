-- ============================================================
-- BASELINE: dbo.vw_coletar_km_rotas_trajeto
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_coletar_km_rotas_trajeto]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[vw_coletar_km_rotas_trajeto]
as

select distinct top 100000000 *
from
(
	select
		distinct
		cast(rotas.IdRota as varchar(50)) IdRota,
		rotas.DataReferencia,
		rotas.IdTransportadora,
		'Logistics' Origem,
		ServiceCenter 'Parada',
		maps.Latitude,
		maps.Longitude,
		maps.Sequencia as SequenciaParada,
		1 MarketPlace
	from
		tb_ml_pacotes_maps as maps
			join vw_coletar_km_rotas as rotas
			on maps.rota = rotas.IdRota and maps.IdTransportadora = rotas.IdTransportadora and maps.DataReferencia = rotas.DataReferencia
	where
		rotas.Origem = 'Logistics'
		and rotas.MarketPlace = 1
        --and rotas.IdTransportadora  in (1726310024,2087146923,1788092343,1329461926,113907685)
        --and rotas.IdTransportadora  in (2087146923)
		--and 1=2

	--union all

	--select distinct
	--	cast(rotas.IdRota as varchar(50)) IdRota,
	--	rotas.DataReferencia,
	--	rotas.IdTransportadora,
	--	'App' Origem,
	--	ServiceCenter 'Parada',
	--	maps.Latitude,
	--	maps.Longitude,
	--	maps.Sequencia as SequenciaParada,
	--	1 MarketPlace
	--from
	--	tb_ml_gps_maps_app as maps
	--		join vw_coletar_km_rotas as rotas
	--		on maps.rota = rotas.IdRota and maps.IdTransportadora = rotas.IdTransportadora and maps.DataReferencia = rotas.DataReferencia
	--where
	--	rotas.Origem = 'App'
	--	and rotas.MarketPlace = 1
 --       and rotas.IdTransportadora  in (1726310024,2087146923)
	--union all

	--select distinct
	--	cast(rotas.IdRota as varchar(50)) IdRota,
	--	rotas.DataReferencia,
	--	rotas.IdTransportadora,
	--	'Geo' Origem,
	--	ServiceCenter 'Parada',
	--	maps.Latitude,
	--	maps.Longitude,
	--	maps.Sequencia as SequenciaParada,
	--	1 MarketPlace
	--from
	--	tb_ml_gps_maps_geo as maps
	--		join vw_coletar_km_rotas as rotas
	--		on maps.rota = rotas.IdRota and maps.IdTransportadora = rotas.IdTransportadora and maps.DataReferencia = rotas.DataReferencia
	--where
	--	rotas.Origem = 'Geo'
	--	and rotas.MarketPlace = 1
 --       and rotas.IdTransportadora  in (1726310024,2087146923)

	union all

	select
		distinct
		rotas.IdRota,
		rotas.DataReferencia,
		rotas.IdTransportadora,
		'Shopee' Origem,
		ServiceCenter 'Parada',
		maps.Latitude,
		maps.Longitude,
		maps.Sequencia as SequenciaParada,
		2 MarketPlace
	from
		tb_spe_pacotes_maps as maps
			join vw_coletar_km_rotas as rotas
			on maps.rota = rotas.IdRota and maps.IdTransportadora = rotas.IdTransportadora and maps.DataReferencia = rotas.DataReferencia
	where
		rotas.Origem = 'Shopee'
		and rotas.MarketPlace = 2
        and rotas.IdTransportadora in (1726310024,2087146923,20230009)
        --and rotas.IdTransportadora in (20230009)

) base
--where DataReferencia between '2024-05-01' and '2024-05-20'


 order by MarketPlace, IdRota, DataReferencia, IdTransportadora, Origem, SequenciaParada


GO
