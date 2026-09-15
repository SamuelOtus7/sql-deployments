-- ============================================================
-- BASELINE: dbo.vw_fin_base_frete_transportadora
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_base_frete_transportadora]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_fin_base_frete_transportadora]
as

select
	base.bft_cd_base_frete_transportadora
	,base.bft_cd_transportadora
	,base.bft_cd_service_center
	,base.bft_estado
	,base.bft_cd_tipo_veiculo
	,base.bft_vl_inicio_faixa
	,base.bft_vl_fim_faixa
	,base.bft_vl_frete
	,base.bft_cd_codigo_cliente
	,base.bft_data_inicio
	,base.bft_data_fim
	,base.bft_nm_cidade
	,base.bft_vl_frete_pm
	,base.bft_cd_operacao
	,lista.lst_ds_valor Operacao
from
	tb_fin_base_frete_transportadora base with(nolock)
	join tb_lista lista with(nolock) on base.bft_cd_operacao = lista.lst_cd_lista
where bft_data_fim_vigencia is null
GO
