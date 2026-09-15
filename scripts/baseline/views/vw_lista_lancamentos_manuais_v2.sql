-- ============================================================
-- BASELINE: dbo.vw_lista_lancamentos_manuais_v2
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lista_lancamentos_manuais_v2]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- dbo.vw_lista_lancamentos_manuais_v2 fonte

CREATE VIEW [dbo].[vw_lista_lancamentos_manuais_v2]
AS
SELECT
	l.tlm_cd_lancamento_manual IdLancamentoManual
	,l.tlm_cd_cliente CodigoCliente
	,CASE WHEN l.tlm_cd_rota = 'null' THEN NULL ELSE l.tlm_cd_rota END Rota
	,CAST(l.tlm_dh_referencia AS DATE) DataReferencia
	,l.tlm_cd_service_center ServiceCenter
	,t.plm_nm_tipo TipoLancamento
	,CASE WHEN l.tlm_ds_placa = 'null' THEN NULL ELSE l.tlm_ds_placa END Placa
	,l.tlm_cd_motorista MotoristaOriginal
	,l.tlm_ds_motorista_apoio MotoristaApoio
	,l.tlm_in_marketplace Marketplace
	,l.tlm_cd_tipo Tipo
	,l.tlm_cd_periodo Periodo
	,l.tlm_cd_risco_ajudante RiscoAjudante
	,l.tlm_cd_quantidade_pacotes QuantidadePacotes
	,l.tlm_cd_pontos Pontos
	,l.tlm_ds_observacao Observacao
	,l.tlm_cd_transportadora CodTransportadora
	,l.tlm_cd_tipo_veiculo_nao_utilizado CodTipoVeiculoNaoUtilizado
	,l.tlm_dh_nao_utilizado DhNaoUtilizado
	,l.tlm_ds_motorista_secundario MotoristaSecundario
	,l.tlm_tipo_valor_apoio TipoValorApoio
	,l.tlm_cd_arquivo CodArquivo
	,l.tlm_cd_cliente_transportadora CodClienteTransportadora
	,l.tlm_in_ativo Ativo
	,lt.lst_ds_label TipoOperacaoName
	,l.tlm_cd_operacao TipoOperacao
	,u.usr_nm_usuario UsuarioCriacao
	,l.tlm_dh_criacao DataHoraCriacao
	,u2.usr_nm_usuario UsuarioAprovacao
	,a.alm_dh_aprovacao DataAprovacao
	,a.alm_ds_status StatusLancamento
	,ISNULL(l.tlm_vl_valor_apoio,0) + ISNULL(l.tlm_vl_valor_rota,0) + ISNULL(l.tlm_vl_valor_adicional,0) + ISNULL(l.tlm_vl_valor_descontos*-1,0) ValorLancamento
	,ISNULL(l.tlm_vl_valor_apoio,0) ValorApoio
	,ISNULL(l.tlm_vl_valor_rota,0) ValorRota
	,ISNULL(l.tlm_vl_valor_adicional,0) ValorAdicional
	,ISNULL(l.tlm_vl_valor_descontos*-1,0) ValorDescontos
	,ISNULL(p.PeriodoPagamento,p2.PeriodoPagamento) PeriodoPagamento
	,ISNULL(p.StatusPagamento,p2.StatusPagamento) StatusPagamento
	,ISNULL(p.Paradas, p2.Paradas) Paradas
	,m.Matricula
	,m.CodigoMotorista
	,m.Banco
	,m.NomeTitular
	,m.CpfTitular
	,m.CnpjTitular
	,m.Agencia
	,m.Conta
	,m.TipoConta
	,m.TipoChavePix
	,m.ChavePix
	,l.tlm_tp_credito_debito AS TipoPagamento
	,p2.PeriodoPagamentoCod AS PeriodoPagamentoCod
FROM
	tb_lancamentos_manuais l WITH(NOLOCK)
	LEFT JOIN tb_tipos_lancamentos_manuais t WITH(NOLOCK) ON l.tlm_cd_tipo = t.plm_cd_tipo_lancamento_manual
	LEFT JOIN tb_usuario u WITH(NOLOCK) ON l.tlm_cd_usuario_criacao = u.usr_cd_usuario
	LEFT JOIN tb_aprovacao_lancamento_manual a WITH(NOLOCK) ON l.tlm_cd_lancamento_manual = a.alm_cd_lancamento_manual
	LEFT JOIN tb_usuario u2 WITH(NOLOCK) ON a.alm_cd_usuario_aprovacao = u2.usr_cd_usuario
	LEFT JOIN tb_lista lt WITH(NOLOCK) ON l.tlm_cd_operacao = lt.lst_cd_lista
	LEFT JOIN vw_dados_motoristas m ON --l.tlm_cd_motorista = m.Motorista
		--AND l.tlm_cd_cliente = m.IdCliente
		--AND m.OrdemNomeMotorista = 1
		l.tlm_cd_mot = m.CodigoUsuario
	LEFT JOIN (
		SELECT
			per.pgp_cd_cliente IdCliente
			,pgp_nm_periodo PeriodoPagamento
			,lt2.lst_ds_label StatusPagamento
			,ppr_lcto_cd_lancamento
			,ROW_NUMBER() OVER (PARTITION BY per.pgp_cd_cliente, ppr_lcto_cd_lancamento ORDER BY per.pgp_dt_inicio DESC) AS PagamentoLancamentoAtual
			,pgp_cd_periodo PeriodoPagamentoCod
			,p.ppr_qt_paradas Paradas
		FROM
			tb_pgto_periodo_rota p WITH(NOLOCK)
			JOIN tb_pag_espelhos esp WITH(NOLOCK) ON p.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
			LEFT JOIN tb_lista lt2 WITH(NOLOCK) ON esp.mtn_cd_status = lt2.lst_cd_lista
			JOIN tb_pgto_periodo per WITH(NOLOCK) ON p.ppr_cd_periodo = per.pgp_cd_periodo
		WHERE
			p.ppr_in_excluido = 0
			AND esp.mtn_in_excluido = 0
			AND per.pgp_cd_status = 1
			AND per.pgp_in_excluido = 0
			AND p.ppr_lcto_cd_lancamento IS NOT NULL
	) p ON l.tlm_cd_lancamento_manual = p.ppr_lcto_cd_lancamento AND t.plm_nm_tipo <> 'Apoio' AND p.PagamentoLancamentoAtual = 1 AND l.tlm_cd_cliente = p.IdCliente
	LEFT JOIN (
		SELECT
			per.pgp_cd_cliente IdCliente
			,pgp_nm_periodo PeriodoPagamento
			,lt2.lst_ds_label StatusPagamento
			,ppr_cd_rota
			,ROW_NUMBER() OVER (PARTITION BY per.pgp_cd_cliente, ppr_cd_rota ORDER BY per.pgp_dt_inicio DESC) AS PagamentoRotaAtual
			,pgp_cd_periodo PeriodoPagamentoCod
			,p.ppr_qt_paradas Paradas
		FROM
			tb_pgto_periodo_rota p WITH(NOLOCK)
			JOIN tb_pag_espelhos esp WITH(NOLOCK) ON p.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
			LEFT JOIN tb_lista lt2 WITH(NOLOCK) ON esp.mtn_cd_status = lt2.lst_cd_lista
			JOIN tb_pgto_periodo per WITH(NOLOCK) ON p.ppr_cd_periodo = per.pgp_cd_periodo
		WHERE
			p.ppr_in_excluido = 0
			AND esp.mtn_in_excluido = 0
			AND per.pgp_cd_status = 1
			AND per.pgp_in_excluido = 0
			AND p.ppr_cd_rota IS NOT NULL
			AND ppr_lcto_cd_lancamento IS NULL
	) p2 ON l.tlm_cd_rota = p2.ppr_cd_rota AND l.tlm_cd_rota <> 'null' AND p2.PagamentoRotaAtual = 1 AND l.tlm_cd_cliente = p2.IdCliente
WHERE
	l.tlm_in_ativo = 1
	AND l.tlm_in_excluido = 0;
GO
