-- ============================================================
-- BASELINE: dbo.vw_rotas_trevo_trevo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_trevo_trevo]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_rotas_trevo_trevo] as 

select 
	DataReferencia
	,cli_cd_codigo_cliente tenant 
	,a.idrota
	,bkt_cd_base_km_trevo
	,bkt_cd_transportadora
	,bkt_cd_service_center
	,latitude_svc
	,longitude_svc
	,bkt_nm_cidades
	,bkt_nm_ordem_ideal
	,bkt_vl_km_ideal
	,bkt_ds_link_google
	,bkt_qt_cidades
	,bkt_cidade_base

from tb_ml_rotas as a 

inner join tb_clientes as cli
on a.idtransportadora = cli_id_logistics

inner join (
				select* 
				from tb_fin_base_km_trevo with (nolock)
				where bkt_cd_transportadora = 2087146923
				) trevo
	  on a.idtrevo = trevo.bkt_cd_base_km_trevo

where excluido = 0
and StatusRota <> 'planned' 
and cli_cd_codigo_cliente = 1
GO
