-- ============================================================
-- BASELINE: dbo.vw_rotas_motoristas_vld
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_motoristas_vld]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_rotas_motoristas_vld]
as

select 
	 IdTransportadora
	,Base
	,ServiceCenter
	,IdRota
	,Data
	,Motorista
	,TipoVeiculo
	,UsouAPP
	,isnull(KmApp,0) as KmApp
	,LinkApp--case when isnull(KmApp,0) = 0 then null else LinkApp end as LinkApp
	,StatusRota
	,rgp_cd_usuario
	,case when UsouAPP  = 'Sim' and  (LinkApp = '0' or LinkApp is null) then 'Em Apuração' else 'Apurado' end as Apuracao

from (
select
	r.IdTransportadora,
	COALESCE(r.base, r.ServiceCenter) Base,
	--isnull(svc.svc_cd_service_center, r.ServiceCenter) ServiceCenter,
	r.ServiceCenter as ServiceCenter,
	r.IdRota,
	r.DataReferencia Data,
	r.NomeMotorista Motorista,
	r.TipoVeiculo,
	case when app.IdRota is not null and 
	(app.QuantidadeApontamento > 10 or geo.QuantidadeApontamento > 10) then 'Sim' else 'Não' end UsouAPP,

case when app.IdRota is not null 
	and (app.QuantidadeApontamento > 10 or geo.QuantidadeApontamento > 10)
	then KmColetado end KmApp,


case when app.IdRota is not null 
	and (app.QuantidadeApontamento > 10 or geo.QuantidadeApontamento > 10)
	then LinkMapa end LinkApp,

	--tr.tds_ds_traducao as StatusRota
	r.StatusRota,
	rgp_cd_usuario

from
	vw_rotas_vld r with(nolock)
	--left join tb_ml_traducoes tr on r.StatusRota = tr.tds_vl_json and tr.tds_nm_tabela = 'tb_ml_rotas' and tr.tds_nm_campo = 'statusrota'
	--left join tb_ml_service_center svc with(nolock) on r.ServiceCenter = svc.svc_cd_service_center
	--left join tb_ml_service_center svc2 with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
	--left join tb_dra_bases b with(nolock) on r.ServiceCenter = b.dab_cd_service_center and r.IdTransportadora = b.dab_cd_transportadora
	left join (
		select
			r.IdRota,
			r.IdTransportadora,
			r.DataReferencia,
			rgp_cd_usuario,
			count(1) QuantidadeApontamento
		from
			tb_ml_rotas r with(nolock)
			join tb_clientes as c with(nolock) on r.IdTransportadora = c.cli_id_logistics
			join (

					select 
						users.cli_cd_codigo_cliente as Transportadora,
						rgp_cd_usuario,
						users.usr_nm_usuario as Motorista,
						cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date) as Data
					from 
						tb_registro_gps as gps with(nolock)
						join tb_usuario as users with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario	

				) gps on c.cli_cd_codigo_cliente = gps.Transportadora 
					and r.NomeMotorista  = gps.Motorista
					and r.DataReferencia = gps.Data 

				where
					DataReferencia >= '2023-04-01'
				group by
					r.IdRota,
					r.IdTransportadora,
					r.DataReferencia,
					rgp_cd_usuario

	) app on r.IdTransportadora = app.IdTransportadora and r.DataReferencia = app.DataReferencia and r.IdRota = app.IdRota
	left join (
				select apg_cd_transportadora as IdTransportadora,
					   geo.DataReferencia as DataReferencia,
					   rotas.IdRota,
					   count(*) as QuantidadeApontamento 
				from tb_apontamento_geo as geo
					join (select DataReferencia, NomeMotorista, max(IdRota) as IdRota from tb_ml_rotas where Excluido = 0 group by DataReferencia, NomeMotorista) as rotas
					on geo.apg_cd_motorista = rotas.NomeMotorista
					and geo.DataReferencia = rotas.DataReferencia
				group by apg_cd_transportadora,
					     geo.DataReferencia,
					     rotas.IdRota
			  ) as Geo
	on r.IdTransportadora = Geo.IdTransportadora and r.DataReferencia = Geo.DataReferencia and r.IdRota = Geo.IdRota
where
	r.DataReferencia >= '2023-04-01'
	--and r.Excluido = 0
) as base


GO
