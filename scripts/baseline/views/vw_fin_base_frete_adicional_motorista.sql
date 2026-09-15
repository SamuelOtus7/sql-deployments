-- ============================================================
-- BASELINE: dbo.vw_fin_base_frete_adicional_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_base_frete_adicional_motorista]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vw_fin_base_frete_adicional_motorista]
as
select
	base.bfa_cd_base_frete_adicional_motorista
	,base.bfa_cd_transportadora
	,base.bfa_cd_service_center
	,base.bfa_nm_cidade
	,base.bfa_cd_tipo_veiculo
	,base.bfa_tipo_adicional_domingo
	,base.bfa_vl_adicional_domingo
	,base.bfa_tipo_adicional_ciclo_pm
	,base.bfa_vl_adicional_ciclo_pm
	,base.bfa_vl_paradas0_60
	,base.bfa_vl_paradas61_75
	,base.bfa_vl_paradas76_85
	,base.bfa_vl_paradas86_90
	,base.bfa_vl_paradas_acima_90
	,base.bfa_tipo_adicional_ajudante
	,base.bfa_vl_adicional_ajudante
	,base.bfa_tipo_adicional_risco
	,base.bfa_vl_adicional_risco
	,base.bfa_calcula_por_parada
	,base.bfa_vl_adicional
	,base.bfa_tipo_adicional_pool
	,base.bfa_cd_tipo_contrato
	,base.bfa_tipo_insucesso
	,base.bfa_cd_insucesso
	,base.bfa_vl_insucesso
	,base.bfa_cd_dias_insentos
	,base.bfa_cd_pacote_ajudante
	,base.bfa_cd_pacote_ajudante_area_risco
	,base.bfa_cd_codigo_cliente
	,base.bfa_vl_adicional_recarga
	,base.bfa_vl_sdd
	,base.bfa_vl_adicional_km100
	,base.bfa_tipo_adicional_recarga
	,base.bfa_vl_qtd_pacote
	,base.bfa_qtd_pacote
	,base.bfa_vl_bonus_ds
	,base.bfa_tipo_desconto_flex_frota
	,base.bfa_vl_valor_desconto_flex_frota
	,base.bfa_tipo_desconto_cartao_flex_frota
	,base.bfa_vl_valor_desconto_cartao_flex_frota
	,base.bfa_data_inicio_vigencia
	,base.bfa_data_fim_vigencia
	,base.bfa_tipo_adicional_feriado
	,base.bfa_vl_adicional_feriado
	,base.bfa_cd_operacao
	,lista.lst_ds_valor Operacao
	,base.bfa_cd_ambulancia_primeira_faixa
	,base.bfa_vl_adicional_pedagio
	,base.bfa_qtd_pacote_ambulancia
	,base.bfa_vl_pacote_ambulancia
	,base.bfa_ds_placa
from
	tb_fin_base_frete_adicional_motorista base with(nolock)
	join tb_lista lista with(nolock) on base.bfa_cd_operacao = lista.lst_cd_lista
GO
