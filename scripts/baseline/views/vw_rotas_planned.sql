-- ============================================================
-- BASELINE: dbo.vw_rotas_planned
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_planned]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_rotas_planned]
as
select 
distinct 
	r.IdTransportadora,
	r.Id,
	r.IdRota,
	r.DataReferencia ,
	r.DataHoraInicio,
	isnull(t2.tds_ds_traducao,r.StatusRota) as StatusRota,
	t4.tds_ds_traducao SubStatusRota,
	isnull(svc.svc_cd_service_center,r.ServiceCenter) ServiceCenter,
	svc.svc_nm_service_center NomeServiceCenter,
	coalesce(svc.svc_cd_service_center,r.ServiceCenter) Base,
	svc.svc_nm_cidade CidadeBase,
	r.TipoOrigemSaida,
	r.OrigemSaida,
	r.TipoRota,
	r.TotalPacotes,
	r.TempoEmRota,
	r.TempoChegadaAreaEntrega,
	r.TempoAreaEntrega,
	r.QuantidadePontos,
	r.QuantidadeParadas,
	format(r.DataHoraInicio, 'HH:mm') AS HoraInicio,
	case when DATEPART(hour,r.DataHoraInicio) <= 12 then 'AM' ELSE 'PM' end Ciclo
from
	tb_ml_rotas r with(nolock)
	join tb_clientes cli with(nolock) on r.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1 and cli.cli_cd_codigo_cliente <> 7
	left join tb_ml_traducoes t1 on r.NivelExperienciaMotorista = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_ml_rotas' and t1.tds_nm_campo = 'NivelExperienciaMotorista'
	left join tb_ml_traducoes t2 on r.StatusRota = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_rotas' and t2.tds_nm_campo = 'StatusRota'
	left join tb_ml_traducoes t3 on r.StatusPrazo = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_rotas' and t3.tds_nm_campo = 'StatusPrazo'
	left join tb_ml_traducoes t4 on r.SubStatusRota = t4.tds_vl_json and t4.tds_nm_tabela = 'tb_ml_rotas' and t4.tds_nm_campo = 'SubStatusRota'
	left join tb_ml_service_center svc 
	on r.ServiceCenter = svc.svc_cd_service_center and r.idtransportadora = svc.idtransportadora

	left join tb_ml_service_center svc2 
	on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
	and r.idtransportadora = svc2.idtransportadora

	where r.excluido = 0
	and r.StatusRota = 'planned'
GO
