-- ============================================================
-- BASELINE: dbo.vw_validacoes_espelho_resultados_lancamentos_manuais
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacoes_espelho_resultados_lancamentos_manuais]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_validacoes_espelho_resultados_lancamentos_manuais]
as
select
	v.vle_nm_validacao Validacao
	,v.vle_ds_validacao DescricaoValidacao
	,l.lst_ds_label GrupoValidacao
	,l2.lst_ds_label TipoValidacao
	,v.vle_nm_url_acao Acao
	,r.ver_cd_periodo CodigoPeriodo
	,r.ver_cd_validacao_contexto CodigoValidacaoContexto
	,r.ver_cd_validacao_resultado CodigoValidacaoResultado
	,r.ver_cd_pagamento_rota CodigoPagamentoRota
	,r.ver_cd_lancamento_manual CodigoLancamentoManual
	,r.ver_in_resultado_sucesso Sucesso
	,r.ver_cd_usuario_inativacao UsuarioInativacao
	,lan.tlm_cd_lancamento_manual IdLancamentoManual
	,lan.plm_nm_tipo TipoLancamentoManual
	,lan.tlm_cd_service_center Base
	,lan.tlm_cd_rota IdRota
	,lan.tlm_cd_motorista Motorista
from
	tb_validacoes_espelho v with(nolock)
	join tb_lista l with(nolock) on v.vle_cd_grupo_validacao = l.lst_cd_lista
	join tb_lista l2 with(nolock) on v.vle_cd_tipo_validacao = l2.lst_cd_lista
	join tb_validacoes_espelho_contexto c with(nolock) on v.vle_cd_validacao = c.vec_cd_validacao
	join tb_validacoes_espelho_resultados r with(nolock) on c.vec_cd_validacao_contexto = r.ver_cd_validacao_contexto
	join vw_lancamentos_manuais_aprovados lan on r.ver_cd_lancamento_manual = lan.tlm_cd_lancamento_manual
GO
