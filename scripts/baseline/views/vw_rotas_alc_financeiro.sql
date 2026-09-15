-- ============================================================
-- BASELINE: dbo.vw_rotas_alc_financeiro
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_alc_financeiro]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_rotas_alc_financeiro]
as
select
	b.dab_nm_base Base,
	r.DataReferencia Data,
	r.Placa,
	r.NomeMotorista Motorista,
	null Destino,
	r.IdRota RotaLogistics,
	r.TipoRota Cluster,
	r.TipoVeiculo,
	r.TotalPacotes QuantidadePacotes,
	r.QuantidadeParadas,
	null PgtoSaida,
	null PgtoParadas,
	null Adicional,
	r.KmColetado,
	r.LinkMapa,
	bf.fbf_vl_faixa_ate_km FaixaKm,
	bf.fbf_vl_frete_km RecebMeli,
	
	case when r.QuantidadeParadas > 60 then 60 else r.QuantidadeParadas end * bf.fbf_vl_paradas0_60
	+
	case when r.QuantidadeParadas > 60 then case when r.QuantidadeParadas >= 90 then 30 else r.QuantidadeParadas - 60 end else 0 end * bf.fbf_vl_paradas61_90
	+
	case when r.QuantidadeParadas > 90 then r.QuantidadeParadas - 90 else 0 end * bf.fbf_vl_paradas_acima_90 RecebimentoParadas,

	null Pedagio,
	null ReceitaTotal, --fazer das colunas depois
	case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end CicloPM
from
	tb_ml_rotas r with(nolock)
	join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
	join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
	join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
	join tb_fin_base_frete bf with(nolock) on b.dab_cd_base = bf.fbf_cd_base 
								and bf.fbf_cd_classificacao_veiculo = tv.tvl_cd_classificacao_veiculo
								and r.KmColetado <= bf.fbf_vl_faixa_ate_km 
								and fbf_vl_faixa_ate_km = (
															select
																min(fbf_vl_faixa_ate_km) fbf_vl_faixa_ate_km
															from
																tb_fin_base_frete frete with(nolock)
															where
																frete.fbf_cd_base = bf.fbf_cd_base
																and frete.fbf_cd_classificacao_veiculo = bf.fbf_cd_classificacao_veiculo
																and r.KmColetado <= frete.fbf_vl_faixa_ate_km 
														)
where
	r.Excluido = 0
	and r.IdTransportadora = 2087146923
	and isnull(r.TipoOrigemSaida,'') <> 'delivery_cell'
	and r.DataReferencia between '2023-02-15' and '2023-02-28'
	and r.DataReferencia = (
		select
			max(DataReferencia)
		from
			 tb_ml_rotas r2 with(nolock)
		where
			r.IdRota = r2.IdRota
			and r.IdTransportadora = r2.IdTransportadora
	)
	

	
GO
