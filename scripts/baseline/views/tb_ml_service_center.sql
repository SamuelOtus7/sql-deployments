-- ============================================================
-- BASELINE: dbo.tb_ml_service_center
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[tb_ml_service_center]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  view  [dbo].[tb_ml_service_center] as 

select    
bss_cd_idtransportadora idtransportadora
,bss_ds_sigla	svc_cd_service_center
,bss_ds_sigla	svc_nm_service_center
,bss_ds_nome	svc_nm_sigla
,bss_ds_regiao  svc_nm_region
,bss_dc_latitude  Latitude
,bss_dc_longitude Longitude
, case when bss_in_xpt = 1 then 'XPT' else null end svc_tipo
,bss_ds_cidade svc_nm_cidade
,bss_ds_estado svc_nm_estado 
,bss_in_status  svc_in_ativo
,bss_ds_label 
,bss_origem_base svc_ds_origem_base
,bss_in_ambulancia svc_in_ambulancia

from tb_bases nolock
where bss_ds_marketplace = 'Mercado Livre'
and bss_in_status = 1 
and bss_in_excluido = 0
GO
