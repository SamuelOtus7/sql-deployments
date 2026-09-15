-- ============================================================
-- BASELINE: dbo.vw_espelho_pagamentos_torres
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_espelho_pagamentos_torres]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_espelho_pagamentos_torres]
AS

select  

-- 'calculo que o zeca fez no arquivo rdl do espelho de pagamento' as desconto 
--valor conta contabil 1 

[cnpj_filial]			= '36524009000149'				 -- Dado fixo, será enviado pela Torres (planilha em anexo)
,[cnpj_fornecedor]		= '32397612895'					-- Dado fixo, será enviado pela Torres (planilha em anexo)
,[numero_documento]		= mtn_cd_motorista_nfs			-- Será o código do espelho do motorista dentro do Irysys
,[emissao]				= pgp_dt_inicio					-- data do último dia da quinzena: 16 e 30 ou 31
,[vencimento]			= pgp_dt_fim					-- data do dia do pagamento (como vamos pegar essa data? a partir da atualização do status pagamento efetuado?) (planilha em anexo)
,[mes_competencia]		= MONTH(pgp_dt_inicio)				-- Dado do período de pagamento
,[ano_competencia]		= YEAR(pgp_dt_inicio)				-- Dado do período de pagamento
,[valor] = ppr_vl_total			 -- Valor líquido, depois dos impostos. (já vai existir no espelho do motorista)
,[acrescimo] = 0										-- deixar zerado? (planilha em anexo)
,[desconto] = (ppr_vl_total * 0.06 ) * 0.135		--ACHAR Valor dos impostos descontados do valor total (já vai existir no espelho do motorista)
,[forma_pagamento] = NULL								-- em branco
,[numero_cheque] = NULL									-- em branco
,[conta_bancaria_cheque] = NULL							-- em branco
,[conta_bancaria_transferencia] = Conta	
,[nome_classificacao_financeira] = NULL					-- Dado fixo, será enviado pela Torres (planilha em anexo)
,[observacao] = NULL									-- em branco
,[codigo_conta_contabil_1] = NULL						-- Dado fixo, será enviado pela Torres (planilha em anexo)
,[valor_conta_contabil_1] = ppr_vl_total - 	((ppr_vl_total * 0.06 ) * 0.135)-- Valor líquido, depois dos impostos. (já vai existir no espelho do motorista)
,[codigo_conta_contabil_2] = NULL						-- deixar em branco
,[valor_conta_contabil_2] = NULL						-- deixar em branco
,[codigo_conta_contabil_3] = NULL						-- deixar em branco
,[valor_conta_contabil_3] = NULL						-- deixar em branco
,[nome_centro_custo_1] = ppr_base_principal		
,[valor_centro_custo_1] = NULL							-- Valor líquido, depois dos impostos. (já vai existir no espelho do motorista)
,[nome_centro_custo_2] = NULL							-- deixar em branco
,[valor_centro_custo_2] = NULL							-- deixar em branco
,[nome_centro_custo_3] = NULL							-- deixar em branco
,[valor_centro_custo_3] = NULL							-- deixar em branco

FROM tb_pgto_periodo_rota a WITH (NOLOCK)
INNER JOIN tb_pag_espelhos pag WITH (NOLOCK)
	ON a.ppr_cd_motorista_nfs = pag.mtn_cd_motorista_nfs
INNER JOIN tb_pgto_periodo b WITH (NOLOCK)
	ON a.ppr_cd_periodo = b.pgp_cd_periodo
LEFT JOIN tb_clientes cli WITH (NOLOCK)
	ON b.pgp_cd_cliente = cli.cli_cd_codigo_cliente
LEFT JOIN vw_resultado_financeiro c
	ON a.ppr_cd_rota = c.IdRota
LEFT JOIN tb_fin_prefatura pre WITH (NOLOCK)
	ON a.ppr_cd_rota = pre.IdRota
LEFT JOIN vw_dados_motoristas m
	ON a.ppr_cd_motorista = m.CodigoUsuario
	AND b.pgp_cd_cliente = m.IdCliente
LEFT JOIN (
	SELECT
		lan.tlm_cd_rota AS Rota,
		SUM(lan.tlm_vl_valor_descontos) AS ValorAdiantado
	FROM tb_lancamentos_manuais lan WITH (NOLOCK)
	JOIN tb_aprovacao_lancamento_manual apr WITH (NOLOCK)
		ON apr.alm_cd_lancamento_manual = lan.tlm_cd_lancamento_manual
	WHERE lan.tlm_cd_cliente = 11
		AND lan.tlm_cd_tipo = 233
		AND apr.alm_ds_status = 'Aprovado'
		AND lan.tlm_cd_rota IS NOT NULL
	GROUP BY lan.tlm_cd_rota
) adiantamentos
	ON a.ppr_cd_rota = adiantamentos.Rota
	AND b.pgp_cd_cliente = 11
WHERE b.pgp_cd_status = 1
	AND b.pgp_cd_periodo >= 370;
GO
