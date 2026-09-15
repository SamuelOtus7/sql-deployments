-- ============================================================
-- BASELINE: dbo.vw_tenant_mktplace
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tenant_mktplace]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[vw_tenant_mktplace]
as

select
	cli_cd_codigo_cliente TenantId,
	cli_ds_nome Tenant,
	cli_id_logistics LogisticsId,
    'Meli' as Mktplace
from
	tb_clientes cli
where
	cli_id_logistics <> 0
	and cli_cd_codigo_cliente <> 7

union all

select
	cli_cd_codigo_cliente TenantId,
	cli_ds_nome Tenant,
    cli_id_shopee ShopeeId,
    'Shopee' as Mktplace
from
	tb_clientes cli
where
	cli_id_shopee <> 0
	and cli_cd_codigo_cliente <> 7



GO
