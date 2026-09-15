-- ============================================================
-- BASELINE: dbo.Vw_vlid_fin_base_km_trevo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[Vw_vlid_fin_base_km_trevo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[Vw_vlid_fin_base_km_trevo] as

select 

	 count(*) as total

	,sum(case when bkt_vl_km_ideal > 0 then 1 else 0 end) as Km

	,sum(case when 
				 bkt_qt_cidades between 2 and 4
				and bkt_vl_km_ideal = 0
				--and bkt_in_processamento = 1
	then 1 else 0 end) as KmZerado

	,(sum(case when 
				 bkt_qt_cidades between 2 and 4
				and bkt_vl_km_ideal = 0
				--and bkt_in_processamento = 1 
	then 1 else 0 end) / cast(count(*) as decimal(10,2)) ) * 100 as Percentual

from tb_fin_base_km_trevo
where bkt_cd_transportadora =  2087146923
GO
