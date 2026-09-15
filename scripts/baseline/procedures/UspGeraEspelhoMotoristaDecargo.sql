-- ============================================================
-- BASELINE: dbo.UspGeraEspelhoMotoristaDecargo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraEspelhoMotoristaDecargo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGeraEspelhoMotoristaDecargo] (
	@IdEspelho int
)
as
begin

	SET NOCOUNT ON;	
	
	--declare @IdEspelho int = 1175254
	declare @IdPeriodo int = (select mtn_cd_pgto_periodo from tb_pag_espelhos where mtn_cd_motorista_nfs = @IdEspelho)
	declare @DataInicio date = (select pgp_dt_inicio from tb_pgto_periodo where pgp_cd_periodo = @IdPeriodo)
	declare @DataFim date = (select pgp_dt_fim from tb_pgto_periodo where pgp_cd_periodo = @IdPeriodo)
	declare @IdCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @IdPeriodo)

	--retorna todos os lançamentos manuais com rotas desse período concatenando em uma única linha
	drop table if exists #lancamentos_manuais
	select 
		p.plm_cd_lancamentos
		,STRING_AGG(CAST(tlm_ds_observacao AS VARCHAR(MAX)) + ': R$ ' + format(isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) + case when plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) END, 'N2', 'pt-BR'),CHAR(13) + CHAR(10) +CHAR(13) + CHAR(10) +CHAR(13) + CHAR(10) ) AS descricao_concatenada
		into #lancamentos_manuais
	from
		vw_lancamentos_manuais_aprovados l
		join tb_pgto_rotas_lanc_manuais p on (l.tlm_cd_rota = p.plm_cd_rota or p.plm_cd_lancamento = l.tlm_cd_lancamento_manual)
										and p.plm_cd_espelhos = @IdEspelho
	where
		tlm_cd_cliente = @IdCliente
		and tlm_dh_referencia >= @DataInicio
		and tlm_dh_referencia < dateadd(day,1,@DataFim)
	group by
		p.plm_cd_lancamentos



	select  
		ppr_cd_pgto_espelho
		,convert(varchar(10),ppr_data_referencia,103) as Data	
		,ppr_cd_rota			as Rota
		,ppr_nome_motorista			as NomeMotorista
		,ppr_base_principal			as Base
		,ppr_cd_faixa_km
		,ppr_total_km
		,ppr_ds_placa			as Placa
		,case when ppr_vl_total < 0 then 'Desconto' else 'Minuta' end as Origem
	
		,CASE WHEN a.ppr_cd_rota IS NOT NULL THEN				
			CASE WHEN a.ppr_vl_base <> 0  THEN 'Frete ' + CASE WHEN a.ppr_ds_ciclo IS NULL THEN '' ELSE a.ppr_ds_ciclo + ': R$ ' END + format(ISNULL(a.ppr_vl_base,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_paradas <> 0 THEN ' Paradas: R$ ' + format(ISNULL(a.ppr_vl_paradas,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_pontos <> 0 THEN ' Pontos: R$ ' + format(ISNULL(a.ppr_vl_pontos,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_risco <> 0 THEN ' Risco: R$ ' + format(ISNULL(a.ppr_vl_risco,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_ajudante <> 0 THEN ' Ajudante: R$ ' + format(ISNULL(a.ppr_vl_ajudante,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_dom_fer <> 0 THEN ' Domingo Feriado: R$ ' + format(ISNULL(a.ppr_vl_dom_fer,0), 'N2', 'pt-BR') ELSE '' END						
			+ CASE WHEN a.ppr_vl_bonus <> 0 THEN ' Bônus: R$ ' + format(ISNULL(a.ppr_vl_bonus,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_pedagio <> 0 THEN ' Pedágio: R$ ' + format(ISNULL(a.ppr_vl_pedagio,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_recarga <> 0 THEN ' Recarga Elétrica: R$ ' + format(ISNULL(a.ppr_vl_recarga,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_desconto <> 0 THEN CASE WHEN a.ppr_lcto_observacao LIKE '%Pnr%' THEN ' PNR: R$ ' ELSE CASE WHEN a.ppr_lcto_observacao LIKE '%Vehicle Daily Not Visited%' THEN ' Not Visited: R$ ' ELSE  ' Lost: R$ ' END end + format(ISNULL(a.ppr_vl_desconto,0), 'N2', 'pt-BR') ELSE '' END
			+ CASE WHEN a.ppr_vl_adicional_km <> 0 then ' Adicional KM: R$ ' + format(ISNULL(a.ppr_vl_adicional_km,0), 'N2', 'pt-BR') ELSE '' END						
			+ CASE WHEN a.ppr_vl_lancamentos <> 0 THEN ' ' + CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN ISNULL(ISNULL(l.descricao_concatenada,a.ppr_lcto_observacao), 'Lanc. Manuais') ELSE a.ppr_lcto_observacao END ELSE '' END
		ELSE 
			CASE 
				WHEN a.ppr_lcto_observacao = 'Lançamento - Aluguel'
					THEN CASE WHEN a.ppr_vl_aluguel <> 0 THEN 'Aluguel: R$ ' + format(ISNULL(a.ppr_vl_aluguel,0), 'N2', 'pt-BR') ELSE '' END
				WHEN a.ppr_lcto_observacao = 'Desconto Flex Frota'
					THEN CASE WHEN a.ppr_vl_desconto_flex_rota <> 0 THEN 'Desconto Flex Frota: R$ ' + format(ISNULL(a.ppr_vl_desconto_flex_rota,0), 'N2', 'pt-BR') ELSE '' END
				WHEN a.ppr_lcto_observacao = 'Desconto Cartão Flex Frota'
					THEN CASE WHEN a.ppr_vl_desconto_cartao_flex_rota <> 0 THEN 'Desconto Cartão Flex Frota: R$ ' + format(ISNULL(a.ppr_vl_desconto_cartao_flex_rota,0), 'N2', 'pt-BR')  ELSE '' END
				ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Avulso' ELSE a.ppr_lcto_observacao END + ': R$ ' + format(ISNULL(a.ppr_vl_total,0), 'N2', 'pt-BR')
			END
		END as Descricao

		,ppr_ds_tipo_veiculo as veiculo	 
		,ppr_vl_total 			as Valor
		,cli_ds_nome			as NomeTrasportadora
		,convert(varchar(10),ppr_dh_criacao,103) + ' ' + convert(varchar(8),convert(time(0),ppr_dh_criacao)) as DataGeracao
		,ppr_dh_criacao
		,cli_ds_cnpj			as CNPJTransportadora
		,e.mot_cd_matricula as Matricula
		,e.mot_cpf as CPFMotorista
		,convert(varchar(10),periodo.pgp_dt_inicio,103) as InicioPeriodo
		,convert(varchar(10),periodo.pgp_dt_fim,103) as FimPeriodo
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
			END					AS Operacao,
			CASE
			WHEN e.mot_pag_cd_tipo_pagamento = 1
				THEN 'Nota Fiscal'
			WHEN e.mot_pag_cd_tipo_pagamento = 2
				THEN 'CIOT'
			ELSE NULL
		END						AS Tipo_Pagamento
		,isnull(m.Agencia,'-') As Agencia
		,isnull(m.Conta,'-') As Conta
		,isnull(m.TipoConta,'-') as Tipo_Conta
		,isnull(m.Banco,'-') as Banco
		,isnull(m.TipoChavePix,'-') TipoChavePix
		,isnull(m.ChavePix,'-') ChavePix
		,isnull(m.NomeTitular,'-') NomeTitular
		,case len (coalesce(m.CpfTitular,m.CnpjTitular,'-'))
			when 11 then format(cast(coalesce(m.CpfTitular,m.CnpjTitular,'-') as bigint), '000\.000\.000\-00') --cpf
			when 14 then format(cast(coalesce(m.CpfTitular,m.CnpjTitular,'-') as bigint), '00\.000\.000\/0000\-00') --cnpj
		else
			coalesce(m.CpfTitular,m.CnpjTitular,'-')
		end CpfTitular
		,case len (coalesce(m.CpfTitular,m.CnpjTitular,'-'))
			when 11 then 'CPF Titular'
			when 14 then 'CNPJ Titular'
		else
			'CPF/CNPJ Titular'
		end LabelCpfTitular
	
		,case when par.prm_ds_valor = 'true' then 1 else 0 end ExibirDadosBancarios

		,m.ResponsavelContrato
	
		,case len(m.CpfCnpjResponsavel)
			when 11 then format(cast(m.CpfCnpjResponsavel as bigint), '000\.000\.000\-00') --cpf
			when 14 then format(cast(m.CpfCnpjResponsavel as bigint), '00\.000\.000\/0000\-00') --cnpj
		else
			m.CpfCnpjResponsavel
		end CpfCnpjResponsavel

		,case len(m.CpfCnpjResponsavel)
			when 11 then 'CPF Responsável'
			when 14 then 'CNPJ Responsável'
		else
			'CPF/CNPJ Responsável'
		end LabelCpfCnpjResponsavel

		,case when par2.prm_ds_valor = 'true' and m.ResponsavelContrato is not null then 1 else 0 end ExibirResponsavel

		,case when par3.prm_ds_valor is not null and par3.prm_ds_valor <> '' then par3.prm_ds_valor else 'Total da nota a emitir:' end LabelTotal

		--select count(*)
	from
		[tb_pgto_periodo_rota] a
		left join [tb_pgto_periodo] as periodo on a.ppr_cd_periodo = periodo.pgp_cd_periodo
		inner join tb_pag_espelhos as espelho on espelho.mtn_cd_motorista_nfs = a.ppr_cd_motorista_nfs
		left join tb_clientes as c on espelho.mtn_cod_cliente =  c.cli_cd_codigo_cliente 
		left join tb_usuario as d on a.ppr_cd_motorista = d.usr_cd_usuario and d.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
		left join tb_motorista as e on ppr_cd_motorista = e.mot_cd_usuario
		left join tb_parametros par with(nolock) on c.cli_cd_codigo_cliente = par.prm_cod_cliente and par.prm_ds_chave = 'Exibir Dados Bancários Espelho'
		left join tb_parametros par2 with(nolock) on c.cli_cd_codigo_cliente = par2.prm_cod_cliente and par2.prm_ds_chave = 'Exibir Responsável Espelho'
		left join tb_parametros par3 with(nolock) on c.cli_cd_codigo_cliente = par3.prm_cod_cliente and par3.prm_ds_chave = 'Label Total Espelho'
		left join tb_parametros par4 with(nolock) on c.cli_cd_codigo_cliente = par4.prm_cod_cliente and par4.prm_ds_chave = 'Exibir tipo lançamento espelho' and par4.prm_ds_valor = 'true'
		--Inclusão para pegar dados de pagamentos dos motoristas
		left join vw_dados_motoristas m on d.usr_cd_usuario = m.CodigoUsuario and c.cli_cd_codigo_cliente = m.IdCliente
		left join #lancamentos_manuais as l on a.ppr_lcto_cd_lancamento = l.plm_cd_lancamentos
	WHERE
		a.ppr_cd_motorista_nfs = @IdEspelho
		and ppr_in_excluido = 0
	
end

GO
