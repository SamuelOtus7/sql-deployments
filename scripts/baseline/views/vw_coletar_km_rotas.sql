-- ============================================================
-- BASELINE: dbo.vw_coletar_km_rotas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_coletar_km_rotas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--834780814	268
--1930706223	96
--2087146923	1123
--select IdTransportadora,count(*) from [vw_coletar_km_rotas] group by IdTransportadora



CREATE view [dbo].[vw_coletar_km_rotas]
as

/*
	select
			cast(rotas.IdRota as varchar(30)) IdRota,
			rotas.DataReferencia,
			rotas.IdTransportadora,
			'Logistics' Origem,
			isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) ServiceCenter,
			cast(case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end as decimal(18, 9)) Latitude,
			cast(case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end as decimal(18, 9)) Longitude,
			1 MarketPlace
	from tb_ml_rotas as rotas
		left join tb_ml_service_center svc with(nolock) on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc.svc_cd_service_center
		left join tb_ml_service_center svc2 with(nolock) on rotas.ServiceCenter = svc2.svc_cd_service_center
	where Excluido = 0 and IdRota in (109723034)
*/


select distinct base.*
from (

		select
			cast(rotas.IdRota as varchar(30)) IdRota,
			rotas.DataReferencia,
			rotas.IdTransportadora,
			'Logistics' Origem,
			isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) ServiceCenter,
			cast(case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end as decimal(18, 9)) Latitude,
			cast(case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end as decimal(18, 9)) Longitude,
			1 MarketPlace
			--dec_ds_erro
		from
			(
				select
					r.IdRota,
					r.DataReferencia,
					r.IdTransportadora,
					r.OrigemSaida,
					r.ServiceCenter,
					r.Excluido
				from tb_ml_rotas r with (nolock)
				union all
				select
					fm.IdRota,
					fm.DataReferencia,
					fm.IdTransportadora,
					fm.OrigemSaida,
					fm.OrigemSaida as ServiceCenter, -- mapeamento solicitado
					fm.Excluido
				from tb_ml_fm_rotas fm with (nolock)
		) rotas
			left join tb_dra_coleta_maps coleta with(nolock) on rotas.IdRota = coleta.dam_cd_rota 
														and rotas.DataReferencia = coleta.dam_dh_referencia
														and rotas.IdTransportadora = coleta.dam_cd_transportadora
														and coleta.dam_nm_origem = 'Logistics'
														and coleta.dam_cd_marketplace = 1
			left join tb_ml_service_center svc with(nolock) 
			on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc.svc_cd_service_center
			and rotas.idtransportadora = svc.idtransportadora

			left join tb_ml_service_center svc2 with(nolock) on rotas.ServiceCenter = svc2.svc_cd_service_center
			and rotas.idtransportadora = svc2.idtransportadora

			left join tb_dra_erros_coleta erros with(nolock) on cast(rotas.IdRota as varchar(30)) = replace(
													replace(
														replace(
														replace(
															right(
																dec_ds_contexto,
																len(dec_ds_contexto) -
																charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,1)+1)+1)
															),
														'/Geo',''),
													'/Logistics',''),
												'/Shopee',''),
												'/App','')
		and rotas.IdTransportadora = erros.dec_cd_transportadora and erros.dec_ds_tipo_coleta = 'SCRAPPER'
		where 1=1
			 and coleta.dam_cd_coleta is null 
		--and rotas.TotalPacotes = rotas.PacotesEntregues + rotas.PacotesNaoEntregue
			and rotas.Excluido = 0
			and exists (select 1 from tb_ml_pacotes_maps p with(nolock) where rotas.IdRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
			-- and rotas.DataReferencia < cast(getdate() as date) 
			-- and rotas.DataReferencia between '2024-07-01' and cast(getdate()-1 as date) 
			and rotas.DataReferencia >= '2025-04-01'
			--and rotas.DataReferencia >= '2024-07-16'
			and case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end is not null and case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end is not null
			 and rotas.IdTransportadora in (/*  1726310024,2087146923,643493085,*/ 2087146923) --1930706223,
			--and rotas.IdTransportadora in (/*  1726310024,2087146923,643493085,*/ 1329461926) --1930706223,
            --and rotas.ServiceCenter = 'SMG14'
			


			--select top 10 * from tb_ml_pacotes_maps nolock
			--where datareferencia = '2024-07-30' 
			--and idtransportadora = 2087146923
			
			
			--2087146923, 1726310024
--			AND (erros.dec_cd_coleta is null 
									 
--			or (erros.dec_ds_erro in (select distinct Mensagem from [dbo].[tb_dra_erros_recorrentes])
--					and datediff(hour,erros.dec_dh_coleta,getdate()) < 1 )
--					or rotas.idrota in (
--					select  idrota from [vw_rotas]
--where DataReferencia between '2024-01-19' and '2024-01-22'
--and IdTransportadora in (1726310024,2087146923,1788092343)
--and LinkMapaMeli is null) -- rotas.idrota in (select id from tb_insert)
--			)

--and rotas.IdTransportadora = 1726310024

					
		--union all

		--select
		--	rotas.CodigoRota,
		--	rotas.DataReferencia,
		--	rotas.IdTransportadora,
		--	'Shopee' Origem,
		--	hub.NomeStation Hub,
		--	cast(hub.Latitude as decimal(18, 9)) Latitude,
		--	cast(hub.Longitude as decimal(18, 9)) Longitude,
		--	2 MarketPlace
		--from
		--	tb_spe_rotas_novo rotas with(nolock)
		--	left join tb_dra_coleta_maps coleta with(nolock) on rotas.CodigoRota = coleta.dam_cd_rota 
		--												and rotas.DataReferencia = coleta.dam_dh_referencia
		--												and rotas.IdTransportadora = coleta.dam_cd_transportadora
		--												and coleta.dam_nm_origem = 'Shopee'
		--												and coleta.dam_cd_marketplace = 2
		--	join tb_spe_station hub with(nolock) on rotas.IdStation = hub.IdStation
		--	left join tb_dra_erros_coleta erros with(nolock) on rotas.CodigoRota = replace(
		--											replace(
		--												replace(
		--												replace(
		--													right(
		--														dec_ds_contexto,
		--														len(dec_ds_contexto) -
		--														charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,1)+1)+1)
		--													),
		--												'/Geo',''),
		--											'/Logistics',''),
		--										'/Shopee',''),
		--										'/App','')
		--	and rotas.IdTransportadora = erros.dec_cd_transportadora and erros.dec_ds_tipo_coleta = 'SCRAPPER'
		--where
		--	coleta.dam_cd_coleta is null
		--	and rotas.Excluido = 0
		--	and exists (select 1 from tb_spe_pacotes_maps p with(nolock) where rotas.CodigoRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		--	and rotas.DataReferencia < cast(getdate() as date)
		--	and hub.Latitude is not null 
		--	and hub.Longitude is not null
		--	AND (erros.dec_cd_coleta is null 
		--	or (erros.dec_ds_erro in (select distinct Mensagem from [dbo].[tb_dra_erros_recorrentes])
		--			and datediff(hour,erros.dec_dh_coleta,getdate()) < 1 )
				
		--	)

		--union all

		--select
		--	rotas.CodigoRota,
		--	rotas.DataReferencia,
		--	rotas.IdTransportadora,
		--	'Shopee' Origem,
		--	hub.NomeStation Hub,
		--	cast(hub.Latitude as decimal(18, 9)) Latitude,
		--	cast(hub.Longitude as decimal(18, 9)) Longitude,
		--	2 MarketPlace
		--from
		--	tb_spe_rotas_v4 rotas with(nolock)
		--	left join tb_dra_coleta_maps coleta with(nolock) on rotas.CodigoRota = coleta.dam_cd_rota 
		--												and rotas.DataReferencia = coleta.dam_dh_referencia
		--												and rotas.IdTransportadora = coleta.dam_cd_transportadora
		--												and coleta.dam_nm_origem = 'Shopee'
		--												and coleta.dam_cd_marketplace = 2
		--	join tb_spe_station hub with(nolock) on rotas.IdStation = hub.IdStation
		--	left join tb_dra_erros_coleta erros with(nolock) on rotas.CodigoRota = replace(
		--											replace(
		--												replace(
		--												replace(
		--													right(
		--														dec_ds_contexto,
		--														len(dec_ds_contexto) -
		--														charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,1)+1)+1)
		--													),
		--												'/Geo',''),
		--											'/Logistics',''),
		--										'/Shopee',''),
		--										'/App','')
		--	and rotas.IdTransportadora = erros.dec_cd_transportadora and erros.dec_ds_tipo_coleta = 'SCRAPPER'
		--where
		--	coleta.dam_cd_coleta is null
		--	and rotas.Excluido = 0
		--	--and exists (select 1 from tb_spe_pacotes_maps p with(nolock) where rotas.CodigoRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		--	and rotas.DataReferencia < cast(getdate() as date)
		--	and hub.Latitude is not null 
		--	and hub.Longitude is not null
		--	AND (erros.dec_cd_coleta is null 
		--	or (erros.dec_ds_erro in (select distinct Mensagem from [dbo].[tb_dra_erros_recorrentes])
		--			and datediff(hour,erros.dec_dh_coleta,getdate()) < 1 )
				
		--	)
              --and rotas.CodigoRota = 'AT202404191CJDX'
	
		--union all

		--select
		--	cast(rotas.IdRota as varchar(30)) IdRota,
		--	rotas.DataReferencia,
		--	rotas.IdTransportadora,
		--	'App' Origem,
		--	isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) ServiceCenter,
		--	cast(case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end as decimal(18, 9)) Latitude,
		--	cast(case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end as decimal(18, 9)) Longitude,
		--	1 MarketPlace
		--from
		--	tb_ml_rotas rotas with(nolock)
		--	left join tb_dra_coleta_maps coleta with(nolock) on rotas.IdRota = coleta.dam_cd_rota 
		--												and rotas.DataReferencia = coleta.dam_dh_referencia
		--												and rotas.IdTransportadora = coleta.dam_cd_transportadora
		--												and coleta.dam_nm_origem = 'App'
		--												and coleta.dam_cd_marketplace = 1
		--	left join tb_ml_service_center svc with(nolock) on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc.svc_cd_service_center
		--	left join tb_ml_service_center svc2 with(nolock) on rotas.ServiceCenter = svc2.svc_cd_service_center
		--	left join tb_dra_erros_coleta erros with(nolock) on cast(rotas.IdRota as varchar(30)) = replace(
		--											replace(
		--												replace(
		--												replace(
		--													right(
		--														dec_ds_contexto,
		--														len(dec_ds_contexto) -
		--														charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,1)+1)+1)
		--													),
		--												'/Geo',''),
		--											'/Logistics',''),
		--										'/Shopee',''),
		--										'/App','')
		--and rotas.IdTransportadora = erros.dec_cd_transportadora and erros.dec_ds_tipo_coleta = 'SCRAPPER'
		--where
		--	coleta.dam_cd_coleta is null 
		--	--and rotas.TotalPacotes = rotas.PacotesEntregues + rotas.PacotesNaoEntregue
		--	and rotas.Excluido = 0
		--	and exists (select 1 from tb_ml_gps_maps_app p with(nolock) where rotas.IdRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		--	and rotas.DataReferencia < cast(getdate() as date)
		--	and case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end is not null and case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end is not null
		--	AND (erros.dec_cd_coleta is null 
		--	or (erros.dec_ds_erro in (select distinct Mensagem from [dbo].[tb_dra_erros_recorrentes])
		--			and datediff(hour,erros.dec_dh_coleta,getdate()) < 1 )
		--			--or  rotas.idrota = 116953852 
		--	)
		--	--and rotas.idrota in (select id from tb_insert)
	
		--union all	

		--select
		--	cast(rotas.IdRota as varchar(30)) IdRota,
		--	rotas.DataReferencia,
		--	rotas.IdTransportadora,
		--	'Geo' Origem,
		--	isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) ServiceCenter,
		--	cast(case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end as decimal(18, 9)) Latitude,
		--	cast(case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end as decimal(18, 9)) Longitude,
		--	1 MarketPlace
		--from
		--	tb_ml_rotas rotas with(nolock)
		--	left join tb_dra_coleta_maps coleta with(nolock) on rotas.IdRota = coleta.dam_cd_rota 
		--												and rotas.DataReferencia = coleta.dam_dh_referencia
		--												and rotas.IdTransportadora = coleta.dam_cd_transportadora
		--												and coleta.dam_nm_origem = 'Geo'
		--												and coleta.dam_cd_marketplace = 1
		--	left join tb_ml_service_center svc with(nolock) on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc.svc_cd_service_center
		--	left join tb_ml_service_center svc2 with(nolock) on rotas.ServiceCenter = svc2.svc_cd_service_center
		--	left join tb_dra_erros_coleta erros with(nolock) 
		--	on cast(rotas.IdRota as varchar(30)) = replace(
		--											replace(
		--											replace(
		--												replace(
		--													right(
		--														dec_ds_contexto,
		--														len(dec_ds_contexto) -
		--														charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,charindex('/',dec_ds_contexto,1)+1)+1)
		--													),
		--												'/Geo',''),
		--											'/Logistics',''),
		--										'/Shopee',''),
		--										'/App','')
		--	and rotas.IdTransportadora = erros.dec_cd_transportadora and erros.dec_ds_tipo_coleta = 'SCRAPPER'
		--where 1=1
		--	 and (coleta.dam_cd_coleta is null)
		--	--and rotas.TotalPacotes = rotas.PacotesEntregues + rotas.PacotesNaoEntregue
		--	and rotas.Excluido = 0
		--	and exists (select 1 from tb_ml_gps_maps_geo p with(nolock) where rotas.IdRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		--	and rotas.DataReferencia < cast(getdate() as date)
		--	and case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end is not null and case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end is not null
		--	and rotas.DataReferencia >= '2023-05-01'
		--	--and rotas.idrota in(115658369, 116359104, 115530962, 115900457)
		--	AND (erros.dec_cd_coleta is null 
		--	or (erros.dec_ds_erro in (select distinct Mensagem from [dbo].[tb_dra_erros_recorrentes])
		--			and datediff(hour,erros.dec_dh_coleta,getdate()) < 1 )
		--			-- or  rotas.idrota = 118442724 
		--	)
  --          -- and rotas.idrota = 118442724 
            
) as base
join tb_clientes as cli on base.IdTransportadora = cli.cli_id_logistics
	or base.IdTransportadora = cli.cli_id_shopee

where cli.cli_in_ativo = 1

--and IdTransportadora = 2087146923 -- somente ALC
and (base.DataReferencia >= cli.cli_dt_ini_ml or base.IdTransportadora <> cli.cli_id_logistics)
--and Origem = 'app'

GO
