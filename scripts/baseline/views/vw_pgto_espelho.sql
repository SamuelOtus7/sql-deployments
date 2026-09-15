-- ============================================================
-- BASELINE: dbo.vw_pgto_espelho
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pgto_espelho]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view 
--select * from [dbo].[vw_pgto_espelho_motorista] where ppr_cd_pgto_espelho = 574505
--select * from [dbo].[vw_pgto_espelho_alter] where ppr_cd_pgto_espelho = 574505
[dbo].[vw_pgto_espelho]
as 
	select  
convert(varchar(10),a.ppr_data_referencia,103)									as Data	
		,a.ppr_cd_rota																	as Rota
		,d.usr_nm_usuario																as NomeMotorista
		,A.ppr_base_principal																as Base
		,a.ppr_ds_placa																	as Placa
		,case 
			when a.ppr_vl_total < 0 
--			when (a.ppr_vl_total - ISNULL(a.ppr_vl_lancamentos,0) + ISNULL(ppr_vl_pedagio,0)) < 0
				then 'Desconto' 
			else 'Minuta' 
		end																				as Origem
--		,'Minuta'																		as Origem
		,
--case 
--			when a.ppr_lcto_observacao is not null 
--				then a.ppr_lcto_observacao
			--when a.ppr_vl_total < 0 
			--	then a.ppr_lcto_observacao 
--			else
			case 
				when pgp_cd_cliente = 27
					then ppr_lcto_observacao
				else 
			CASE
				WHEN a.ppr_cd_rota IS NOT NULL
					THEN
						CASE
							WHEN a.ppr_lcto_cd_lancamento IS NULL
								THEN 'Frete ' + CASE WHEN a.ppr_ds_ciclo IS NULL THEN '' ELSE a.ppr_ds_ciclo + ': R$ ' END + format(ISNULL(a.ppr_vl_base,0), 'N2', 'pt-BR') 
									-- + ' Paradas: R$ ' + cast(ISNULL(a.ppr_vl_paradas,0) as varchar(50))
									+ CASE WHEN pgp_cd_cliente = 61 THEN ' Ajudante: R$ ' 
									ELSE ' Paradas: R$ ' 
									END + format(ISNULL(a.ppr_vl_paradas,0), 'N2', 'pt-BR') 
									+ CASE WHEN a.ppr_vl_risco <> 0 THEN ' Risco: R$ ' + format(ISNULL(a.ppr_vl_risco,0), 'N2', 'pt-BR') ELSE '' END
									+ CASE WHEN a.ppr_vl_ajudante <> 0 THEN ' Ajudante: R$ ' + format(ISNULL(a.ppr_vl_ajudante,0), 'N2', 'pt-BR') ELSE '' END
									+ CASE WHEN a.ppr_vl_dom_fer <> 0 THEN ' Domingo Feriado: R$ ' + format(ISNULL(a.ppr_vl_dom_fer,0), 'N2', 'pt-BR') ELSE '' END
									+ CASE WHEN a.ppr_vl_lancamentos <> 0 THEN ' ' + CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Lanc. Manuais' ELSE a.ppr_lcto_observacao END + ': R$ ' + format(ISNULL(a.ppr_vl_lancamentos,0), 'N2', 'pt-BR') ELSE '' END
									+ CASE WHEN a.ppr_vl_bonus <> 0 THEN ' Bônus: R$ ' + format(ISNULL(a.ppr_vl_bonus,0), 'N2', 'pt-BR') ELSE '' END
									+ CASE WHEN a.ppr_vl_pedagio <> 0 THEN ' Pedágio: R$ ' + format(ISNULL(a.ppr_vl_pedagio,0), 'N2', 'pt-BR') ELSE '' END
									+ CASE WHEN a.ppr_vl_recarga <> 0 THEN ' Recarga Elétrica: R$ ' + format(ISNULL(a.ppr_vl_recarga,0), 'N2', 'pt-BR') ELSE '' END
									+ CASE WHEN a.ppr_vl_desconto <> 0 THEN CASE WHEN a.ppr_lcto_observacao LIKE '%Pnr%' THEN ' PNR: R$ ' ELSE CASE WHEN a.ppr_lcto_observacao LIKE '%Vehicle Daily Not Visited%' THEN ' Not Visited: R$ ' ELSE ' Lost: R$ ' END END + format(ISNULL(a.ppr_vl_desconto,0), 'N2', 'pt-BR') ELSE '' END
							ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Lanc. Manuais' ELSE a.ppr_lcto_observacao END + ': R$ ' + format(ISNULL(a.ppr_vl_lancamentos,0), 'N2', 'pt-BR')
						END
				ELSE 
					CASE 
						WHEN a.ppr_lcto_observacao = 'Lançamento - Aluguel'
							THEN CASE WHEN a.ppr_vl_aluguel <> 0 THEN 'Aluguel: R$ ' + + format(ISNULL(a.ppr_vl_aluguel,0), 'N2', 'pt-BR') ELSE '' END
						WHEN a.ppr_lcto_observacao = 'Desconto Flex Frota'
							THEN CASE WHEN a.ppr_vl_desconto_flex_rota <> 0 THEN 'Desconto Flex Frota: R$ ' + + format(ISNULL(a.ppr_vl_desconto_flex_rota,0), 'N2', 'pt-BR') ELSE '' END
						WHEN a.ppr_lcto_observacao = 'Desconto Cartão Flex Frota'
							THEN CASE WHEN a.ppr_vl_desconto_cartao_flex_rota <> 0 THEN 'Desconto Cartão Flex Frota: R$ ' + format(ISNULL(a.ppr_vl_desconto_cartao_flex_rota,0), 'N2', 'pt-BR') ELSE '' END
						ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Avulso' ELSE a.ppr_lcto_observacao END + ': R$ ' + format(ISNULL(a.ppr_vl_total,0), 'N2', 'pt-BR')
					END
--		end
		END end as Descricao
		
		,a.ppr_ds_tipo_veiculo															as veiculo	 
		--,a.ppr_vl_total - ISNULL(a.ppr_vl_lancamentos,0) + ISNULL(ppr_vl_pedagio,0)		as Valor
		,a.ppr_vl_total as Valor
		,c.cli_ds_nome																	as NomeTrasportadora
		,convert(varchar(10),a.ppr_dh_criacao,103) + ' ' 
			+ convert(varchar(8),convert(time(0),a.ppr_dh_criacao))						as DataGeracao
		,a.ppr_dh_criacao
		,c.cli_ds_cnpj																	as CNPJTransportadora
		,d.usr_matricula																as Matricula
		,e.mot_cpf																		as CPFMotorista
		,convert(varchar(10),periodo.pgp_dt_inicio,103)									as InicioPeriodo
		,convert(varchar(10),periodo.pgp_dt_fim,103)									as FimPeriodo
		,a.ppr_nm_cidade
		,a.ppr_cd_pgto_espelho
		,CASE
			WHEN a.ppr_cd_tipo = 'FM'
				THEN 'Fisrt Mile'
			WHEN a.ppr_cd_tipo = 'LM'
				THEN 'Last Mile'
			WHEN a.ppr_cd_tipo = 'MO'
				THEN 'Meli One'
			WHEN a.ppr_cd_tipo = 'LH'
				THEN 'Line Hall'
			ELSE ''
		END																				AS Operacao,
		CASE
			WHEN e.mot_pag_cd_tipo_pagamento = 1
				THEN 'Nota Fiscal'
			WHEN e.mot_pag_cd_tipo_pagamento = 2
				THEN 'CIOT'
			ELSE NULL
		END																				AS Tipo_Pagamento

		,isnull(m.Agencia,'-') As Agencia
		,isnull(m.Conta,'-') As Conta
		,isnull(m.TipoConta,'-') as Tipo_Conta
		,isnull(m.Banco,'-') as Banco
		,isnull(m.TipoChavePix,'-') TipoChavePix
		,isnull(m.ChavePix,'-') ChavePix
		,isnull(m.NomeTitular,'-') NomeTitular
		,coalesce(m.CpfTitular,m.CnpjTitular,'-') CpfTitular

	from [tb_pgto_periodo_rota] a

	left join [tb_pgto_periodo] as periodo
	on a.ppr_cd_periodo = periodo.pgp_cd_periodo

	inner join tb_pag_espelhos as espelho
	on 1=1
	and espelho.mtn_cd_motorista_nfs = a.ppr_cd_pgto_espelho

	left join tb_clientes as c
	on espelho.mtn_cod_cliente =  c.cli_cd_codigo_cliente 
	left join tb_usuario as d
	on a.ppr_cd_motorista = d.usr_cd_usuario
	and d.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente

	left join tb_motorista as e
	on  ppr_cd_motorista = e.mot_cd_usuario
	left join ( select
					lan.tlm_cd_rota Rota
					,sum(lan.tlm_vl_valor_descontos) ValorAdiantado
						from 
							tb_lancamentos_manuais lan with(nolock)
							join tb_aprovacao_lancamento_manual apr with(nolock) on alm_cd_lancamento_manual = tlm_cd_lancamento_manual
						where 
							lan.tlm_cd_cliente = 11 and lan.tlm_cd_tipo = 233 and apr.alm_ds_status = 'Aprovado' and lan.tlm_cd_rota <> 'null'
						group by
							lan.tlm_cd_rota) as LM on LM.Rota = a.ppr_cd_rota

	--Inclusão para pegar dados de pagamentos dos motoristas
	left join vw_dados_motoristas m on d.usr_cd_usuario = m.CodigoUsuario and c.cli_cd_codigo_cliente = m.IdCliente

	WHERE ppr_in_excluido = 0
	and mot_cd_cliente = pgp_cd_cliente
	--and ppr_cd_pgto_espelho  = 574505
GO
