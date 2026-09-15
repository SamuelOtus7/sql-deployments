-- ============================================================
-- BASELINE: dbo.vw_pgto_espelho_motorista_TESTE
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pgto_espelho_motorista_TESTE]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view  [dbo].[vw_pgto_espelho_motorista_TESTE] AS 
	
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
							THEN 'Frete ' + CASE WHEN a.ppr_ds_ciclo IS NULL THEN '' ELSE a.ppr_ds_ciclo + ': R$ ' END + cast(ISNULL(a.ppr_vl_base,0) as varchar(50)) 
								+ ' Paradas: R$ ' + cast(ISNULL(a.ppr_vl_paradas,0) as varchar(50))
								+ CASE WHEN a.ppr_vl_risco <> 0 THEN ' Risco: R$ ' + CAST(a.ppr_vl_risco AS VARCHAR(50)) ELSE '' END
								+ CASE WHEN a.ppr_vl_ajudante <> 0 THEN ' Ajudante: R$ ' + CAST(a.ppr_vl_ajudante AS VARCHAR(50)) ELSE '' END
								+ CASE WHEN a.ppr_vl_dom_fer <> 0 THEN ' Domingo Feriado: R$ ' + CAST(a.ppr_vl_dom_fer AS VARCHAR(50)) ELSE '' END
								+ CASE WHEN a.ppr_vl_lancamentos <> 0 THEN ' ' + CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Lanc. Manuais' ELSE a.ppr_lcto_observacao END + ': R$ ' + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) ELSE '' END
								+ CASE WHEN a.ppr_vl_bonus <> 0 THEN ' Bônus: R$ ' + CAST(a.ppr_vl_bonus AS VARCHAR(50)) ELSE '' END
								+ CASE WHEN a.ppr_vl_pedagio <> 0 THEN ' Pedágio: R$ ' + CAST(a.ppr_vl_pedagio AS VARCHAR(50)) ELSE '' END
								+ CASE WHEN a.ppr_vl_recarga <> 0 THEN ' Recarga Elétrica: R$ ' + CAST(a.ppr_vl_recarga AS VARCHAR(50)) ELSE '' END
								+ CASE WHEN a.ppr_vl_desconto <> 0 THEN CASE WHEN a.ppr_lcto_observacao LIKE '%Pnr%' THEN ' PNR: R$ ' ELSE ' Lost: R$ ' END + CAST(a.ppr_vl_desconto AS VARCHAR(50)) ELSE '' END
						ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Lanc. Manuais' ELSE a.ppr_lcto_observacao END + ': R$ ' + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) 
					END
			ELSE 
				CASE 
					WHEN a.ppr_lcto_observacao = 'Lançamento - Aluguel'
						THEN CASE WHEN a.ppr_vl_aluguel <> 0 THEN 'Aluguel: R$ ' + + CAST(a.ppr_vl_aluguel AS VARCHAR(50)) ELSE '' END
					WHEN a.ppr_lcto_observacao = 'Desconto Flex Frota'
						THEN CASE WHEN a.ppr_vl_desconto_flex_rota <> 0 THEN 'Desconto Flex Frota: R$ ' + + CAST(a.ppr_vl_desconto_flex_rota AS VARCHAR(50)) ELSE '' END
					WHEN a.ppr_lcto_observacao = 'Desconto Cartão Flex Frota'
						THEN CASE WHEN a.ppr_vl_desconto_cartao_flex_rota <> 0 THEN 'Desconto Cartão Flex Frota: R$ ' + + CAST(a.ppr_vl_desconto_cartao_flex_rota AS VARCHAR(50)) ELSE '' END
					ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Avulso' ELSE a.ppr_lcto_observacao END + ': R$ ' + CAST(a.ppr_vl_total AS VARCHAR(50))
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
		,usr_matricula			as Matricula
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
			 ELSE ''
		 END					AS Operacao,
		 CASE
			WHEN e.mot_pag_cd_tipo_pagamento = 1
				THEN 'Nota Fiscal'
			WHEN e.mot_pag_cd_tipo_pagamento = 2
				THEN 'CIOT'
			ELSE NULL
		END						AS Tipo_Pagamento

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
	--and b.idtransportadora =  e.mot_cd_cliente
	--where ppr_cd_pgto_espelho = @codespelho
	-- order by 1 desc

	WHERE ppr_in_excluido = 0
	and mot_cd_cliente = pgp_cd_cliente
	 --and mtn_cd_motorista_nfs = 420558
	-- and mot_cd_status = 1

GO
