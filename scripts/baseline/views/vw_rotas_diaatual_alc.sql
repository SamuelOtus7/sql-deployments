-- ============================================================
-- BASELINE: dbo.vw_rotas_diaatual_alc
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_diaatual_alc]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_rotas_diaatual_alc]
as
select 
	r.*--,
	--b.dab_nm_base Base,
	--b.dab_nm_cidade CidadeBase
from
	vw_rotas_diaatual r
	--left join tb_ml_service_center svc on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
	--left join tb_dra_bases b on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = 2087146923
where
	r.IdTransportadora = 2087146923
	and isnull(r.TipoOrigemSaida,'') <> 'delivery_cell'
GO
