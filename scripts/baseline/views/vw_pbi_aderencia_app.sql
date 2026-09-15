-- ============================================================
-- BASELINE: dbo.vw_pbi_aderencia_app
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_aderencia_app]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_pbi_aderencia_app]
as
select DataReferencia,
	   NomeMotorista,
	   ServiceCenter,
	   coalesce(b.dab_nm_base,svc.svc_cd_service_center,rotas.ServiceCenter) Base,
	   isnull(KmColetado,0) as KmColetado,
	   isnull(LinkMapa,'') as LinkMapa,
	   clientes.cli_cd_codigo_cliente as TenantId,
	   isnull(Apontamentos,0) as Apontamentos,
	   case when Apontamentos is null then 0 else 1 end as StatusApontamento,
	   case when acesso.UsuarioDA is not null then 'Sim' else 'Não' end PossuiUsuario,
	   acesso.UltimoAcesso
	  
from tb_ml_rotas as rotas with(nolock)
	left join tb_ml_service_center svc with(nolock) on rotas.ServiceCenter = svc.svc_cd_service_center
	left join tb_ml_service_center svc2 with(nolock) on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc2.svc_cd_service_center
	left join tb_dra_bases b with(nolock) on svc2.svc_cd_service_center = b.dab_cd_service_center and rotas.IdTransportadora = b.dab_cd_transportadora

	inner join tb_clientes as clientes with(nolock) on rotas.IdTransportadora = clientes.cli_id_logistics
	left join 	 (
					select users.cli_cd_codigo_cliente as Transportadora,
						   --users.usr_nm_usuario as Motorista,
						   users.usr_cd_usuario as UsuarioDA,
						   cast(gps.rgp_dh_data_hora as date) as Data,
						   count(*) as Apontamentos,
						   min(gps.rgp_dh_data_hora) as Abertura,
						   max(gps.rgp_dh_data_hora) as Encerramento
					from tb_registro_gps as gps with(nolock)
						join tb_usuario as users with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario
					group by --users.usr_nm_usuario,
							 users.usr_cd_usuario,
							 cast(gps.rgp_dh_data_hora as date),
							 users.cli_cd_codigo_cliente
				) as base
	on clientes.cli_cd_codigo_cliente = base.Transportadora 
	--and rotas.NomeMotorista = base.Motorista
	and rotas.UsuarioDA = base.UsuarioDA
	and rotas.DataReferencia = base.Data
	left join 	 (
					select users.cli_cd_codigo_cliente as Transportadora,
						   --users.usr_nm_usuario as Motorista,
						   users.usr_cd_usuario as UsuarioDA,
						   max(gps.rgp_dh_data_hora) as UltimoAcesso
					from tb_usuario as users with(nolock)
						left join tb_registro_gps as gps with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario
					group by users.usr_cd_usuario, --users.usr_nm_usuario,
							 users.cli_cd_codigo_cliente
				) as acesso
	on clientes.cli_cd_codigo_cliente = acesso.Transportadora 
	--and rotas.NomeMotorista = acesso.Motorista
	and rotas.UsuarioDA = acesso.UsuarioDA
	
where rotas.Excluido = 0
	  and NomeMotorista not in ('','-')
	  and rotas.DataReferencia >= clientes.cli_dt_ini_geo
GO
