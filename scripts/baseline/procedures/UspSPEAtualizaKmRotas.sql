-- ============================================================
-- BASELINE: dbo.UspSPEAtualizaKmRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEAtualizaKmRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPEAtualizaKmRotas]
as
begin

	update tb_dra_coleta_maps
	set dam_ds_km = replace(replace(dam_ds_km,'(',''),')','')
	where dam_in_processado = 0

	update
		tb_dra_coleta_maps
	set
		dam_vl_km = 
		
		case when charindex(',',REVERSE(dam_ds_km)) = 5 then cast(replace(replace(replace(dam_ds_km,' km',''),'.',''),',','.') as decimal(10, 5))
		else cast(replace(replace(dam_ds_km,' km',''),',','') as decimal(10, 5)) end
	from
		tb_dra_coleta_maps
	where
		dam_in_processado = 0
		and dam_ds_km like '%km%'
		and case when charindex(',',REVERSE(dam_ds_km)) = 5 then cast(replace(replace(replace(dam_ds_km,' km',''),'.',''),',','.') as decimal(10, 5))
		else cast(replace(replace(dam_ds_km,' km',''),',','') as decimal(10, 5)) end <> dam_vl_km

	
	

	drop table if exists #mapas
	select
		dam_cd_coleta,
		dam_cd_transportadora,
		dam_dh_referencia,
		dam_cd_rota,
		dam_ds_url,
		case when dam_ds_km like '% m' then dam_vl_km / 1000 else dam_vl_km end dam_vl_km,
		dam_nm_origem
		into #mapas
	from
		tb_dra_coleta_maps
	where
		dam_in_processado = 0
		and dam_cd_marketplace = 2

	update
		r
	set
		r.LinkMapa = m.dam_ds_url,
		r.KmColetado = isnull(m.dam_vl_km,0)
	from
		tb_spe_rotas_novo r
		join #mapas m on r.CodigoRota = m.dam_cd_rota 
							and r.IdTransportadora = m.dam_cd_transportadora
							and r.DataReferencia = m.dam_dh_referencia
	where
		isnull(m.dam_nm_origem,'Shopee') = 'Shopee'

	
	update
		r
	set
		r.LinkMapa = m.dam_ds_url,
		r.KmColetado = isnull(m.dam_vl_km,0)
	from
		tb_spe_rotas_v4 r
		join #mapas m on r.CodigoRota = m.dam_cd_rota 
							and r.IdTransportadora = m.dam_cd_transportadora
							and r.DataReferencia = m.dam_dh_referencia
	where
		isnull(m.dam_nm_origem,'Shopee') = 'Shopee'

							
	update
		maps
	set
		dam_in_processado = 1,
		dam_dh_processamento = getdate()
	from
		tb_dra_coleta_maps maps
		join #mapas t on maps.dam_cd_coleta = t.dam_cd_coleta

								

	


end
GO
