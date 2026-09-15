-- ============================================================
-- BASELINE: dbo.vw_adr_irs_envios_status_evios_whats
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_adr_irs_envios_status_evios_whats]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_adr_irs_envios_status_evios_whats] as

select 
er_cd_codigo_cliente as TenantId --chave para a tabela de tenant
,er_in_desativado
,er_in_excluido
,count(*) qtd
from tb_envio_relatios
group by er_cd_codigo_cliente --chave para a tabela de tenant
,er_in_desativado
,er_in_excluido
GO
