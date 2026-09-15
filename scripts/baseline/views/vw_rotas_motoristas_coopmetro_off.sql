-- ============================================================
-- BASELINE: dbo.vw_rotas_motoristas_coopmetro_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_motoristas_coopmetro_off]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_rotas_motoristas_coopmetro_off]
as
select
	r.IdTransportadora,
	COALESCE(b.dab_nm_base, svc2.svc_cd_service_center, svc.svc_cd_service_center) Base,
	r.OrigemSaida XPT,
	r.IdRota,
	r.DataReferencia Data,
	r.NomeMotorista Motorista,
	r.TipoVeiculo,
	case when app.IdRota is null then 'Não' else 'Sim' end UsouAPP,
	r.KmColetadoApp KmApp,
	r.LinkMapaApp LinkApp	
from
	tb_ml_rotas r
	left join tb_ml_service_center svc with(nolock) on r.ServiceCenter = svc.svc_cd_service_center
	left join tb_ml_service_center svc2 on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
	left join tb_dra_bases b on svc2.svc_cd_service_center = b.dab_cd_service_center and r.IdTransportadora = b.dab_cd_transportadora
	left join (
		select
			r.IdRota,
			r.IdTransportadora,
			r.DataReferencia,
			count(1) QuantidadeApontamento
		from
			tb_ml_rotas r
			join db_PlayTelematics.dbo.tb_clientes as c on r.IdTransportadora = c.cli_id_logistics
			join (
				select 
					users.cli_cd_codigo_cliente as Transportadora,
					users.usr_nm_usuario as Motorista,
					cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date) as Data
				from 
					db_PlayTelematics.dbo.tb_registro_gps as gps
					join db_PlayTelematics.dbo.tb_usuario as users on gps.rgp_cd_usuario = users.usr_cd_usuario	
			) gps on c.cli_cd_codigo_cliente = gps.Transportadora 
					and r.NomeMotorista = gps.Motorista
					and r.DataReferencia = gps.Data 
		where
			r.DataReferencia >= '2023-04-01'
			and r.IdTransportadora = 1070423464
		group by
			r.IdRota,
			r.IdTransportadora,
			r.DataReferencia
	) app on r.IdTransportadora = app.IdTransportadora and r.DataReferencia = app.DataReferencia and r.IdRota = app.IdRota
where
	r.DataReferencia >= '2023-04-01'
	and r.Excluido = 0
	and r.IdTransportadora = 1070423464
GO
