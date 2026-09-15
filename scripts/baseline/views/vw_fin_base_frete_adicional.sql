-- ============================================================
-- BASELINE: dbo.vw_fin_base_frete_adicional
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_base_frete_adicional]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_fin_base_frete_adicional]
as
select
	base.bfa_cd_base_frete_adicional
	,base.bfa_cd_transportadora
	,base.bfa_cd_service_center
	,base.bfa_estado
	,base.bfa_cd_tipo_veiculo
	,base.bfa_tipo_adicional_domingo
	,base.bfa_vl_adicional_domingo
	,base.bfa_tipo_adicional_ciclo_pm
	,base.bfa_vl_adicional_ciclo_pm
	,base.bfa_vl_paradas0_60
	,base.bfa_vl_paradas61_90
	,base.bfa_vl_paradas_acima_90
	,base.bfa_tipo_adicional_ajudante
	,base.bfa_vl_adicional_ajudante
	,base.bfa_tipo_adicional_risco
	,base.bfa_vl_adicional_risco
	,base.bfa_calcula_por_parada
	,base.bfa_cd_codigo_cliente
	,base.bfa_data_inicio
	,base.bfa_data_fim
	,base.bfa_adicional_recarga
	,base.bfa_tipo_adicional_recarga
	,base.bfa_vl_adicional_recarga
	,base.bfa_cd_operacao
	,lista.lst_ds_valor Operacao
from
	tb_fin_base_frete_adicional base with(nolock)
	join tb_lista lista with(nolock) on base.bfa_cd_operacao = lista.lst_cd_lista
GO
