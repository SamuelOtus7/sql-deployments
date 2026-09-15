-- ============================================================
-- BASELINE: dbo.vw_conferencia_carga
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_conferencia_carga]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_conferencia_carga] as   



select   

    list.lst_ds_valor as StatusRota  
   ,cfr_cd_conferencia_cargas   
   ,isnull(bss_ds_nome,case when servicecenter <> origemsaida then origemsaida else servicecenter end ) as Base  
   ,cfr_nr_rota_lm as RotaLm  
   ,cfr_ds_cluster cluster
   ,cfr_nr_rota_lh as RotaLh  
   ,cfp_ds_pacote  as IdPacote 
   ,cfr_cd_cliente as TenantId  
   ,listpct.lst_ds_valor as StatusPacote  
   ,cast(cfp_dh_conferencia as date) as DataConferencia  
   ,cfp_cd_usuario_conferencia as UsuarioConferencia
   ,usr_nm_usuario NomeUsuario
   ,cfp_nr_gaiola as NrGaiola  
   ,cfr_dh_inicio_conferencia as InicioConferencia  
   ,cfr_dh_fim_conferencia as FimConferencia  
   --,rota.*   

from [dbo].[tb_conferencia_cargas] as rota  

inner join tb_lista as list  
on cfr_cd_status_conferencia = lst_cd_lista  

left join [dbo].[tb_conferencia_cargas_pacotes] as b  
on cfr_cd_conferencia_cargas = cfp_cd_conferencia_cargas  
and cfp_cd_cliente = cfr_cd_cliente  

inner join tb_lista as listpct  
on cfp_cd_status_pacote = listpct.lst_cd_lista  

left join tb_bases as base  
on cfr_cd_base = bss_cd_base

left join
tb_usuario
on cfp_cd_usuario_conferencia = usr_cd_usuario

inner join tb_ml_rotas as rt
on rt.idrota = cfr_nr_rota_lm

where 
cfr_dh_inicio_conferencia >= DATEADD(DAY, -120, GETDATE())



GO
