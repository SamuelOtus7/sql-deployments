-- ============================================================
-- BASELINE: dbo.vw_log_envios_relatorios
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_log_envios_relatorios]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[vw_log_envios_relatorios] as 

SELECT  
ler_cd_log_envio
,cli_cd_codigo_cliente tenantid
,ler_dh_envio
,CAST(ler_dh_envio AS DATE)       AS DataEnvio
,CAST(ler_dh_envio AS TIME)       AS HoraCompleta
,DATEPART(HOUR, ler_dh_envio)     AS Hora
,ler_ds_status_envio
,case when ler_ds_status_envio not in ('Enviar mensagem','Enviar relatório') then 'Mensagem de Erro' else ler_ds_status_envio end StatusGrafico
,rel_ds_nome
,ler_cd_transportadora
,ler_cd_envio_relatorio
,er_dt_ultima_execucao	
,er_dt_proxima_execucao


FROM [db_Irisys].[dbo].[tb_log_envios_relatorios] as a
inner join tb_clientes as b
on ler_cd_transportadora = cli_id_logistics
inner join tb_relatorios as c
on ler_cd_relatorio = rel_cd_relatorio
inner join [dbo].[tb_envio_relatios] as d
on er_cd_envio_relatorio = ler_cd_envio_relatorio

where cli_in_ativo  = 1
and ler_dh_envio >= dateadd(HOUR,-24,getdate())


  
GO
