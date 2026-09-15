-- ============================================================
-- BASELINE: dbo.vw_acao_gps
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_acao_gps]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_acao_gps] as 

select 
	 cast(agp_dh_data_hora as date) as Data
	,agp_dh_data_hora as DataHora
	,dateadd(hour,-3,Timestamp) as Timestamps
	,datediff(minute,dateadd(hour,-3,Timestamp) ,agp_dh_data_hora) diferenca
	,agp_cd_usuario as UsuarioIrisys
	,usr_nm_usuario as Nome
	,case 
		when agp_ds_acao = 'I' THEN 'Inicio' 
		when agp_ds_acao = 'F' THEN 'Fim' 
			else null end Acao
	,agp_ds_uuid CodAparelho
	,cli_cd_codigo_cliente Tenant
from tb_acao_gps as a with(nolock)
inner join tb_usuario as b with(nolock)
on agp_cd_usuario = usr_cd_usuario
where cast(agp_dh_data_hora as date) >= cast(dateadd(month,-2,getdate()) as date) 
GO
