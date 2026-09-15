-- ============================================================
-- BASELINE: dbo.vw_tabela_frete_transportadora
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tabela_frete_transportadora]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_tabela_frete_transportadora]
as
select
	trans.tpr_nome_transportadora Transportadora,
	trans.tpr_cd_transportadora IdTransportadora,
	veic.tvl_nm_tipo_veiculo TipoVeiculo,
	frete.bft_cd_service_center ServiceCenter,
	frete.bft_estado Estado,
	frete.bft_vl_inicio_faixa InicioFaixa,
	frete.bft_vl_fim_faixa FimFaixa,
	frete.bft_vl_frete ValorFrete
from
	tb_fin_base_frete_transportadora frete
	join tb_dra_transportadora trans on frete.bft_cd_transportadora = trans.tpr_cd_transportadora
	join tb_dra_tipo_veiculo veic on frete.bft_cd_tipo_veiculo = veic.tvl_cd_tipo_veiculo
GO
