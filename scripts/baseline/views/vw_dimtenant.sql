-- ============================================================
-- BASELINE: dbo.vw_dimtenant
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dimtenant]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_dimtenant] as 

select  
	 cli_cd_codigo_cliente TenantId,  
	 cli_ds_nome Tenant,  
	 cli_id_logistics LogisticsId,  
	 cli_id_shopee ShopeeId  
from  
	tb_clientes cli  
where  
	cli_cd_codigo_cliente <> 7  
  --and cli_id_logistics > 0 
  and cli_in_ativo = 1
GO
