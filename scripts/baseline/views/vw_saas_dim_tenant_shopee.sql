-- ============================================================
-- BASELINE: dbo.vw_saas_dim_tenant_shopee
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_dim_tenant_shopee]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_saas_dim_tenant_shopee]
as
select 
	cli_cd_codigo_cliente TenantId
	,cli_ds_nome Tenant
	,cli_id_shopee ShopeeId
from 
	tb_clientes
where 
	cli_in_ativo = 1
	and cli_id_shopee > 0
GO
