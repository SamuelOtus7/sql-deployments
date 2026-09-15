-- ============================================================
-- BASELINE: dbo.vw_tabela_frete_adicional_transportadora
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tabela_frete_adicional_transportadora]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_tabela_frete_adicional_transportadora]
as
select
	trans.tpr_nome_transportadora Transportadora,
	trans.tpr_cd_transportadora IdTransportadora,
	veic.tvl_nm_tipo_veiculo TipoVeiculo,
	frete.bfa_cd_service_center ServiceCenter,
	frete.bfa_estado Estado,
	tipo01.ftc_nm_tipo_calculo TipoCalculoDomingo,
	frete.bfa_vl_adicional_domingo ValorDomingo,
	tipo02.ftc_nm_tipo_calculo TipoCalculoCicloPM,
	frete.bfa_vl_adicional_ciclo_pm ValorDescontoCicloPM,
	tipo03.ftc_nm_tipo_calculo TipoCalculoAjudante,
	frete.bfa_vl_adicional_ajudante ValorAjudante,
	tipo04.ftc_nm_tipo_calculo TipoCalculoRotaRisco,
	frete.bfa_vl_adicional_risco ValorRisco,
	frete.bfa_vl_paradas0_60,
	frete.bfa_vl_paradas61_90,
	frete.bfa_vl_paradas_acima_90,
	bfa_calcula_por_parada
from
	tb_fin_base_frete_adicional frete
	join tb_dra_transportadora trans on frete.bfa_cd_transportadora = trans.tpr_cd_transportadora
	join tb_dra_tipo_veiculo veic on frete.bfa_cd_tipo_veiculo = veic.tvl_cd_tipo_veiculo
	left join tb_fin_tipo_calculo tipo01 on frete.bfa_tipo_adicional_domingo = tipo01.ftc_cd_tipo_calculo
	left join tb_fin_tipo_calculo tipo02 on frete.bfa_tipo_adicional_ciclo_pm = tipo02.ftc_cd_tipo_calculo
	left join tb_fin_tipo_calculo tipo03 on frete.bfa_tipo_adicional_ajudante = tipo03.ftc_cd_tipo_calculo
	left join tb_fin_tipo_calculo tipo04 on frete.bfa_tipo_adicional_risco = tipo04.ftc_cd_tipo_calculo
GO
