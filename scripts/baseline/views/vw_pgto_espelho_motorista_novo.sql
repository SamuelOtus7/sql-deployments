-- ============================================================
-- BASELINE: dbo.vw_pgto_espelho_motorista_novo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pgto_espelho_motorista_novo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view  [dbo].[vw_pgto_espelho_motorista_novo] AS 
	
	select  
		ppr_cd_pgto_espelho
		,convert(varchar(10),ppr_data_referencia,103) as Data	
		,ppr_cd_rota			as Rota
		,usr_nm_usuario			as NomeMotorista
		,ppr_base_principal			as Base
		,ppr_ds_placa			as Placa
		,case when ppr_vl_total < 0 then 'Desconto' else 'Minuta' end as Origem

		-- /*texto para fcargo*/
		-- ,case 
		-- 	when ppr_lcto_observacao is not null then ppr_lcto_observacao
		-- 	when ppr_vl_total < 0 then ppr_lcto_observacao 
		-- 	else 'Ref.: Rota de número ' + ppr_cd_rota +  ' realizada com veículo ' + b.tipoveiculo + '.' end  as Descricao

		,case 
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
								+ CASE WHEN a.ppr_vl_desconto <> 0 THEN CASE WHEN a.ppr_lcto_observacao LIKE '%Pnr%' THEN ' PNR: R$ ' ELSE CASE WHEN a.ppr_lcto_observacao LIKE '%Vehicle Daily Not Visited%' THEN ' Not Visited: R$ ' ELSE  ' Lost: R$ ' END end + format(ISNULL(a.ppr_vl_desconto,0), 'N2', 'pt-BR') ELSE '' END
								+ CASE WHEN a.ppr_vl_adicional_km <> 0 then ' Adicional KM: R$ ' + format(ISNULL(a.ppr_vl_adicional_km,0), 'N2', 'pt-BR') ELSE '' END
						ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Lanc. Manuais' + case when par4.prm_cd_parametro is null then '' else ' - ' + t.plm_nm_tipo end  ELSE a.ppr_lcto_observacao END + ': R$ ' + format(ISNULL(a.ppr_vl_lancamentos,0), 'N2', 'pt-BR')
					END
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
--		end
		END  end as Descricao

		,ppr_ds_tipo_veiculo as veiculo	 
		--,isnull((-1*ppr_vl_lancamentos),0) + ppr_vl_total 			as Valor
		,ppr_vl_total 			as Valor
		,cli_ds_nome			as NomeTrasportadora
		,convert(varchar(10),ppr_dh_criacao,103) + ' ' + convert(varchar(8),convert(time(0),ppr_dh_criacao)) as DataGeracao
		,ppr_dh_criacao
		,cli_ds_cnpj			as CNPJTransportadora
		--,usr_matricula			as Matricula
		,e.mot_cd_matricula as Matricula
		,e.mot_cpf as CPFMotorista
		,convert(varchar(10),periodo.pgp_dt_inicio,103) as InicioPeriodo
		,convert(varchar(10),periodo.pgp_dt_fim,103) as FimPeriodo
		,CASE
			 WHEN a.ppr_cd_tipo = 'FM'
				 THEN 'First Mile'
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
	from [tb_pgto_periodo_rota] a

	left join [tb_pgto_periodo] as periodo
	on a.ppr_cd_periodo = periodo.pgp_cd_periodo

	inner join tb_pag_espelhos as espelho
	on 1=1
	-- and espelho.mtn_cd_motorista		= a.ppr_cd_motorista
	-- and espelho.mtn_cd_pgto_periodo = a.ppr_cd_periodo
	and espelho.mtn_cd_motorista_nfs = a.ppr_cd_pgto_espelho

	left join tb_clientes as c
	on espelho.mtn_cod_cliente =  c.cli_cd_codigo_cliente 

	--left join vw_rotas as b
	--on a.ppr_cd_rota = cast(b.idrota as varchar(10))

	left join tb_usuario as d
	on a.ppr_cd_motorista = d.usr_cd_usuario
	and d.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente

	left join tb_motorista as e
	on  ppr_cd_motorista = e.mot_cd_usuario
	
	left join tb_parametros par with(nolock) on c.cli_cd_codigo_cliente = par.prm_cod_cliente and par.prm_ds_chave = 'Exibir Dados Bancários Espelho'
	left join tb_parametros par2 with(nolock) on c.cli_cd_codigo_cliente = par2.prm_cod_cliente and par2.prm_ds_chave = 'Exibir Responsável Espelho'
	left join tb_parametros par3 with(nolock) on c.cli_cd_codigo_cliente = par3.prm_cod_cliente and par3.prm_ds_chave = 'Label Total Espelho'
	left join tb_parametros par4 with(nolock) on c.cli_cd_codigo_cliente = par4.prm_cod_cliente and par4.prm_ds_chave = 'Exibir tipo lançamento espelho' and par4.prm_ds_valor = 'true'
	
	--Inclusão para pegar dados de pagamentos dos motoristas
	left join vw_dados_motoristas m on d.usr_cd_usuario = m.CodigoUsuario and c.cli_cd_codigo_cliente = m.IdCliente

	left join tb_lancamentos_manuais as l on a.ppr_lcto_cd_lancamento = l.tlm_cd_lancamento_manual
	left join tb_tipos_lancamentos_manuais as t on l.tlm_cd_tipo = t.plm_cd_tipo_lancamento_manual

	WHERE ppr_in_excluido = 0
	and mot_cd_cliente = pgp_cd_cliente
	 --and mtn_cd_motorista_nfs = 420558

	/* ALTERAÇÃO 07/04/2025 and mot_cd_status = 1 retirado para que motoristas com status de inativo apareçam no espelho de pagamentos */

	 --and mot_cd_status = 1


	--select * from tb_motorista where mot_nm_motorista = 'Gustavo Henrique da Silva'
	--select * from tb_ml_motoristas where Nome = 'Gustavo Henrique da Silva'
	--select * from tb_usuario where usr_nm_usuario = 'Gustavo Henrique da Silva'

	--union all

	--select
	--convert(varchar(10),tlm_dh_referencia,103) as Data
	--,cast(tlm_cd_rota as varchar(50)) as IdRota
	--,tlm_cd_motorista as Motorista
	--,tlm_cd_service_center as Base
	--,null as Placa
	--,case when isnull(tlm_vl_valor_descontos,0) > 0 then 'Desconto' else 'Credito' end as Origem
	--,tlm_ds_observacao as observacao
	--,null as Veiculo
	--,-1 * isnull(tlm_vl_valor_descontos,0) + isnull(tlm_vl_valor_apoio,0)  ValorApoio
	--,cli_ds_nome as Transportadora
	--,null DataGeracao
	--,tlm_dh_criacao as DataCriacao
	--,cli_ds_cnpj as CNPJ
	--,usr_matricula as Matricula
	--,c.CPF
	--,CONVERT(VARCHAR(10), periodo.pgp_dt_inicio, 103) as DataInicio
	--,CONVERT(VARCHAR(10), periodo.pgp_dt_fim, 103) as DataFim
	
	--from (
	--		select a.*
	--		from [dbo].[tb_lancamentos_manuais] as a
	--		inner join [tb_aprovacao_lancamento_manual] as b
	--		on alm_cd_lancamento_manual = tlm_cd_lancamento_manual
	--		where alm_ds_status = 'Aprovado'
	--	) as a
	
	--left join tb_usuario as b
	--on a.tlm_cd_usuario_criacao = b.usr_cd_usuario
	
	--left join (
	--			select cli_cd_codigo_cliente,cli_ds_cnpj,cli_ds_nome, a.*
	--			from tb_ml_motoristas as a
	--			inner join tb_clientes as b
	--			on a.idtransportadora = b.cli_id_logistics         
	--			) as c
	--on a.tlm_cd_motorista = c.nome
	--and a.tlm_cd_cliente = c.cli_cd_codigo_cliente
	
	
	--inner join (
	
	--			select distinct ppr_cd_periodo ,pgp_dt_inicio,pgp_dt_fim,ppr_nome_motorista
	--			from tb_pgto_periodo_rota as a
	--			inner join tb_pgto_periodo as b
	--			on a.ppr_cd_periodo = b.pgp_cd_periodo
	--			where ppr_cd_pgto_espelho = @codespelho
	
	--			) as periodo
	--on periodo.ppr_nome_motorista = a.tlm_cd_motorista
	
	--where tlm_in_ativo = 1
	--and cast(tlm_dh_referencia as date) between pgp_dt_inicio and pgp_dt_fim
GO
