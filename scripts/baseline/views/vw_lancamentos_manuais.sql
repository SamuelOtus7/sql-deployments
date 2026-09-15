-- ============================================================
-- BASELINE: dbo.vw_lancamentos_manuais
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lancamentos_manuais]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_lancamentos_manuais]
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
	,l.tlm_cd_mot tlm_cd_mot --,isnull(l.tlm_cd_mot,usu.usr_cd_usuario) tlm_cd_mot
	,l.tlm_cd_mot_apoio tlm_cd_mot_apoio --,isnull(l.tlm_cd_mot_apoio,usu_apoio.usr_cd_usuario) tlm_cd_mot_apoio
	,l.tlm_tp_credito_debito
	,l.tlm_cd_operacao
	,a.alm_ds_status
	,t.plm_nm_tipo
	,t.plm_in_calculo_desconto
	,lista.lst_ds_valor Operacao
	,l.tlm_cd_mot tlm_cd_usuario --usu.usr_cd_usuario tlm_cd_usuario
	,l.tlm_ds_valor_referencia
	,isnull(l.tlm_vl_valor_adicional,0) 
		+ isnull(l.tlm_vl_valor_rota,0) 
		+ case when t.plm_nm_tipo = 'ROTAS DE BIKE' then isnull(l.tlm_vl_valor_apoio,0) else 0 end 
		+ case when t.plm_nm_tipo = 'Apoio' then (-1 * isnull(l.tlm_vl_valor_apoio,0)) else (-1 * isnull(l.tlm_vl_valor_descontos,0)) end 
	tlm_vl_lancamento
from 
	[dbo].[tb_lancamentos_manuais] l with(nolock)
	join [tb_aprovacao_lancamento_manual] a with(nolock) on l.tlm_cd_lancamento_manual = a.alm_cd_lancamento_manual 
	join [dbo].[tb_tipos_lancamentos_manuais] t with(nolock) on l.tlm_cd_tipo = t.plm_cd_tipo_lancamento_manual
	join tb_lista lista with(nolock) on l.tlm_cd_operacao = lista.lst_cd_lista
	
	--left join tb_usuario as usu on l.tlm_cd_motorista = usu.usr_nm_usuario --DBO.fn_remove_acentuacao(l.tlm_cd_motorista) = DBO.fn_remove_acentuacao(usu.usr_nm_usuario)
	--							and l.tlm_cd_cliente = usu.cli_cd_codigo_cliente 
	--							and usu.usr_in_ativo = 1
	--left join tb_usuario as usu_apoio on l.tlm_ds_motorista_apoio = usu_apoio.usr_nm_usuario --DBO.fn_remove_acentuacao(l.tlm_ds_motorista_apoio) = DBO.fn_remove_acentuacao(usu_apoio.usr_nm_usuario)
	--							and l.tlm_cd_cliente = usu_apoio.cli_cd_codigo_cliente 
	--							and usu_apoio.usr_in_ativo = 1

GO
