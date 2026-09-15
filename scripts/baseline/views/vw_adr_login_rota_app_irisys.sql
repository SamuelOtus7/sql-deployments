-- ============================================================
-- BASELINE: dbo.vw_adr_login_rota_app_irisys
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_adr_login_rota_app_irisys]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_adr_login_rota_app_irisys] as

select 
	cast(agp_dh_data_hora as date) as agp_dh_data_hora
	,mot_cd_cliente TenantID
	,agp_cd_usuario
	,count(*) qtd

from tb_acao_gps as a
inner join tb_motorista as b
on a.agp_cd_usuario = b.mot_cd_usuario

where agp_ds_acao = 'I'
and cast(agp_dh_data_hora as date) >= dateadd(month,-6,getdate())

group by 
cast(agp_dh_data_hora as date) 
,agp_cd_usuario
,mot_cd_cliente
GO
