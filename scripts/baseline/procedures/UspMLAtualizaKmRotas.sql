-- ============================================================
-- BASELINE: dbo.UspMLAtualizaKmRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaKmRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLAtualizaKmRotas]
as
begin

	update tb_dra_coleta_maps
	set dam_ds_km = replace(replace(dam_ds_km,'(',''),')','')
	where dam_in_processado = 0

	update
		tb_dra_coleta_maps
	set
		dam_vl_km = 
		
		case when charindex(',',REVERSE(dam_ds_km)) = 5 then cast(trim(replace(replace(replace(dam_ds_km,'km',''),'.',''),',','.')) as decimal(10, 5))
		else cast(trim(replace(replace(dam_ds_km,'km',''),',','')) as decimal(10, 5)) end

	from
		tb_dra_coleta_maps
	where
		dam_in_processado = 0
		and dam_ds_km like '%km%'
		and case when charindex(',',REVERSE(dam_ds_km)) = 5 then cast(trim(replace(replace(replace(dam_ds_km,'km',''),'.',''),',','.')) as decimal(10, 5))
		else cast(trim(replace(replace(dam_ds_km,'km',''),',','')) as decimal(10, 5)) end <> dam_vl_km

	
	

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
		and dam_cd_marketplace = 1

	update
		r
	set
		r.LinkMapa = m.dam_ds_url,
		r.KmColetado = isnull(m.dam_vl_km,0)
	from
		tb_ml_rotas r
		join #mapas m on r.IdRota = m.dam_cd_rota 
							and r.IdTransportadora = m.dam_cd_transportadora
							and r.DataReferencia = m.dam_dh_referencia
	where
		isnull(m.dam_nm_origem,'Logistics') = 'Logistics'

	update
		r
	set
		r.LinkMapaApp = m.dam_ds_url,
		r.KmColetadoApp = isnull(m.dam_vl_km,0)
	from
		tb_ml_rotas r
		join #mapas m on r.IdRota = m.dam_cd_rota 
							and r.IdTransportadora = m.dam_cd_transportadora
							and r.DataReferencia = m.dam_dh_referencia
	where
		m.dam_nm_origem = 'App'


	update
		r
	set
		r.LinkMapaGeo = m.dam_ds_url,
		r.KmColetadoGeo = isnull(m.dam_vl_km,0)
	from
		tb_ml_rotas r
		join #mapas m on r.IdRota = m.dam_cd_rota 
							and r.IdTransportadora = m.dam_cd_transportadora
							and r.DataReferencia = m.dam_dh_referencia
	where
		m.dam_nm_origem = 'Geo'
							
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
