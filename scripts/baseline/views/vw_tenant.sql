-- ============================================================
-- BASELINE: dbo.vw_tenant
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tenant]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_tenant] as

select  
 cli_cd_codigo_cliente TenantId,  
 cli_ds_nome Tenant,  
 cli_id_logistics LogisticsId  ,
 cli_id_shopee IdShopee

from  
 tb_clientes cli  
where 1=1  
 --and cli_id_logistics <> 0  
 and cli_cd_codigo_cliente <> 7  
GO
