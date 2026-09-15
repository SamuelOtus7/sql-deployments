-- ============================================================
-- BASELINE: dbo.UspFinCalculaPagamentoSaidaMeliLM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinCalculaPagamentoSaidaMeliLM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinCalculaPagamentoSaidaMeliLM]  (
	@CodPeriodoPagamento int
	,@IdRota int = null
	,@CodEspelho int = null
	,@CodUsuario int = null
)
as
begin

	SET NOCOUNT ON;

	--declare @CodPeriodoPagamento int = 2616
	--declare @IdRota int = null
	--declare @CodEspelho int = null -- codigo espelho,
	--declare @CodUsuario int = null

	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)
	declare @DataLimiteReanalise date = (select pgp_dt_limite_reanalise from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1 and cast(getdate() as date) <= isnull(@DataLimiteReanalise,cast(getdate() as date))
	begin


		------------------------------------------------------------
		-- INFORMAÇÕES SOBRE O PERÍODO QUE ESTÁ SENDO PROCESSADO
		------------------------------------------------------------
		declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @CodPeriodoPagamento)
		declare @Operacao int = (select
									lst_cd_lista
								from
									tb_lista as a with(nolock)
									join [tb_pgto_periodo] as b with(nolock) on a.lst_cd_cliente = b.pgp_cd_cliente
																			and a.lst_cd_lista = b.pgp_tipo_operacao
								where
									lst_nm_lista = 'Operações Marketplace'
									and pgp_cd_periodo = @CodPeriodoPagamento
								)


		declare @IdCliTransportadora int = (select
												lst_cd_lista
											from
												tb_lista (NOLOCK)
											where
												lst_nm_lista = 'Clientes transportadoras'
												and lst_ds_label = 'Mercado Livre'
												and lst_cd_cliente = @CodigoCliente
											)


		declare @ParamUtilizaContrato int = isnull(
												(select
													prm_ds_valor
												from
													tb_parametros
												where
													prm_ds_categoria = 'Financeiro - Pagamentos'
													and prm_nm_parametro = 'Utiliza contrato'
													and prm_cod_cliente = @CodigoCliente
													and prm_in_ativo = 1
													and prm_in_excluido = 0
												)
											,0)


		declare @TipoOperacao varchar(2) = (select
												lst_ds_valor
											from
												tb_lista as a with(nolock)
												join [tb_pgto_periodo] as b with(nolock) on a.lst_cd_cliente = b.pgp_cd_cliente
																			and a.lst_cd_lista = b.pgp_tipo_operacao
											where
												lst_nm_lista = 'Operações Marketplace'
												and pgp_cd_periodo = @CodPeriodoPagamento
		)

		 declare @ParamZerarAmbulancia varchar(50) = lower(ltrim(rtrim(isnull(
															(select
																prm_ds_valor
															from
																tb_parametros with(nolock)
															where
																prm_nm_parametro = 'Zerar ambulância'
																and prm_in_ativo = 1
																and prm_in_excluido = 0
																and prm_cod_cliente = @CodigoCliente
															)
														,'false'))))

		 declare @PagarAmbulancia1FaixaSemAdicional varchar(50) = lower(ltrim(rtrim(isnull(
															(select
																prm_ds_valor
															from
																tb_parametros with(nolock)
															where
																prm_nm_parametro = 'Pagar ambulância 1 faixa sem adicional'
																and prm_in_ativo = 1
																and prm_in_excluido = 0
																and prm_cod_cliente = @CodigoCliente
															)
														,'false'))))

		------------------------------------------------------------
		-- GERA TABELA COM DADOS QUE SERÃO UTILIZADOS PARA CÁLCULO
		------------------------------------------------------------
		drop table if exists #tb_pgto_periodo_rota
		select
			@Operacao ppr_cd_operacao
			,@IdCliTransportadora ppr_cd_cliente_transportadora
			,ppr_cd_motorista_nfs
			,ppr_cd_pagamento_rota
			,ppr_cd_periodo
			,ppr_cd_rota
			,ppr_base_principal
			,isnull(ppr_base_calculo,ppr_base_principal) ppr_base_calculo
			,ppr_ds_tipo_veiculo
			,ppr_nome_motorista
			,ppr_nm_cidade
			,ppr_total_km
			,ppr_qt_pacotes
			,ppr_qt_pacotes_entregues
			,ppr_in_zerar_rota
			,ppr_motivo_rota_zerada
			,ppr_in_ambulancia
			,ppr_in_ambulancia_aprovada
			,ppr_tipo_rota
			,ppr_ds_ciclo
			,ppr_in_dom
			,ppr_in_fer
			,ppr_ds_placa
			,ppr_data_referencia
			,ppr_qt_paradas
			,ppr_cd_tipo_pgto
			,@ParamZerarAmbulancia ppr_zerar_ambulancia
			,@PagarAmbulancia1FaixaSemAdicional ppr_ambulancia_1_faixa_sem_adicional
			,ppr_in_rota_saca
			into #tb_pgto_periodo_rota
		from
			tb_pgto_periodo_rota with(nolock)
		where
			ppr_cd_periodo = @CodPeriodoPagamento
			and ppr_cd_rota is not null
			and ppr_cd_tipo_pgto = 1362
			and ppr_in_excluido = 0
			and (ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
			and (ppr_cd_rota = @IdRota or @IdRota is null)


		------------------------------------------------------------
		-- MATERIALIZAÇÃO DE VIEWS EM TABELAS TEMPORÁRIAS
		-- Otimização: evita reexpansão da view ~10x com UNION
		-- Split em 3 tabelas: normal, placa, paradas
		------------------------------------------------------------
		declare @min_data_referencia date = (select min(ppr_data_referencia) from #tb_pgto_periodo_rota)
		declare @max_data_referencia date = (select max(ppr_data_referencia) from #tb_pgto_periodo_rota)

		-- #temp 1: vw_fin_base_frete_motorista NORMAL (sem placa, sem paradas)
		-- Usada por: freteKm0a100Cidade, freteKm0a100, freteKmCidade, freteKm
		drop table if exists #tmp_bf_normal
		select
		     bfm_cd_base_frete_motorista
		    ,bfm_cd_transportadora
		    ,bfm_cd_service_center
		    ,bfm_nm_cidade
		    ,bfm_cd_tipo_veiculo
		    ,bfm_vl_inicio_faixa
		    ,bfm_vl_fim_faixa
		    ,bfm_vl_frete
		    ,bfm_vl_frete_pm
		    ,bfm_vl_frete_fixo
		    ,bmf_cd_tipo_contrato
		    ,bfm_cd_codigo_cliente
		    ,bfm_vl_domfer_am
		    ,bfm_vl_domfer_pm
		    ,bfm_vl_frete_ambulancia_am
		    ,bfm_vl_frete_ambulancia_pm
		    ,bfm_data_inicio_vigencia
		    ,bfm_data_fim_vigencia
		    ,bfm_nm_regiao
		    ,bfm_cd_operacao
		    ,ValidFrom
		    ,ValidTo
		    ,Operacao
		    ,bfm_cd_pagar_por_pacotes
		    ,bfm_vl_frete_sd
		    ,bfm_cd_criterio_pagamento
		    ,bfm_pag_pacote_entregues
		    ,CriterioPagamento
		    ,bfm_perc_minimo_endereco_nao_visitado
		    ,bfm_zerar_ambulancia_nao_aprovada
		    ,bfm_ds_placa
		    ,CriterioFaixa
		    ,bfm_vl_inicio_faixa2
		    ,bfm_vl_fim_faixa2
		    ,CriterioFaixa2
			,bfm_vl_frete_saca
		into #tmp_bf_normal
		from vw_fin_base_frete_motorista
		where bfm_cd_transportadora = @CodigoCliente
		  and Operacao = @TipoOperacao
		  and bfm_ds_placa is null
		  and CriterioFaixa2 is null
		  and bfm_cd_codigo_cliente = @IdCliTransportadora
		  and bfm_data_inicio_vigencia <= @max_data_referencia
		  and (bfm_data_fim_vigencia is null or bfm_data_fim_vigencia >= @min_data_referencia)

		create nonclustered index IX_tmp_bf_normal_cidade
		    on #tmp_bf_normal (bfm_cd_service_center, bfm_cd_tipo_veiculo, bfm_nm_cidade, bfm_vl_inicio_faixa, bfm_vl_fim_faixa)
		    include (bfm_vl_frete, bfm_vl_frete_pm, bfm_vl_frete_fixo, bmf_cd_tipo_contrato,
		             bfm_cd_codigo_cliente, bfm_vl_domfer_am, bfm_vl_domfer_pm,
		             bfm_vl_frete_ambulancia_am, bfm_vl_frete_ambulancia_pm,
		             bfm_cd_pagar_por_pacotes, bfm_vl_frete_sd, bfm_zerar_ambulancia_nao_aprovada,
		             CriterioPagamento, bfm_pag_pacote_entregues, bfm_perc_minimo_endereco_nao_visitado,
		             bfm_data_inicio_vigencia, bfm_data_fim_vigencia)

		-- #temp 2: vw_fin_base_frete_motorista PLACA (com placa, sem paradas)
		-- Usada por: fretePlacaCidade, fretePlaca, frete0a100PlacaCidade, frete0a100Placa
		drop table if exists #tmp_bf_placa
		select
		     bfm_cd_base_frete_motorista
		    ,bfm_cd_transportadora
		    ,bfm_cd_service_center
		    ,bfm_nm_cidade
		    ,bfm_cd_tipo_veiculo
		    ,bfm_vl_inicio_faixa
		    ,bfm_vl_fim_faixa
		    ,bfm_vl_frete
		    ,bfm_vl_frete_pm
		    ,bfm_vl_frete_fixo
		    ,bmf_cd_tipo_contrato
		    ,bfm_cd_codigo_cliente
		    ,bfm_vl_domfer_am
		    ,bfm_vl_domfer_pm
		    ,bfm_vl_frete_ambulancia_am
		    ,bfm_vl_frete_ambulancia_pm
		    ,bfm_data_inicio_vigencia
		    ,bfm_data_fim_vigencia
		    ,bfm_nm_regiao
		    ,bfm_cd_operacao
		    ,ValidFrom
		    ,ValidTo
		    ,Operacao
		    ,bfm_cd_pagar_por_pacotes
		    ,bfm_vl_frete_sd
		    ,bfm_cd_criterio_pagamento
		    ,bfm_pag_pacote_entregues
		    ,CriterioPagamento
		    ,bfm_perc_minimo_endereco_nao_visitado
		    ,bfm_zerar_ambulancia_nao_aprovada
		    ,bfm_ds_placa
		    ,CriterioFaixa
		    ,bfm_vl_inicio_faixa2
		    ,bfm_vl_fim_faixa2
		    ,CriterioFaixa2
			,bfm_vl_frete_saca
		into #tmp_bf_placa
		from vw_fin_base_frete_motorista
		where bfm_cd_transportadora = @CodigoCliente
		  and Operacao = @TipoOperacao
		  and bfm_ds_placa is not null
		  and CriterioFaixa2 is null
		  and bfm_cd_codigo_cliente = @IdCliTransportadora
		  and bfm_data_inicio_vigencia <= @max_data_referencia
		  and (bfm_data_fim_vigencia is null or bfm_data_fim_vigencia >= @min_data_referencia)

		create nonclustered index IX_tmp_bf_placa_cidade
		    on #tmp_bf_placa (bfm_cd_service_center, bfm_cd_tipo_veiculo, bfm_ds_placa,
		                      bfm_nm_cidade, bfm_vl_inicio_faixa, bfm_vl_fim_faixa)
		    include (bfm_vl_frete, bfm_vl_frete_pm, bfm_vl_frete_fixo, bmf_cd_tipo_contrato,
		             bfm_cd_codigo_cliente, bfm_vl_domfer_am, bfm_vl_domfer_pm,
		             bfm_vl_frete_ambulancia_am, bfm_vl_frete_ambulancia_pm,
		             bfm_vl_frete_sd, bfm_data_inicio_vigencia, bfm_data_fim_vigencia)

		-- #temp 3: vw_fin_base_frete_motorista PARADAS (sem placa, com paradas)
		-- Usada por: freteKmCidadeParadas, freteKmParadas, freteKm0a100CidadeParadas, freteKm0a100Paradas
		drop table if exists #tmp_bf_paradas
		select
		     bfm_cd_base_frete_motorista
		    ,bfm_cd_transportadora
		    ,bfm_cd_service_center
		    ,bfm_nm_cidade
		    ,bfm_cd_tipo_veiculo
		    ,bfm_vl_inicio_faixa
		    ,bfm_vl_fim_faixa
		    ,bfm_vl_frete
		    ,bfm_vl_frete_pm
		    ,bfm_vl_frete_fixo
		    ,bmf_cd_tipo_contrato
		    ,bfm_cd_codigo_cliente
		    ,bfm_vl_domfer_am
		    ,bfm_vl_domfer_pm
		    ,bfm_vl_frete_ambulancia_am
		    ,bfm_vl_frete_ambulancia_pm
		    ,bfm_data_inicio_vigencia
		    ,bfm_data_fim_vigencia
		    ,bfm_nm_regiao
		    ,bfm_cd_operacao
		    ,ValidFrom
		    ,ValidTo
		    ,Operacao
		    ,bfm_cd_pagar_por_pacotes
		    ,bfm_vl_frete_sd
		    ,bfm_cd_criterio_pagamento
		    ,bfm_pag_pacote_entregues
		    ,CriterioPagamento
		    ,bfm_perc_minimo_endereco_nao_visitado
		    ,bfm_zerar_ambulancia_nao_aprovada
		    ,bfm_ds_placa
		    ,CriterioFaixa
		    ,bfm_vl_inicio_faixa2
		    ,bfm_vl_fim_faixa2
		    ,CriterioFaixa2
			,bfm_vl_frete_saca
		into #tmp_bf_paradas
		from vw_fin_base_frete_motorista
		where bfm_cd_transportadora = @CodigoCliente
		  and Operacao = @TipoOperacao
		  and bfm_ds_placa is null
		  and CriterioFaixa2 = 'Paradas'
		  and bfm_cd_codigo_cliente = @IdCliTransportadora
		  and bfm_data_inicio_vigencia <= @max_data_referencia
		  and (bfm_data_fim_vigencia is null or bfm_data_fim_vigencia >= @min_data_referencia)

		create nonclustered index IX_tmp_bf_paradas_cidade
		    on #tmp_bf_paradas (bfm_cd_service_center, bfm_cd_tipo_veiculo, bfm_nm_cidade,
		                        bfm_vl_inicio_faixa, bfm_vl_fim_faixa)
		    include (bfm_vl_frete, bfm_vl_frete_pm, bfm_vl_frete_fixo, bmf_cd_tipo_contrato,
		             bfm_cd_codigo_cliente, bfm_vl_domfer_am, bfm_vl_domfer_pm,
		             bfm_vl_frete_ambulancia_am, bfm_vl_frete_ambulancia_pm,
		             bfm_vl_frete_sd, bfm_vl_inicio_faixa2, bfm_vl_fim_faixa2,
		             bfm_data_inicio_vigencia, bfm_data_fim_vigencia)

		-- #temp 4: vw_fin_base_frete_adicional_motorista
		-- Usada por: adicionalCidade, adicional
		drop table if exists #tmp_bfa
		select
		     bfa_cd_base_frete_adicional_motorista
		    ,bfa_cd_transportadora
		    ,bfa_cd_service_center
		    ,bfa_nm_cidade
		    ,bfa_cd_tipo_veiculo
		    ,bfa_cd_ambulancia_primeira_faixa
		    ,bfa_qtd_pacote_ambulancia
		    ,bfa_vl_pacote_ambulancia
		    ,bfa_cd_tipo_contrato
		    ,bfa_data_inicio_vigencia
		    ,bfa_data_fim_vigencia
		    ,bfa_ds_placa
		    ,bfa_cd_codigo_cliente
		    ,Operacao
		into #tmp_bfa
		from vw_fin_base_frete_adicional_motorista
		where bfa_cd_transportadora = @CodigoCliente
		  and bfa_cd_codigo_cliente = @IdCliTransportadora
		  and bfa_data_inicio_vigencia <= @max_data_referencia
		  and (bfa_data_fim_vigencia is null or bfa_data_fim_vigencia >= @min_data_referencia)

		create nonclustered index IX_tmp_bfa
		    on #tmp_bfa (bfa_cd_transportadora, bfa_cd_service_center, bfa_cd_tipo_veiculo, bfa_nm_cidade)
		    include (bfa_cd_ambulancia_primeira_faixa, bfa_qtd_pacote_ambulancia, bfa_vl_pacote_ambulancia,
		             bfa_cd_tipo_contrato, bfa_ds_placa, bfa_data_inicio_vigencia, bfa_data_fim_vigencia)


		------------------------------------------------------------
		-- CALCULA VALOR BASE DA ROTA
		------------------------------------------------------------
		drop table if exists #pagamento_base
		select
			pgto.ppr_cd_operacao
			,pgto.ppr_cd_cliente_transportadora
			,pgto.ppr_cd_motorista_nfs
			,pgto.ppr_cd_pagamento_rota
			,pgto.ppr_cd_periodo
			,pgto.ppr_cd_rota
			,pgto.ppr_base_principal
			,pgto.ppr_ds_tipo_veiculo
			,veic.tvl_cd_tipo_veiculo
			,pgto.ppr_nome_motorista
			,isnull(esp.mtn_cd_tipo_contrato,-1) tipo_contrato
			,pgto.ppr_nm_cidade
			,pgto.ppr_total_km
			,pgto.ppr_qt_pacotes
			,pgto.ppr_qt_pacotes_entregues
			,pgto.ppr_in_zerar_rota
			,pgto.ppr_motivo_rota_zerada
			,pgto.ppr_in_ambulancia
			,pgto.ppr_in_ambulancia_aprovada
			,pgto.ppr_zerar_ambulancia
			,pgto.ppr_ambulancia_1_faixa_sem_adicional
			,pgto.ppr_qt_paradas
			,pgto.ppr_ds_ciclo

			--,case when v.vei_vl_pagamento_fixo > 0 then v.vei_vl_pagamento_fixo end ValorFixoPlacaRota
			,case when v.vei_valor_fixo > 0 then v.vei_valor_fixo end ValorFixoPlacaRota

			-- ValorFixoSD: agora inclui Paradas 0a100 e Placa 0a100 (prioridade: Paradas ? Placa ? Normal)
			,case when pgto.ppr_tipo_rota like '%SD%' or pgto.ppr_ds_ciclo = 'SD'
				then coalesce(
					freteKm0a100CidadeParadas.bfm_vl_frete_sd,
					freteKm0a100Paradas.bfm_vl_frete_sd,
					frete0a100PlacaCidade.bfm_vl_frete_sd,
					frete0a100Placa.bfm_vl_frete_sd,
					freteKm0a100Cidade.bfm_vl_frete_sd,
					freteKm0a100.bfm_vl_frete_sd
				) else null end ValorFixoSD
			,case when (pgto.ppr_tipo_rota like '%SD%' or pgto.ppr_ds_ciclo = 'SD')
				and coalesce(
					freteKm0a100CidadeParadas.bfm_vl_frete_sd,
					freteKm0a100Paradas.bfm_vl_frete_sd,
					frete0a100PlacaCidade.bfm_vl_frete_sd,
					frete0a100Placa.bfm_vl_frete_sd,
					freteKm0a100Cidade.bfm_vl_frete_sd,
					freteKm0a100.bfm_vl_frete_sd
				) is not null then 1 else null end ppr_cd_desconto_sd

			--Parametros necessários para verificar se a rota deve ser pago a 1 faixa por ser ambulancia
			,isnull(adicionalCidade.bfa_cd_ambulancia_primeira_faixa,adicional.bfa_cd_ambulancia_primeira_faixa) PagarPrimeiraFaixaAmbulancia
			,isnull(adicionalCidade.bfa_qtd_pacote_ambulancia,adicional.bfa_qtd_pacote_ambulancia) bfa_qtd_pacote_ambulancia
			,isnull(adicionalCidade.bfa_vl_pacote_ambulancia,adicional.bfa_vl_pacote_ambulancia) bfa_vl_pacote_ambulancia

			-- PagarPorPacote: agora inclui Paradas 0a100 e Placa 0a100 (prioridade: Paradas ? Placa ? Normal)
			,coalesce(
				freteKm0a100CidadeParadas.bfm_cd_pagar_por_pacotes,
				freteKm0a100Paradas.bfm_cd_pagar_por_pacotes,
				frete0a100PlacaCidade.bfm_cd_pagar_por_pacotes,
				frete0a100Placa.bfm_cd_pagar_por_pacotes,
				freteKm0a100Cidade.bfm_cd_pagar_por_pacotes,
				freteKm0a100.bfm_cd_pagar_por_pacotes
			) PagarPorPacote

			-- PagarPorPacoteEntregue: agora inclui Paradas 0a100 e Placa 0a100
			,coalesce(
				freteKm0a100CidadeParadas.bfm_pag_pacote_entregues,
				freteKm0a100Paradas.bfm_pag_pacote_entregues,
				frete0a100PlacaCidade.bfm_pag_pacote_entregues,
				frete0a100Placa.bfm_pag_pacote_entregues,
				freteKm0a100Cidade.bfm_pag_pacote_entregues,
				freteKm0a100.bfm_pag_pacote_entregues
			) PagarPorPacoteEntregue

			--verifica se foi cadastrado alguma regra de pagamento
			,case
				when freteKmCidade.bfm_cd_base_frete_motorista is not null
					then freteKmCidade.CriterioPagamento
				when freteKm.bfm_cd_base_frete_motorista is not null
					then freteKm.CriterioPagamento
				when freteKm0a100Cidade.bfm_cd_base_frete_motorista is not null
					then freteKm0a100Cidade.CriterioPagamento
				when freteKm0a100.bfm_cd_base_frete_motorista is not null
					then freteKm0a100.CriterioPagamento
			end CriterioPagamento

			--verifica se foi cadastrado percentual mínimo de endereço não visitado
			,case
				when freteKmCidade.bfm_cd_base_frete_motorista is not null
					then freteKmCidade.bfm_perc_minimo_endereco_nao_visitado
				when freteKm.bfm_cd_base_frete_motorista is not null
					then freteKm.bfm_perc_minimo_endereco_nao_visitado
				when freteKm0a100Cidade.bfm_cd_base_frete_motorista is not null
					then freteKm0a100Cidade.bfm_perc_minimo_endereco_nao_visitado
				when freteKm0a100.bfm_cd_base_frete_motorista is not null
					then freteKm0a100.bfm_perc_minimo_endereco_nao_visitado
			end PercentualMinimoEnderecoNaoVisitado

			--verifica se foi cadastrado flag para zerar ambulancia não aprovada
			,case
				when freteKmCidade.bfm_cd_base_frete_motorista is not null
					then freteKmCidade.bfm_zerar_ambulancia_nao_aprovada
				when freteKm.bfm_cd_base_frete_motorista is not null
					then freteKm.bfm_zerar_ambulancia_nao_aprovada
				when freteKm0a100Cidade.bfm_cd_base_frete_motorista is not null
					then freteKm0a100Cidade.bfm_zerar_ambulancia_nao_aprovada
				when freteKm0a100.bfm_cd_base_frete_motorista is not null
					then freteKm0a100.bfm_zerar_ambulancia_nao_aprovada
			end ZerarAmbulanciaNaoAprovada

			--o isnull ta pegando as duas opções do mesmo cruzamento

			--Campos com valor frete
			-- SaidaKm0a100: agora inclui Paradas 0a100 e Placa 0a100 (prioridade: Paradas ? Placa ? Normal)
			,coalesce(
				case
					when coalesce(
						freteKm0a100CidadeParadas.bfm_vl_frete_fixo,
						freteKm0a100Paradas.bfm_vl_frete_fixo,
						frete0a100PlacaCidade.bfm_vl_frete_fixo,
						frete0a100Placa.bfm_vl_frete_fixo,
						freteKm0a100Cidade.bfm_vl_frete_fixo,
						freteKm0a100.bfm_vl_frete_fixo
					) > 0
						then coalesce(
							freteKm0a100CidadeParadas.bfm_vl_frete_fixo,
							freteKm0a100Paradas.bfm_vl_frete_fixo,
							frete0a100PlacaCidade.bfm_vl_frete_fixo,
							frete0a100Placa.bfm_vl_frete_fixo,
							freteKm0a100Cidade.bfm_vl_frete_fixo,
							freteKm0a100.bfm_vl_frete_fixo
						)
					when ppr_ds_ciclo in ('PM','SD') and (ppr_in_dom = 1 or ppr_in_fer = 1)
						then coalesce(
										coalesce(
											freteKm0a100CidadeParadas.bfm_vl_domfer_pm,
											freteKm0a100Paradas.bfm_vl_domfer_pm,
											frete0a100PlacaCidade.bfm_vl_domfer_pm,
											frete0a100Placa.bfm_vl_domfer_pm,
											freteKm0a100Cidade.bfm_vl_domfer_pm,
											freteKm0a100.bfm_vl_domfer_pm
										),
										coalesce(
											freteKm0a100CidadeParadas.bfm_vl_frete_pm,
											freteKm0a100Paradas.bfm_vl_frete_pm,
											frete0a100PlacaCidade.bfm_vl_frete_pm,
											frete0a100Placa.bfm_vl_frete_pm,
											freteKm0a100Cidade.bfm_vl_frete_pm,
											freteKm0a100.bfm_vl_frete_pm
										),
										coalesce(
											freteKm0a100CidadeParadas.bfm_vl_frete,
											freteKm0a100Paradas.bfm_vl_frete,
											frete0a100PlacaCidade.bfm_vl_frete,
											frete0a100Placa.bfm_vl_frete,
											freteKm0a100Cidade.bfm_vl_frete,
											freteKm0a100.bfm_vl_frete
										)
									)
					when ppr_ds_ciclo = 'AM' and (ppr_in_dom = 1 or ppr_in_fer = 1)
						then coalesce(
										coalesce(
											freteKm0a100CidadeParadas.bfm_vl_domfer_am,
											freteKm0a100Paradas.bfm_vl_domfer_am,
											frete0a100PlacaCidade.bfm_vl_domfer_am,
											frete0a100Placa.bfm_vl_domfer_am,
											freteKm0a100Cidade.bfm_vl_domfer_am,
											freteKm0a100.bfm_vl_domfer_am
										),
										coalesce(
											freteKm0a100CidadeParadas.bfm_vl_frete,
											freteKm0a100Paradas.bfm_vl_frete,
											frete0a100PlacaCidade.bfm_vl_frete,
											frete0a100Placa.bfm_vl_frete,
											freteKm0a100Cidade.bfm_vl_frete,
											freteKm0a100.bfm_vl_frete
										)
									)
					when ppr_ds_ciclo in ('PM','SD')
						then coalesce(
										coalesce(
											freteKm0a100CidadeParadas.bfm_vl_frete_pm,
											freteKm0a100Paradas.bfm_vl_frete_pm,
											frete0a100PlacaCidade.bfm_vl_frete_pm,
											frete0a100Placa.bfm_vl_frete_pm,
											freteKm0a100Cidade.bfm_vl_frete_pm,
											freteKm0a100.bfm_vl_frete_pm
										),
										coalesce(
											freteKm0a100CidadeParadas.bfm_vl_frete,
											freteKm0a100Paradas.bfm_vl_frete,
											frete0a100PlacaCidade.bfm_vl_frete,
											frete0a100Placa.bfm_vl_frete,
											freteKm0a100Cidade.bfm_vl_frete,
											freteKm0a100.bfm_vl_frete
										)
									)
					when ppr_ds_ciclo = 'AM'
						then coalesce(
										freteKm0a100CidadeParadas.bfm_vl_frete,
										freteKm0a100Paradas.bfm_vl_frete,
										frete0a100PlacaCidade.bfm_vl_frete,
										frete0a100Placa.bfm_vl_frete,
										freteKm0a100Cidade.bfm_vl_frete,
										freteKm0a100.bfm_vl_frete
									)
				end
				,0
			) SaidaKm0a100


			,coalesce(
				case
					when ppr_in_rota_saca = 1 and coalesce(
														fretePlacaCidade.bfm_vl_frete_saca,
														fretePlaca.bfm_vl_frete_saca,
														freteKmCidadeParadas.bfm_vl_frete_saca,
														freteKmParadas.bfm_vl_frete_saca,
														freteKmCidade.bfm_vl_frete_saca,
														freteKm.bfm_vl_frete_saca
													) > 0 
					then coalesce(
									fretePlacaCidade.bfm_vl_frete_saca,
									fretePlaca.bfm_vl_frete_saca,
									freteKmCidadeParadas.bfm_vl_frete_saca,
									freteKmParadas.bfm_vl_frete_saca,
									freteKmCidade.bfm_vl_frete_saca,
									freteKm.bfm_vl_frete_saca
								)

					when coalesce(
							fretePlacaCidade.bfm_vl_frete_fixo,
							fretePlaca.bfm_vl_frete_fixo,
							freteKmCidadeParadas.bfm_vl_frete_fixo,
							freteKmParadas.bfm_vl_frete_fixo,
							freteKmCidade.bfm_vl_frete_fixo,
							freteKm.bfm_vl_frete_fixo
						) > 0
						then coalesce(
							fretePlacaCidade.bfm_vl_frete_fixo,
							fretePlaca.bfm_vl_frete_fixo,
							freteKmCidadeParadas.bfm_vl_frete_fixo,
							freteKmParadas.bfm_vl_frete_fixo,
							freteKmCidade.bfm_vl_frete_fixo,
							freteKm.bfm_vl_frete_fixo
						)

					when ppr_ds_ciclo in ('PM','SD') and (ppr_in_dom = 1 or ppr_in_fer = 1)
						then coalesce(
							coalesce(
								fretePlacaCidade.bfm_vl_domfer_pm,
								fretePlaca.bfm_vl_domfer_pm,
								freteKmCidadeParadas.bfm_vl_domfer_pm,
								freteKmParadas.bfm_vl_domfer_pm,
								freteKmCidade.bfm_vl_domfer_pm,
								freteKm.bfm_vl_domfer_pm
							),
							coalesce(
								fretePlacaCidade.bfm_vl_frete_pm,
								fretePlaca.bfm_vl_frete_pm,
								freteKmCidadeParadas.bfm_vl_frete_pm,
								freteKmParadas.bfm_vl_frete_pm,
								freteKmCidade.bfm_vl_frete_pm,
								freteKm.bfm_vl_frete_pm
							),
							coalesce(
								fretePlacaCidade.bfm_vl_frete,
								fretePlaca.bfm_vl_frete,
								freteKmCidadeParadas.bfm_vl_frete,
								freteKmParadas.bfm_vl_frete,
								freteKmCidade.bfm_vl_frete,
								freteKm.bfm_vl_frete
							)
						)

					when ppr_ds_ciclo = 'AM' and (ppr_in_dom = 1 or ppr_in_fer = 1)
						then coalesce(
							coalesce(
								fretePlacaCidade.bfm_vl_domfer_am,
								fretePlaca.bfm_vl_domfer_am,
								freteKmCidadeParadas.bfm_vl_domfer_am,
								freteKmParadas.bfm_vl_domfer_am,
								freteKmCidade.bfm_vl_domfer_am,
								freteKm.bfm_vl_domfer_am
							),
							coalesce(
								fretePlacaCidade.bfm_vl_frete,
								fretePlaca.bfm_vl_frete,
								freteKmCidadeParadas.bfm_vl_frete,
								freteKmParadas.bfm_vl_frete,
								freteKmCidade.bfm_vl_frete,
								freteKm.bfm_vl_frete
							)
						)

					when ppr_ds_ciclo in ('PM','SD')
						then coalesce(
							coalesce(
								fretePlacaCidade.bfm_vl_frete_pm,
								fretePlaca.bfm_vl_frete_pm,
								freteKmCidadeParadas.bfm_vl_frete_pm,
								freteKmParadas.bfm_vl_frete_pm,
								freteKmCidade.bfm_vl_frete_pm,
								freteKm.bfm_vl_frete_pm
							),
							coalesce(
								fretePlacaCidade.bfm_vl_frete,
								fretePlaca.bfm_vl_frete,
								freteKmCidadeParadas.bfm_vl_frete,
								freteKmParadas.bfm_vl_frete,
								freteKmCidade.bfm_vl_frete,
								freteKm.bfm_vl_frete
							)
						)

					when ppr_ds_ciclo = 'AM'
						then coalesce(
							fretePlacaCidade.bfm_vl_frete,
							fretePlaca.bfm_vl_frete,
							freteKmCidadeParadas.bfm_vl_frete,
							freteKmParadas.bfm_vl_frete,
							freteKmCidade.bfm_vl_frete,
							freteKm.bfm_vl_frete
						)
				end,
				0
			) SaidaKm

			,cast(coalesce(
					fretePlacaCidade.bfm_vl_inicio_faixa,
					fretePlaca.bfm_vl_inicio_faixa,
					freteKmCidadeParadas.bfm_vl_inicio_faixa,
					freteKmParadas.bfm_vl_inicio_faixa,
					freteKmCidade.bfm_vl_inicio_faixa,
					freteKm.bfm_vl_inicio_faixa
				) as varchar)
			+ '/'
			+ cast(coalesce(
					fretePlacaCidade.bfm_vl_fim_faixa,
					fretePlaca.bfm_vl_fim_faixa,
					freteKmCidadeParadas.bfm_vl_fim_faixa,
					freteKmParadas.bfm_vl_fim_faixa,
					freteKmCidade.bfm_vl_fim_faixa,
					freteKm.bfm_vl_fim_faixa
				) as varchar) FaixaKm

			-- FaixaKm0a100: agora inclui Paradas 0a100 e Placa 0a100 (mesma ordem do SaidaKm0a100)
			,cast(coalesce(
					freteKm0a100CidadeParadas.bfm_vl_inicio_faixa,
					freteKm0a100Paradas.bfm_vl_inicio_faixa,
					frete0a100PlacaCidade.bfm_vl_inicio_faixa,
					frete0a100Placa.bfm_vl_inicio_faixa,
					freteKm0a100Cidade.bfm_vl_inicio_faixa,
					freteKm0a100.bfm_vl_inicio_faixa
				) as varchar)
			+ '/'
			+ cast(coalesce(
					freteKm0a100CidadeParadas.bfm_vl_fim_faixa,
					freteKm0a100Paradas.bfm_vl_fim_faixa,
					frete0a100PlacaCidade.bfm_vl_fim_faixa,
					frete0a100Placa.bfm_vl_fim_faixa,
					freteKm0a100Cidade.bfm_vl_fim_faixa,
					freteKm0a100.bfm_vl_fim_faixa
				) as varchar) FaixaKm0a100

			-- =================================================================================
			-- NOVO: Valores de frete ambulância AM/PM (mesma ordem de prioridade do SaidaKm0a100:
			--        Paradas ? Placa ? Normal; Cidade antes de genérico)
			--        Usados no UPDATE de override para rotas com ppr_in_ambulancia = 1.
			-- =================================================================================
			,coalesce(
				freteKm0a100CidadeParadas.bfm_vl_frete_ambulancia_am,
				freteKm0a100Paradas.bfm_vl_frete_ambulancia_am,
				frete0a100PlacaCidade.bfm_vl_frete_ambulancia_am,
				frete0a100Placa.bfm_vl_frete_ambulancia_am,
				freteKm0a100Cidade.bfm_vl_frete_ambulancia_am,
				freteKm0a100.bfm_vl_frete_ambulancia_am,
				fretePlacaCidade.bfm_vl_frete_ambulancia_am,
				fretePlaca.bfm_vl_frete_ambulancia_am,
				freteKmCidadeParadas.bfm_vl_frete_ambulancia_am,
				freteKmParadas.bfm_vl_frete_ambulancia_am,
				freteKmCidade.bfm_vl_frete_ambulancia_am,
				freteKm.bfm_vl_frete_ambulancia_am
			) AmbulanciaFreteAM

			,coalesce(
				freteKm0a100CidadeParadas.bfm_vl_frete_ambulancia_pm,
				freteKm0a100Paradas.bfm_vl_frete_ambulancia_pm,
				frete0a100PlacaCidade.bfm_vl_frete_ambulancia_pm,
				frete0a100Placa.bfm_vl_frete_ambulancia_pm,
				freteKm0a100Cidade.bfm_vl_frete_ambulancia_pm,
				freteKm0a100.bfm_vl_frete_ambulancia_pm,
				fretePlacaCidade.bfm_vl_frete_ambulancia_pm,
				fretePlaca.bfm_vl_frete_ambulancia_pm,
				freteKmCidadeParadas.bfm_vl_frete_ambulancia_pm,
				freteKmParadas.bfm_vl_frete_ambulancia_pm,
				freteKmCidade.bfm_vl_frete_ambulancia_pm,
				freteKm.bfm_vl_frete_ambulancia_pm
			) AmbulanciaFretePM

			into #pagamento_base
		from
			#tb_pgto_periodo_rota pgto with(nolock)
			join tb_pgto_periodo per with(nolock) on pgto.ppr_cd_periodo = per.pgp_cd_periodo
			join tb_dra_tipo_veiculo veic with (nolock) on pgto.ppr_ds_tipo_veiculo = veic.tvl_nm_tipo_veiculo
			join tb_pag_espelhos esp with(nolock) on pgto.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
													--and esp.mtn_cd_cliente_transportadora = @IdCliTransportadora
													and esp.mtn_cd_operacao = @Operacao
													and esp.mtn_cd_status IN (34,228,38,1298)

			-- Verifica se foi cadastrado valor fixo por placa
			left join tb_veiculos v with(nolock) on per.pgp_cd_cliente = v.vei_cd_cliente
													and pgto.ppr_ds_placa = v.vei_ds_placa
													and v.vei_in_ativo = 1
													--and v.vei_cd_status = 1
													and v.vei_in_excluido = 0

			-- Busca o parametro para cálculo de PM
			left join #tmp_bfa adicionalCidade on per.pgp_cd_cliente = adicionalCidade.bfa_cd_transportadora
																			and pgto.ppr_base_principal = adicionalCidade.bfa_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = adicionalCidade.bfa_cd_tipo_veiculo

																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(adicionalCidade.bfa_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and pgto.ppr_nm_cidade = adicionalCidade.bfa_nm_cidade
																			and pgto.ppr_data_referencia between adicionalCidade.bfa_data_inicio_vigencia and isnull(adicionalCidade.bfa_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and adicionalCidade.Operacao = @TipoOperacao
																			--and adicionalCidade.bfa_cd_codigo_cliente = @IdCliTransportadora
																			and adicionalCidade.bfa_ds_placa is null

			left join #tmp_bfa adicional on per.pgp_cd_cliente= adicional.bfa_cd_transportadora
																			and pgto.ppr_base_principal = adicional.bfa_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo

																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and adicional.bfa_nm_cidade is null
																			and pgto.ppr_data_referencia between adicional.bfa_data_inicio_vigencia and isnull(adicional.bfa_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and adicional.Operacao = @TipoOperacao
																			--and adicional.bfa_cd_codigo_cliente = @IdCliTransportadora
																			and adicional.bfa_ds_placa is null

			-- =======================================================================
			-- #tmp_bf_normal: sem placa, sem paradas (freteKm0a100*, freteKm*)
			-- =======================================================================
			-- Calcula o valor pago para primeira faixa (0a100) com cidade
			left join #tmp_bf_normal freteKm0a100Cidade on per.pgp_cd_cliente = freteKm0a100Cidade.bfm_cd_transportadora
																			and pgto.ppr_base_principal = freteKm0a100Cidade.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = freteKm0a100Cidade.bfm_cd_tipo_veiculo

																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm0a100Cidade.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and freteKm0a100Cidade.bfm_nm_cidade is not null
																			and pgto.ppr_nm_cidade = freteKm0a100Cidade.bfm_nm_cidade
																			and freteKm0a100Cidade.bfm_vl_inicio_faixa in (0,1)
																			and pgto.ppr_data_referencia between freteKm0a100Cidade.bfm_data_inicio_vigencia and isnull(freteKm0a100Cidade.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and freteKm0a100Cidade.Operacao = @TipoOperacao
																			--and freteKm0a100Cidade.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and freteKm0a100Cidade.bfm_ds_placa is null
																			and freteKm0a100Cidade.CriterioFaixa2 is null

			left join #tmp_bf_normal freteKm0a100 on per.pgp_cd_cliente = freteKm0a100.bfm_cd_transportadora
																			and pgto.ppr_base_principal = freteKm0a100.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = freteKm0a100.bfm_cd_tipo_veiculo
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and freteKm0a100.bfm_nm_cidade is null
																			and freteKm0a100.bfm_vl_inicio_faixa in (0,1)
																			and pgto.ppr_data_referencia between freteKm0a100.bfm_data_inicio_vigencia and isnull(freteKm0a100.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and freteKm0a100.Operacao = @TipoOperacao
																			--and freteKm0a100.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and freteKm0a100.bfm_ds_placa is null
																			and freteKm0a100.CriterioFaixa2 is null

			-- Calcula o frete pelo km rodado
			left join #tmp_bf_normal freteKmCidade with (nolock)  on per.pgp_cd_cliente = freteKmCidade.bfm_cd_transportadora
																			and pgto.ppr_base_principal = freteKmCidade.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = freteKmCidade.bfm_cd_tipo_veiculo
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKmCidade.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and freteKmCidade.bfm_nm_cidade is not null
																			and pgto.ppr_nm_cidade = freteKmCidade.bfm_nm_cidade
																			and pgto.ppr_total_km > (freteKmCidade.bfm_vl_inicio_faixa - 1)
																			and pgto.ppr_total_km <= freteKmCidade.bfm_vl_fim_faixa
																			and pgto.ppr_data_referencia between freteKmCidade.bfm_data_inicio_vigencia and isnull(freteKmCidade.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and freteKmCidade.Operacao = @TipoOperacao
																			--and freteKmCidade.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and freteKmCidade.bfm_ds_placa is null
																			and freteKmCidade.CriterioFaixa2 is null

			left join #tmp_bf_normal freteKm with (nolock)  on per.pgp_cd_cliente = freteKm.bfm_cd_transportadora
																			and pgto.ppr_base_principal = freteKm.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = freteKm.bfm_cd_tipo_veiculo

																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and freteKm.bfm_nm_cidade is null
																			and pgto.ppr_total_km > (freteKm.bfm_vl_inicio_faixa - 1)
																			and pgto.ppr_total_km <= freteKm.bfm_vl_fim_faixa
																			and pgto.ppr_data_referencia between freteKm.bfm_data_inicio_vigencia and isnull(freteKm.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and freteKm.Operacao = @TipoOperacao
																			--and freteKm.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and freteKm.bfm_ds_placa is null
																			and freteKm.CriterioFaixa2 is null

			-- =======================================================================
			-- #tmp_bf_placa: com placa, sem paradas (fretePlaca*, frete0a100Placa*)
			-- =======================================================================
			--Regra de placas
			left join #tmp_bf_placa fretePlacaCidade with (nolock)  on per.pgp_cd_cliente = fretePlacaCidade.bfm_cd_transportadora
																			and pgto.ppr_base_principal = fretePlacaCidade.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = fretePlacaCidade.bfm_cd_tipo_veiculo
																			and pgto.ppr_ds_placa = fretePlacaCidade.bfm_ds_placa
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(fretePlacaCidade.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and pgto.ppr_nm_cidade = fretePlacaCidade.bfm_nm_cidade
																			and pgto.ppr_total_km > (fretePlacaCidade.bfm_vl_inicio_faixa - 1)
																			and pgto.ppr_total_km <= fretePlacaCidade.bfm_vl_fim_faixa
																			and pgto.ppr_data_referencia between fretePlacaCidade.bfm_data_inicio_vigencia and isnull(fretePlacaCidade.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and fretePlacaCidade.Operacao = @TipoOperacao
																			--and fretePlacaCidade.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and fretePlacaCidade.CriterioFaixa2 is null

			left join #tmp_bf_placa fretePlaca with (nolock)  on per.pgp_cd_cliente = fretePlaca.bfm_cd_transportadora
																			and pgto.ppr_base_principal = fretePlaca.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = fretePlaca.bfm_cd_tipo_veiculo
																			and pgto.ppr_ds_placa = fretePlaca.bfm_ds_placa
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(fretePlaca.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and fretePlaca.bfm_nm_cidade is null
																			and pgto.ppr_total_km > (fretePlaca.bfm_vl_inicio_faixa - 1)
																			and pgto.ppr_total_km <= fretePlaca.bfm_vl_fim_faixa
																			and pgto.ppr_data_referencia between fretePlaca.bfm_data_inicio_vigencia and isnull(fretePlaca.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and fretePlaca.Operacao = @TipoOperacao
																			--and fretePlaca.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and fretePlaca.CriterioFaixa2 is null

			-- NOVOS JOINS 0a100 PLACA (faixa inicial 0 ou 1)
			left join #tmp_bf_placa frete0a100PlacaCidade on per.pgp_cd_cliente = frete0a100PlacaCidade.bfm_cd_transportadora
																			and pgto.ppr_base_principal = frete0a100PlacaCidade.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = frete0a100PlacaCidade.bfm_cd_tipo_veiculo
																			and pgto.ppr_ds_placa = frete0a100PlacaCidade.bfm_ds_placa
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(frete0a100PlacaCidade.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and pgto.ppr_nm_cidade = frete0a100PlacaCidade.bfm_nm_cidade
																			and frete0a100PlacaCidade.bfm_vl_inicio_faixa in (0,1)
																			and pgto.ppr_data_referencia between frete0a100PlacaCidade.bfm_data_inicio_vigencia and isnull(frete0a100PlacaCidade.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and frete0a100PlacaCidade.Operacao = @TipoOperacao
																			--and frete0a100PlacaCidade.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and frete0a100PlacaCidade.CriterioFaixa2 is null

			left join #tmp_bf_placa frete0a100Placa on per.pgp_cd_cliente = frete0a100Placa.bfm_cd_transportadora
																			and pgto.ppr_base_principal = frete0a100Placa.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = frete0a100Placa.bfm_cd_tipo_veiculo
																			and pgto.ppr_ds_placa = frete0a100Placa.bfm_ds_placa
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(frete0a100Placa.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and frete0a100Placa.bfm_nm_cidade is null
																			and frete0a100Placa.bfm_vl_inicio_faixa in (0,1)
																			and pgto.ppr_data_referencia between frete0a100Placa.bfm_data_inicio_vigencia and isnull(frete0a100Placa.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and frete0a100Placa.Operacao = @TipoOperacao
																			--and frete0a100Placa.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and frete0a100Placa.CriterioFaixa2 is null

			-- =======================================================================
			-- #tmp_bf_paradas: sem placa, com paradas (freteKm*Paradas, freteKm0a100*Paradas)
			-- =======================================================================
			--Cruzamento para segunda faixa (paradas)
			left join #tmp_bf_paradas freteKmCidadeParadas with (nolock)  on per.pgp_cd_cliente = freteKmCidadeParadas.bfm_cd_transportadora
																			and pgto.ppr_base_principal = freteKmCidadeParadas.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = freteKmCidadeParadas.bfm_cd_tipo_veiculo
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKmCidadeParadas.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and freteKmCidadeParadas.bfm_nm_cidade is not null
																			and pgto.ppr_nm_cidade = freteKmCidadeParadas.bfm_nm_cidade
																			and pgto.ppr_total_km > (freteKmCidadeParadas.bfm_vl_inicio_faixa - 1)
																			and pgto.ppr_total_km <= freteKmCidadeParadas.bfm_vl_fim_faixa
																			and pgto.ppr_data_referencia between freteKmCidadeParadas.bfm_data_inicio_vigencia and isnull(freteKmCidadeParadas.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and freteKmCidadeParadas.Operacao = @TipoOperacao
																			--and freteKmCidadeParadas.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and freteKmCidadeParadas.bfm_ds_placa is null
																			and freteKmCidadeParadas.CriterioFaixa2 = 'Paradas'
																			and pgto.ppr_qt_paradas > (freteKmCidadeParadas.bfm_vl_inicio_faixa2 - 1)
																			and pgto.ppr_qt_paradas <= freteKmCidadeParadas.bfm_vl_fim_faixa2

			left join #tmp_bf_paradas freteKmParadas with (nolock)  on per.pgp_cd_cliente = freteKmParadas.bfm_cd_transportadora
																			and pgto.ppr_base_principal = freteKmParadas.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = freteKmParadas.bfm_cd_tipo_veiculo

																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKmParadas.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and freteKmParadas.bfm_nm_cidade is null
																			and pgto.ppr_total_km > (freteKmParadas.bfm_vl_inicio_faixa - 1)
																			and pgto.ppr_total_km <= freteKmParadas.bfm_vl_fim_faixa
																			and pgto.ppr_data_referencia between freteKmParadas.bfm_data_inicio_vigencia and isnull(freteKmParadas.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and freteKmParadas.Operacao = @TipoOperacao
																			--and freteKmParadas.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and freteKmParadas.bfm_ds_placa is null
																			and freteKmParadas.CriterioFaixa2 = 'Paradas'
																			and pgto.ppr_qt_paradas > (freteKmParadas.bfm_vl_inicio_faixa2 - 1)
																			and pgto.ppr_qt_paradas <= freteKmParadas.bfm_vl_fim_faixa2

			-- NOVOS JOINS 0a100 PARADAS (faixa inicial 0 ou 1, faixa2 inicial 0 ou 1)
			left join #tmp_bf_paradas freteKm0a100CidadeParadas on per.pgp_cd_cliente = freteKm0a100CidadeParadas.bfm_cd_transportadora
																			and pgto.ppr_base_principal = freteKm0a100CidadeParadas.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = freteKm0a100CidadeParadas.bfm_cd_tipo_veiculo
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm0a100CidadeParadas.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and freteKm0a100CidadeParadas.bfm_nm_cidade is not null
																			and pgto.ppr_nm_cidade = freteKm0a100CidadeParadas.bfm_nm_cidade
																			and freteKm0a100CidadeParadas.bfm_vl_inicio_faixa in (0,1)
																			and pgto.ppr_data_referencia between freteKm0a100CidadeParadas.bfm_data_inicio_vigencia and isnull(freteKm0a100CidadeParadas.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and freteKm0a100CidadeParadas.Operacao = @TipoOperacao
																			--and freteKm0a100CidadeParadas.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and freteKm0a100CidadeParadas.CriterioFaixa2 = 'Paradas'
																			and freteKm0a100CidadeParadas.bfm_vl_inicio_faixa2 in (0,1)
																			and freteKm0a100CidadeParadas.bfm_ds_placa is null

			left join #tmp_bf_paradas freteKm0a100Paradas on per.pgp_cd_cliente = freteKm0a100Paradas.bfm_cd_transportadora
																			and pgto.ppr_base_principal = freteKm0a100Paradas.bfm_cd_service_center
																			and veic.tvl_cd_tipo_veiculo = freteKm0a100Paradas.bfm_cd_tipo_veiculo
																			and (
																					(@ParamUtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm0a100Paradas.bmf_cd_tipo_contrato,-1))
																					or
																					@ParamUtilizaContrato = 0
																			)
																			and (freteKm0a100Paradas.bfm_nm_cidade is null or freteKm0a100Paradas.bfm_nm_cidade = '')
																			and freteKm0a100Paradas.bfm_vl_inicio_faixa in (0,1)
																			and pgto.ppr_data_referencia between freteKm0a100Paradas.bfm_data_inicio_vigencia and isnull(freteKm0a100Paradas.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
																			and freteKm0a100Paradas.Operacao = @TipoOperacao
																			--and freteKm0a100Paradas.bfm_cd_codigo_cliente = @IdCliTransportadora
																			and freteKm0a100Paradas.CriterioFaixa2 = 'Paradas'
																			and freteKm0a100Paradas.bfm_vl_inicio_faixa2 in (0,1)
																			and freteKm0a100Paradas.bfm_ds_placa is null

		-- =================================================================================
		-- NOVO: OVERRIDE DE FRETE AMBULÂNCIA AM/PM
		-- Para rotas com ppr_in_ambulancia = 1, sobrescreve SaidaKm0a100 e SaidaKm pelo
		-- valor de frete ambulância configurado conforme o ciclo:
		--   AM  -> AmbulanciaFreteAM
		--   PM/SD -> AmbulanciaFretePM
		-- Fallback (isnull) ao valor já calculado quando o valor ambulância for nulo
		-- (mantém o cálculo normal existente). Propaga automaticamente para o update
		-- final de ppr_vl_base / ppr_vl_base_calculado, preservando as regras
		-- PagarPrimeiraFaixaAmbulancia, PagarPorPacote, ValorFixoSD, etc.
		-- =================================================================================
		update #pagamento_base
		set
			 SaidaKm0a100 = case when ppr_ds_ciclo = 'AM'
			                     then isnull(AmbulanciaFreteAM, SaidaKm0a100)
			                     when ppr_ds_ciclo in ('PM','SD')
			                     then isnull(AmbulanciaFretePM, SaidaKm0a100)
			                end
			,SaidaKm      = case when ppr_ds_ciclo = 'AM'
			                     then isnull(AmbulanciaFreteAM, SaidaKm)
			                     when ppr_ds_ciclo in ('PM','SD')
			                     then isnull(AmbulanciaFretePM, SaidaKm)
			                end
		where ppr_in_ambulancia = 1
		  and (AmbulanciaFreteAM is not null or AmbulanciaFretePM is not null);

		------------------------------------------------------------
		-- EXCLUI ROTAS DUPLICADAS
		------------------------------------------------------------

		--verifica se existe rotas duplicadas
		drop table if exists #rotas_duplicadas
		select
			ppr_cd_periodo
			,ppr_cd_cliente_transportadora
			,ppr_cd_operacao
			,ppr_cd_rota
			into #rotas_duplicadas
		from
			#pagamento_base
		group by
			ppr_cd_periodo
			,ppr_cd_cliente_transportadora
			,ppr_cd_operacao
			,ppr_cd_rota
		having
			count(1) > 1


		--insere na tabela de erro
		insert into tb_pgto_periodo_rota_erro (pre_cd_periodo, pre_cd_cliente_transportadora, pre_cd_operacao, pre_cd_rota, pre_base, pre_ds_erro, pre_dh_criacao)
		select
			distinct
			d.ppr_cd_periodo
			,d.ppr_cd_cliente_transportadora
			,d.ppr_cd_operacao
			,d.ppr_cd_rota
			,r.ppr_base_principal
			,'Rotas duplicadas ao calcular valor saída' pee_ds_erro
			,getdate() pee_dh_criacao
		from
			#rotas_duplicadas d
			join #pagamento_base r on d.ppr_cd_rota = r.ppr_cd_rota


		--remove rotas duplicados
		delete
			r
		from
			#pagamento_base r
			join #rotas_duplicadas r2 on r.ppr_cd_rota = r2.ppr_cd_rota


		------------------------------------------------------------
		-- LIMPEZA DAS TABELAS TEMPORÁRIAS DE FRETE
		------------------------------------------------------------
		drop table if exists #tmp_bf_normal
		drop table if exists #tmp_bf_placa
		drop table if exists #tmp_bf_paradas
		drop table if exists #tmp_bfa

		------------------------------------------------------------
		-- SALVA VALOR BASE DA ROTA QUE FOI CALCULADO
		------------------------------------------------------------
		--atualiza apenas rotas de espelhos em aberto
		update
			pgto
		set
			pgto.ppr_vl_base = case when base.ppr_in_zerar_rota = 1 then 0
							   else case when base.ppr_zerar_ambulancia = 'true' and base.ppr_in_ambulancia = 1 then 0
							   else case when base.ZerarAmbulanciaNaoAprovada = 1 and base.ppr_in_ambulancia = 1 and base.ppr_in_ambulancia_aprovada = 0 then 0
							   else case when base.ValorFixoPlacaRota is not null then ValorFixoPlacaRota
							   else case when base.PagarPorPacote = 1 then isnull(base.SaidaKm0a100,0) * isnull(base.ppr_qt_pacotes,0)
							   else case when base.PagarPorPacoteEntregue = 1 then isnull(base.SaidaKm0a100,0) * isnull(base.ppr_qt_pacotes_entregues,0)
							   else case when base.PagarPrimeiraFaixaAmbulancia = 1 and base.ppr_in_ambulancia = 1 and base.ValorFixoSD is null then isnull(base.SaidaKm0a100,0)
							   else case when base.ppr_ambulancia_1_faixa_sem_adicional = 'true' and base.ppr_in_ambulancia = 1 then isnull(base.SaidaKm0a100,0)
							   else case when base.ValorFixoSD is not null then base.ValorFixoSD
							   else isnull(base.SaidaKm,0) end end end end end end end end end

			,pgto.ppr_vl_base_calculado = case when base.ValorFixoPlacaRota is not null then ValorFixoPlacaRota
											   else case when base.PagarPorPacote = 1 then isnull(base.SaidaKm0a100,0) * isnull(base.ppr_qt_pacotes,0)
											   else case when base.PagarPorPacoteEntregue = 1 then isnull(base.SaidaKm0a100,0) * isnull(base.ppr_qt_pacotes_entregues,0)
											   else case when base.PagarPrimeiraFaixaAmbulancia = 1 and base.ppr_in_ambulancia = 1 and base.ValorFixoSD is null then isnull(base.SaidaKm0a100,0)
											   else case when base.ppr_ambulancia_1_faixa_sem_adicional = 'true' and base.ppr_in_ambulancia = 1 then isnull(base.SaidaKm0a100,0)
											   else case when base.ValorFixoSD is not null then base.ValorFixoSD
											   else isnull(base.SaidaKm,0) end end end end end end

			,pgto.ppr_cd_desconto_sd = base.ppr_cd_desconto_sd

			,pgto.ppr_cd_faixa_km = case when base.PagarPorPacote = 1 
										or base.PagarPorPacoteEntregue = 1 
										or (base.PagarPrimeiraFaixaAmbulancia = 1 and base.ppr_in_ambulancia = 1)
										or (base.ppr_ambulancia_1_faixa_sem_adicional = 'true' and base.ppr_in_ambulancia = 1)
										then FaixaKm0a100
									else FaixaKm end

			,pgto.ppr_in_calcular_adicional = case when base.ppr_in_zerar_rota = 1
														or (base.ZerarAmbulanciaNaoAprovada = 1 and base.ppr_in_ambulancia = 1 and base.ppr_in_ambulancia_aprovada = 0)
														or (base.ppr_zerar_ambulancia = 'true' and base.ppr_in_ambulancia = 1) 
														or (base.ppr_ambulancia_1_faixa_sem_adicional = 'true' and base.ppr_in_ambulancia = 1)
														then 0 else 1 end

			,pgto.ppr_motivo_rota_zerada = case
											when base.ppr_in_zerar_rota = 1 then isnull(base.ppr_motivo_rota_zerada,'Rota alterada manualmente para ser zerada.')
											when base.ZerarAmbulanciaNaoAprovada = 1 and base.ppr_in_ambulancia = 1 and base.ppr_in_ambulancia_aprovada = 0 then 'Ambulância zerada por falta de aprovação do Meli.'
											when base.ppr_zerar_ambulancia = 'true' and base.ppr_in_ambulancia = 1 then 'Ambulância'
										  end
		from
			tb_pgto_periodo_rota pgto
			join #pagamento_base base on pgto.ppr_cd_pagamento_rota = base.ppr_cd_pagamento_rota


		--zera valores de quem não faz parte do critério
		update
			pgto
		set
			pgto.ppr_vl_base = 0
			,pgto.ppr_cd_desconto_sd = 0
			,pgto.ppr_cd_faixa_km = case when base.PagarPorPacote = 1 or base.PagarPorPacoteEntregue = 1 or (base.PagarPrimeiraFaixaAmbulancia = 1 and base.ppr_in_ambulancia = 1) then FaixaKm0a100
									else FaixaKm end
			,pgto.ppr_in_calcular_adicional = 0
			,pgto.ppr_motivo_rota_zerada = case
												when base.ppr_in_zerar_rota = 1 then isnull(base.ppr_motivo_rota_zerada,'Rota alterada manualmente para ser zerada.')
												when base.ppr_zerar_ambulancia = 'true' and base.ppr_in_ambulancia = 1 then 'Ambulância'
												when (base.CriterioPagamento = 'Ter pacotes entregues' and pgto.ppr_qt_pacotes_entregues = 0) then 'Rota sem pacotes entregues.'
												when (base.CriterioPagamento = 'Ter percentual mínimo de endereço não visitado' and isnull(pgto.ppr_per_endereco_nao_visitado,0) < base.PercentualMinimoEnderecoNaoVisitado) then 'Rota abaixo de 90% de endereço visitado.'
												when (base.ZerarAmbulanciaNaoAprovada = 1 and base.ppr_in_ambulancia = 1 and base.ppr_in_ambulancia_aprovada = 0) then 'Ambulância zerada por falta de aprovação do Meli.'
											end
		from
			tb_pgto_periodo_rota pgto
			join #pagamento_base base on pgto.ppr_cd_pagamento_rota = base.ppr_cd_pagamento_rota
		where
			(base.CriterioPagamento = 'Ter pacotes entregues' and pgto.ppr_qt_pacotes_entregues = 0)
			or
			(base.CriterioPagamento = 'Ter percentual mínimo de endereço não visitado' and isnull(pgto.ppr_per_endereco_nao_visitado,0) < base.PercentualMinimoEnderecoNaoVisitado)
			or
			(base.ZerarAmbulanciaNaoAprovada = 1 and base.ppr_in_ambulancia = 1 and base.ppr_in_ambulancia_aprovada = 0)
			or
			(base.ppr_zerar_ambulancia = 'true' and base.ppr_in_ambulancia = 1)


		/*regra de pagamento de ambulancia para Hawk

		SE A ROTA FOR AMBULÂNCIA E ELE ENTREGAR MENOS DE 30 PACOTES, PASSA A RECEBER POR PACOTE
		R$3,00 POR PACOTE PARA PASSEIO, VAN OU UTILITÁRIO
		R$10,00 POR PACOTE PARA VUC

		Veiculos que não estão citados estão com o vl_pacote_ambulancia_regra zerado e mantem o valor base
		*/

		update
			tb_pgto_periodo_rota
		set
			ppr_vl_base =  pgto.ppr_qt_pacotes_entregues * bfa_vl_pacote_ambulancia
		from
			tb_pgto_periodo_rota pgto
			join #pagamento_base base on pgto.ppr_cd_pagamento_rota = base.ppr_cd_pagamento_rota
		where
			-- Validacoes de regra da ambulancia
			pgto.ppr_in_ambulancia = 1
			and base.bfa_qtd_pacote_ambulancia is not null
			and base.bfa_vl_pacote_ambulancia is not null
			and pgto.ppr_qt_pacotes_entregues < base.bfa_qtd_pacote_ambulancia


	end

end
GO
