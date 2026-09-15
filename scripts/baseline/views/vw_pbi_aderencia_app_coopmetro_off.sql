-- ============================================================
-- BASELINE: dbo.vw_pbi_aderencia_app_coopmetro_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_aderencia_app_coopmetro_off]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_pbi_aderencia_app_coopmetro_off]
as
select DataReferencia,
	   NomeMotorista,
	   ServiceCenter,
	   coalesce(b.dab_nm_base,svc.svc_cd_service_center,rotas.ServiceCenter) Base,
	   isnull(KmColetado,0) as KmColetado,
	   isnull(LinkMapa,'') as LinkMapa,
	   isnull(Apontamentos,0) as Apontamentos,
	   case when Apontamentos is null then 0 else 1 end as StatusApontamento,
	   case when acesso.Motorista is not null then 'Sim' else 'Não' end PossuiUsuario,
	   acesso.UltimoAcesso
	  
from tb_ml_rotas as rotas
	left join tb_ml_service_center svc on rotas.ServiceCenter = svc.svc_cd_service_center
	left join tb_ml_service_center svc2 on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc2.svc_cd_service_center
	left join tb_dra_bases b on svc2.svc_cd_service_center = b.dab_cd_service_center and rotas.IdTransportadora = b.dab_cd_transportadora
	left join 	 (
					select 1070423464 as Transportadora,
						   users.usr_nm_usuario as Motorista,
						   cast(gps.rgp_dh_data_hora as date) as Data,
						   count(*) as Apontamentos,
						   min(gps.rgp_dh_data_hora) as Abertura,
						   max(gps.rgp_dh_data_hora) as Encerramento
					from db_PlayTelematics.dbo.tb_registro_gps as gps
						join db_PlayTelematics.dbo.tb_usuario as users on gps.rgp_cd_usuario = users.usr_cd_usuario
					group by users.usr_nm_usuario,
							 cast(gps.rgp_dh_data_hora as date),
							 users.cli_cd_codigo_cliente
				) as base
	on rotas.IdTransportadora = base.Transportadora 
	and rotas.NomeMotorista = base.Motorista
	and rotas.DataReferencia = base.Data
	left join 	 (
					select 1070423464 as Transportadora,
						   users.usr_nm_usuario as Motorista,
						   max(gps.rgp_dh_data_hora) as UltimoAcesso
					from db_PlayTelematics.dbo.tb_usuario as users
						left join db_PlayTelematics.dbo.tb_registro_gps as gps on gps.rgp_cd_usuario = users.usr_cd_usuario
					group by users.usr_nm_usuario,
							 users.cli_cd_codigo_cliente
				) as acesso
	on rotas.IdTransportadora = acesso.Transportadora 
	and rotas.NomeMotorista = acesso.Motorista
	
where rotas.Excluido = 0
	  and rotas.IdTransportadora = 1070423464
	  and NomeMotorista not in ('','-')
	 
GO
