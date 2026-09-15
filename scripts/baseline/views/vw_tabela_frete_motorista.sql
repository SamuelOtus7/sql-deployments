-- ============================================================
-- BASELINE: dbo.vw_tabela_frete_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tabela_frete_motorista]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_tabela_frete_motorista]
as
select 
	t.tpr_cd_transportadora IdTransportadora,
	t.tpr_nome_transportadora Transportadora,
	m.bfm_cd_service_center ServiceCenter,
	v.tvl_nm_tipo_veiculo TipoVeiculo,
	m.bfm_vl_inicio_faixa InicioFaixa,
	m.bfm_vl_fim_faixa FimFaixa,
	m.bfm_vl_frete ValorFrete,
	m.bfm_vl_frete_pm ValorFretePM
from 
	tb_fin_base_frete_motorista m
	join tb_dra_tipo_veiculo v on m.bfm_cd_tipo_veiculo = v.tvl_cd_tipo_veiculo
	join tb_dra_transportadora t on m.bfm_cd_transportadora = t.tpr_cd_transportadora
GO
