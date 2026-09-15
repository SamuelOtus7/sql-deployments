-- ============================================================
-- BASELINE: dbo.vw_getServiceCenter
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_getServiceCenter]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_getServiceCenter] as 

select 
	svc_cd_service_center as svc
	, Longitude
	, Latitude 
	, idtransportadora

from tb_ml_service_center 
--where svc_cd_service_center = '${svc}'
--and idtransportadora = '$transportadora'

union all

select 
 bss_ds_nome
,bss_dc_latitude	
,bss_dc_longitude
,bss_cd_idtransportadora

from tb_bases 
where bss_ds_marketplace = 'Shopee'
--where NomeStation = '${svc}'
GO
