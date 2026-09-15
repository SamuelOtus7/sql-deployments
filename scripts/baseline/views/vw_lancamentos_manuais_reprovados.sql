-- ============================================================
-- BASELINE: dbo.vw_lancamentos_manuais_reprovados
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lancamentos_manuais_reprovados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





Create view [dbo].[vw_lancamentos_manuais_reprovados]
as
select
	l.tlm_cd_lancamento_manual
	,l.tlm_cd_rota
	,l.tlm_cd_service_center
	,l.tlm_cd_motorista
	,l.tlm_cd_tipo
	,l.tlm_cd_periodo
	,l.tlm_cd_risco_ajudante
	,l.tlm_cd_quantidade_pacotes
	,l.tlm_cd_pontos
	,l.tlm_ds_observacao
	,l.tlm_cd_cliente
	,l.tlm_in_ativo
	,l.tlm_in_excluido
	,l.tlm_cd_usuario_criacao
	,l.tlm_dh_criacao
	,l.tlm_cd_usuario_modificacao
	,l.tlm_dh_modificacao
	,l.tlm_cd_transportadora
	,l.tlm_in_marketplace
	,l.tlm_ds_motorista_apoio
	,l.tlm_tipo_valor_apoio
	,l.tlm_vl_valor_apoio
	,l.tlm_cd_tipo_veiculo_nao_utilizado
	,l.tlm_dh_nao_utilizado
	,l.tlm_dh_referencia
	,l.tlm_cd_arquivo
	,l.tlm_cd_cliente_transportadora
	,l.tlm_vl_valor_rota
	,l.tlm_vl_valor_adicional
	,l.tlm_ds_motorista_secundario
	,l.tlm_vl_valor_descontos
	,l.tlm_ds_matricula
	,l.tlm_ds_placa
	,l.tlm_cd_mot
	,l.tlm_cd_mot_apoio
	,l.tlm_tp_credito_debito
	,l.tlm_cd_operacao
	,l.alm_ds_status
	,l.plm_nm_tipo
	,l.plm_in_calculo_desconto
	,l.Operacao
	,l.tlm_cd_usuario
from 
	vw_lancamentos_manuais l
where 
	tlm_in_ativo = 1
	and tlm_in_excluido = 0
	and alm_ds_status in ('Cancelado','Reprovado')
GO
