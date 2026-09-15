-- ============================================================
-- BASELINE: dbo.vw_service_center_transportadora
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_service_center_transportadora]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
CREATE view [dbo].[vw_service_center_transportadora]
as
-- select 
-- 	distinct
-- 	cli.cli_cd_codigo_cliente CodigoCliente,
-- 	isnull(svc2.svc_cd_service_center,svc.svc_cd_service_center) ServiceCenter
-- from
-- 	tb_ml_rotas r with(nolock)
-- 	left join tb_ml_service_center svc with(nolock) on r.ServiceCenter = svc.svc_cd_service_center
-- 	left join tb_ml_service_center svc2 with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
-- 	join tb_clientes cli with(nolock) on r.IdTransportadora = cli.cli_id_logistics
-- where
-- 	r.Excluido = 0
-- 	and r.DataReferencia >= dateadd(month,-2,cast(getdate() as date))
-- 	and isnull(svc2.svc_cd_service_center,svc.svc_cd_service_center) is not null



select distinct 
bss_cod_cliente as CodigoCliente
, bss_ds_sigla as ServiceCenter
from tb_bases
where bss_ds_marketplace = 'Mercado Livre'

union all 

select distinct
bss_cod_cliente as CodigoCliente
, bss_ds_nome as ServiceCenter
from tb_bases
where bss_ds_marketplace = 'Shopee'

GO
