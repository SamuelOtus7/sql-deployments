-- ============================================================
-- BASELINE: dbo.vw_adr_irs_qtd_envios_whats
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_adr_irs_qtd_envios_whats]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_adr_irs_qtd_envios_whats] as


select 
er_cd_codigo_cliente TenantId
,cast(ler_dh_envio as date) as data
,sum(case when ler_ds_status_envio = 'Enviar relatório' then 1 else 0 end) as QtdEnvios
,sum(case when ler_ds_status_envio <> 'Enviar relatório' then 1 else 0 end) as QtdFalhas 

from tb_log_envios_relatorios  as a with(nolock)
inner join tb_envio_relatios as b with(nolock)
on ler_cd_envio_relatorio = er_cd_envio_relatorio

where cast(ler_dh_envio as date) >= DATEADD(MONTH,-8,getdate())

group by er_cd_codigo_cliente
,cast(ler_dh_envio as date)
GO
