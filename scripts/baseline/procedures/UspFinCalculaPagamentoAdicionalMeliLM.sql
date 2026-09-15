-- ============================================================
-- BASELINE: dbo.UspFinCalculaPagamentoAdicionalMeliLM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinCalculaPagamentoAdicionalMeliLM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 21/03/2026
-- Description:	Calcula pagamento adicional: paradas, domingo, pacotes, etc.
--				Atualiza tb_pgto_periodo_rota (valores adicionais)
-- =============================================
CREATE PROCEDURE [dbo].[UspFinCalculaPagamentoAdicionalMeliLM] (
	@CodPeriodoPagamento int
	,@IdRota int = null
	,@CodEspelho int = null
	,@CodUsuario int = null
)
AS
BEGIN

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
		declare @CodigoCliente int
		declare @DataInicial date
		declare @DataFinal date
		declare @Operacao int
		declare @IdCliTransportadora int

		select
			@CodigoCliente = pgp_cd_cliente
			,@DataInicial = pgp_dt_inicio
			,@DataFinal = pgp_dt_fim
			,@Operacao = pgp_tipo_operacao
			,@IdCliTransportadora = pgp_cd_cliente_transportadora
		from
			tb_pgto_periodo with(nolock)
		where
			pgp_cd_periodo = @CodPeriodoPagamento

		set @CodUsuario = case when @CodUsuario is null then 7 else @CodUsuario end

		declare @IdTransportadora int = (select cli_id_logistics from tb_clientes with(nolock) where cli_cd_codigo_cliente = @CodigoCliente)

		------------------------------------------------------------
		-- PARAMETRIZAÇÃO FINANCEIRO DO CLIENTE
		------------------------------------------------------------
		declare @ParamUtilizaContrato int = isnull(
												(select
													prm_ds_valor
												from
													tb_parametros with(nolock)
												where
													prm_ds_categoria = 'Financeiro - Pagamentos'
													and prm_nm_parametro = 'Utiliza contrato'
													and prm_cod_cliente = @CodigoCliente
													and prm_in_ativo = 1
													and prm_in_excluido = 0
												)
											,0)

		------------------------------------------------------------
		-- CALCULA PAGAMENTO ADICIONAL
		------------------------------------------------------------
		drop table if exists #tb_pgto_periodo_rota
		select
			p.ppr_cd_pagamento_rota
			,p.ppr_cd_periodo
			,p.ppr_cd_rota
			,p.ppr_cd_motorista_nfs
			,p.ppr_ds_tipo_veiculo
			,ppr_base_principal
			,isnull(ppr_base_calculo,ppr_base_principal) ppr_base_calculo
			,p.ppr_data_referencia
			,p.ppr_nm_cidade
			,p.ppr_qt_pacotes
			,p.ppr_qt_pacotes_entregues
			,p.ppr_cd_faixa_km
			,p.ppr_ds_placa
			,p.ppr_ds_ciclo
			,p.ppr_qt_faixa
			,p.ppr_qt_paradas
			,p.ppr_qt_pontos
			,p.ppr_in_area_risco
			,p.ppr_in_ajudante
			,p.ppr_in_dom
			,p.ppr_in_fer
			,p.ppr_in_dom_fer
			,p.ppr_in_ambulancia
			,p.ppr_vl_base
			,p.ppr_total_km
			,p.ppr_cd_desconto_sd
			,p.ppr_vl_insucessos
			,p.ppr_in_calcular_adicional
			,@IdCliTransportadora ppr_cd_cliente_transportadora
			,@Operacao ppr_cd_operacao
			into #tb_pgto_periodo_rota
		from
			tb_pgto_periodo_rota p
			join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
										and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
										and e.mtn_cd_operacao = @Operacao
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento
			and p.ppr_cd_tipo_pgto = 1362
			and p.ppr_in_excluido = 0
			and e.mtn_cd_status in (34,228,38,1298)
			and p.ppr_in_calcular_adicional = 1
		
		

		-- Regra específica de Area Risco por cliente (parametrizável) -- Setado como risco igual a 1 e controlado na tabela de adicionais
		--Se tiver valor cadastrado paga
		if @CodigoCliente = 56
		begin
			update
				a
			set
				ppr_in_area_risco = 1
			from
				#tb_pgto_periodo_rota a
		end



		drop table if exists #tb_parametro_paradas_km
		select
			bfp_cd_adcional_parada
			,bfa_cd_adicional_motorista
			,bfa_fx_ini
			,bfa_fx_fim
			,bfa_fx_fim - isnull(lag(bfa_fx_fim) over (partition by bfa_cd_adicional_motorista order by bfp_cd_adcional_parada), 0) as bfa_fx_multiplicador
			,bfa_fx_valor
			,bfa_fx_ini_2
			,bfa_fx_fim_2
			,bfa_dia_util
			,bfa_tipo_valor
			,tipo_fx_1
			,tipo_fx_2
		into #tb_parametro_paradas_km
		from
			tb_fin_base_frete_adicional_motorista_parada

		drop table if exists #tb_pgto_periodo_rota_calc
		;with adicionais as (
			select
				a.ppr_cd_periodo
				,a.ppr_cd_rota
				,a.ppr_cd_pagamento_rota
				,a.ppr_cd_cliente_transportadora
				,a.ppr_cd_operacao
				,coalesce(adcplaca.bfa_cd_base_frete_adicional_motorista, adplaca.bfa_cd_base_frete_adicional_motorista, adc.bfa_cd_base_frete_adicional_motorista, ad.bfa_cd_base_frete_adicional_motorista) as bfa_cd_base_frete_adicional_motorista
				,nullif(a.ppr_qt_pacotes_entregues, 0) / cast(nullif(a.ppr_qt_pacotes, 0) as decimal(9,2)) as ppr_vl_success_delivery
				,coalesce(adcplaca.bfa_tipo_adicional_risco, adplaca.bfa_tipo_adicional_risco, adc.bfa_tipo_adicional_risco, ad.bfa_tipo_adicional_risco) as tipo_risco
				,coalesce(adcplaca.bfa_vl_adicional_risco, adplaca.bfa_vl_adicional_risco, adc.bfa_vl_adicional_risco, ad.bfa_vl_adicional_risco) as vl_risco
				,coalesce(adcplaca.bfa_tipo_adicional_ajudante, adplaca.bfa_tipo_adicional_ajudante, adc.bfa_tipo_adicional_ajudante, ad.bfa_tipo_adicional_ajudante) as tipo_ajudante
				,coalesce(adcplaca.bfa_vl_adicional_ajudante, adplaca.bfa_vl_adicional_ajudante, adc.bfa_vl_adicional_ajudante, ad.bfa_vl_adicional_ajudante) as vl_ajudante
				,coalesce(adcplaca.bfa_tipo_adicional_domingo, adplaca.bfa_tipo_adicional_domingo, adc.bfa_tipo_adicional_domingo, ad.bfa_tipo_adicional_domingo) as tipo_domingo
				,coalesce(adcplaca.bfa_vl_adicional_domingo, adplaca.bfa_vl_adicional_domingo, adc.bfa_vl_adicional_domingo, ad.bfa_vl_adicional_domingo) as vl_domingo
				,coalesce(adcplaca.bfa_vl_adicional_recarga, adplaca.bfa_vl_adicional_recarga, adc.bfa_vl_adicional_recarga, ad.bfa_vl_adicional_recarga) as vl_recarga
				,coalesce(adcplaca.bfa_tipo_adicional_feriado, adplaca.bfa_tipo_adicional_feriado, adc.bfa_tipo_adicional_feriado, ad.bfa_tipo_adicional_feriado) as tipo_feriado
				,coalesce(adcplaca.bfa_vl_adicional_feriado, adplaca.bfa_vl_adicional_feriado, adc.bfa_vl_adicional_feriado, ad.bfa_vl_adicional_feriado) as vl_feriado
				,coalesce(adcplaca.bfa_tipo_adicional_ciclo_pm, adplaca.bfa_tipo_adicional_ciclo_pm, adc.bfa_tipo_adicional_ciclo_pm, ad.bfa_tipo_adicional_ciclo_pm) as tipo_desc_ciclo_pm
				,coalesce(adcplaca.bfa_vl_adicional_ciclo_pm, adplaca.bfa_vl_adicional_ciclo_pm, adc.bfa_vl_adicional_ciclo_pm, ad.bfa_vl_adicional_ciclo_pm) as vl_desc_ciclo_pm
				,coalesce(adcplaca.bfa_perc_ds, adplaca.bfa_perc_ds, adc.bfa_perc_ds, ad.bfa_perc_ds) as perc_ds
				,coalesce(adcplaca.bfa_tipo_bonus_ds, adplaca.bfa_tipo_bonus_ds, adc.bfa_tipo_bonus_ds, ad.bfa_tipo_bonus_ds) as bfa_tipo_bonus_ds
				,coalesce(adcplaca.bfa_vl_bonus_ds, adplaca.bfa_vl_bonus_ds, adc.bfa_vl_bonus_ds, ad.bfa_vl_bonus_ds) as vl_bonus_ds
				,coalesce(adcplaca.bfa_tipo_adicional_faixa, adplaca.bfa_tipo_adicional_faixa, adc.bfa_tipo_adicional_faixa, ad.bfa_tipo_adicional_faixa) as bfa_tipo_adicional_faixa
				,coalesce(adcplaca.bfa_tipo_adicional_rota, adplaca.bfa_tipo_adicional_rota, adc.bfa_tipo_adicional_rota, ad.bfa_tipo_adicional_rota) as bfa_tipo_adicional_rota
				,coalesce(adcplaca.bfa_vl_adicional_rota, adplaca.bfa_vl_adicional_rota, adc.bfa_vl_adicional_rota, ad.bfa_vl_adicional_rota) as bfa_vl_adicional_rota
				,coalesce(adcplaca.bfa_calcula_por_parada, adplaca.bfa_calcula_por_parada, adc.bfa_calcula_por_parada, ad.bfa_calcula_por_parada) as bfa_calcula_por_parada
				,coalesce(adcplaca.bfa_vl_adicional, adplaca.bfa_vl_adicional, adc.bfa_vl_adicional, ad.bfa_vl_adicional) as bfa_vl_adicional
				,coalesce(adcplaca.bfa_tipo_adicional_ajudante_dom, adplaca.bfa_tipo_adicional_ajudante_dom, adc.bfa_tipo_adicional_ajudante_dom, ad.bfa_tipo_adicional_ajudante_dom) as bfa_tipo_adicional_ajudante_dom
				,coalesce(adcplaca.bfa_vl_adicional_ajudante_dom, adplaca.bfa_vl_adicional_ajudante_dom, adc.bfa_vl_adicional_ajudante_dom, ad.bfa_vl_adicional_ajudante_dom) as bfa_vl_adicional_ajudante_dom
				,coalesce(adcplaca.bfa_tipo_adicional, adplaca.bfa_tipo_adicional, adc.bfa_tipo_adicional, ad.bfa_tipo_adicional) as bfa_tipo_adicional
				,coalesce(adcplaca.bfa_qtd_pacote_ambulancia, adplaca.bfa_qtd_pacote_ambulancia, adc.bfa_qtd_pacote_ambulancia, ad.bfa_qtd_pacote_ambulancia, adcplaca.bfa_zera_adicional_ambulancia, adplaca.bfa_zera_adicional_ambulancia, adc.bfa_zera_adicional_ambulancia, ad.bfa_zera_adicional_ambulancia) as regra_ambulancia
			from
				#tb_pgto_periodo_rota a
				inner join tb_pag_espelhos b on b.mtn_cd_motorista_nfs = a.ppr_cd_motorista_nfs
				left join tb_dra_tipo_veiculo tv on a.ppr_ds_tipo_veiculo = tv.tvl_nm_tipo_veiculo
				left join tb_fin_base_frete_adicional_motorista ad on b.mtn_cod_cliente = ad.bfa_cd_transportadora
													and a.ppr_base_calculo = ad.bfa_cd_service_center
													and tv.tvl_cd_tipo_veiculo = ad.bfa_cd_tipo_veiculo
													and ad.bfa_nm_cidade is null
													and (
															(@ParamUtilizaContrato = 1 and isnull(b.mtn_cd_tipo_contrato, -1) = isnull(ad.bfa_cd_tipo_contrato, -1))
															or @ParamUtilizaContrato = 0
														)
													and a.ppr_data_referencia between ad.bfa_data_inicio_vigencia and isnull(ad.bfa_data_fim_vigencia, convert(date, dateadd(year, 1, getdate())))
													and ad.bfa_cd_operacao = @Operacao
													and ad.bfa_cd_codigo_cliente = @IdCliTransportadora
													and ad.bfa_ds_placa is null

				left join tb_fin_base_frete_adicional_motorista adc on b.mtn_cod_cliente = adc.bfa_cd_transportadora
													and a.ppr_base_calculo = adc.bfa_cd_service_center
													and tv.tvl_cd_tipo_veiculo = adc.bfa_cd_tipo_veiculo
													and a.ppr_nm_cidade = adc.bfa_nm_cidade
													and (
															(@ParamUtilizaContrato = 1 and isnull(b.mtn_cd_tipo_contrato, -1) = isnull(adc.bfa_cd_tipo_contrato, -1))
															or @ParamUtilizaContrato = 0
														)
													and a.ppr_data_referencia between adc.bfa_data_inicio_vigencia and isnull(adc.bfa_data_fim_vigencia, convert(date, dateadd(year, 1, getdate())))
													and adc.bfa_cd_operacao = @Operacao
													and adc.bfa_cd_codigo_cliente = @IdCliTransportadora
													and adc.bfa_ds_placa is null

				left join tb_fin_base_frete_adicional_motorista adcplaca on b.mtn_cod_cliente = adcplaca.bfa_cd_transportadora
													and a.ppr_base_calculo = adcplaca.bfa_cd_service_center
													and tv.tvl_cd_tipo_veiculo = adcplaca.bfa_cd_tipo_veiculo
													and a.ppr_ds_placa = adcplaca.bfa_ds_placa
													and a.ppr_nm_cidade = adcplaca.bfa_nm_cidade
													and (
															(@ParamUtilizaContrato = 1 and isnull(b.mtn_cd_tipo_contrato, -1) = isnull(adcplaca.bfa_cd_tipo_contrato, -1))
															or @ParamUtilizaContrato = 0
														)
													and a.ppr_data_referencia between adcplaca.bfa_data_inicio_vigencia and isnull(adcplaca.bfa_data_fim_vigencia, convert(date, dateadd(year, 1, getdate())))
													and adcplaca.bfa_cd_operacao = @Operacao
													and adcplaca.bfa_cd_codigo_cliente = @IdCliTransportadora
				
				left join tb_fin_base_frete_adicional_motorista adplaca on b.mtn_cod_cliente = adplaca.bfa_cd_transportadora
													and a.ppr_base_calculo = adplaca.bfa_cd_service_center
													and tv.tvl_cd_tipo_veiculo = adplaca.bfa_cd_tipo_veiculo
													and a.ppr_ds_placa = adplaca.bfa_ds_placa
													and adplaca.bfa_nm_cidade is null
													and (
															(@ParamUtilizaContrato = 1 and isnull(b.mtn_cd_tipo_contrato, -1) = isnull(adplaca.bfa_cd_tipo_contrato, -1))
															or @ParamUtilizaContrato = 0
														)
													and a.ppr_data_referencia between adplaca.bfa_data_inicio_vigencia and isnull(adplaca.bfa_data_fim_vigencia, convert(date, dateadd(year, 1, getdate())))
													and adplaca.bfa_cd_operacao = @Operacao
													and adplaca.bfa_cd_codigo_cliente = @IdCliTransportadora
		)
		select
			a.ppr_cd_pagamento_rota
			,a.ppr_cd_periodo
			,a.ppr_cd_rota
			,a.ppr_cd_cliente_transportadora
			,a.ppr_cd_operacao
			,a.ppr_cd_faixa_km
			,a.ppr_ds_placa
			,a.ppr_ds_tipo_veiculo
			,a.ppr_ds_ciclo
			,a.ppr_qt_faixa
			,a.ppr_qt_paradas
			,a.ppr_qt_pontos
			,a.ppr_in_area_risco
			,a.ppr_in_ajudante
			,a.ppr_in_dom
			,a.ppr_in_fer
			,a.ppr_in_dom_fer
			,a.ppr_in_ambulancia
			,a.ppr_vl_base
			,bfa_cd_base_frete_adicional_motorista
			,a.ppr_base_principal
			,a.ppr_total_km
			,a.ppr_qt_pacotes
			,a.ppr_qt_pacotes_entregues
			,regra_ambulancia
			,a.ppr_cd_desconto_sd
			,case when a.ppr_in_dom_fer = 1 then 0 else 1 end as ppr_dia_util
			,case when bfa_tipo_adicional = 1 then bfa_vl_adicional * a.ppr_qt_paradas else bfa_vl_adicional end as bfa_vl_adicional
			,cast(0.00 as decimal(7,2)) as ppr_vl_paradas
			,cast(0.00 as decimal(7,2)) as ppr_vl_faixa
			,case
				when ad.tipo_risco = 1 and a.ppr_in_area_risco = 1 then (ad.vl_risco / 100) * a.ppr_vl_base
				when ad.tipo_risco = 2 and a.ppr_in_area_risco = 1 then ad.vl_risco
				else 0
			end as ppr_vl_risco
			,case
				when a.ppr_in_dom_fer = 1 then
					case
						when isnull(ad.bfa_tipo_adicional_ajudante_dom, ad.tipo_ajudante) = 1 then (isnull(ad.bfa_vl_adicional_ajudante_dom, ad.vl_ajudante) / 100) * a.ppr_vl_base
						when isnull(ad.bfa_tipo_adicional_ajudante_dom, ad.tipo_ajudante) = 2 then isnull(ad.bfa_vl_adicional_ajudante_dom, ad.vl_ajudante)
						else 0
					end
				else
					case
						when ad.tipo_ajudante = 1 then (ad.vl_ajudante / 100) * a.ppr_vl_base
						when ad.tipo_ajudante = 2 then ad.vl_ajudante
						else 0
					end
			end as ppr_vl_ajudante
			,case
				when ad.tipo_domingo = 1 and a.ppr_in_dom_fer = 1 then (ad.vl_domingo / 100) * a.ppr_vl_base
				when ad.tipo_domingo = 2 and a.ppr_in_dom_fer = 1 then ad.vl_domingo
				else 0
			end as ppr_vl_dom
			,case
				when ad.tipo_feriado = 1 and a.ppr_in_fer = 1 then (ad.vl_feriado / 100) * a.ppr_vl_base
				when ad.tipo_feriado = 2 and a.ppr_in_fer = 1 then ad.vl_feriado
				else 0
			end as ppr_vl_fer
			,a.ppr_vl_insucessos
			,ad.ppr_vl_success_delivery
			,case
				when ad.bfa_tipo_bonus_ds = 1 and ad.ppr_vl_success_delivery >= ad.perc_ds and ad.perc_ds > 0 then (ad.vl_bonus_ds / 100) * a.ppr_vl_base
				when ad.bfa_tipo_bonus_ds = 2 and ad.ppr_vl_success_delivery >= ad.perc_ds and ad.perc_ds > 0 then ad.vl_bonus_ds
				else 0
			end as ppr_vl_bonus_ds
			,cast(0.00 as decimal(7,2)) as ppr_vl_bonus
			,case
				when ad.tipo_desc_ciclo_pm = 1 and a.ppr_ds_ciclo = 'PM' then (ad.vl_desc_ciclo_pm / 100) * a.ppr_vl_base
				when ad.tipo_desc_ciclo_pm = 2 and a.ppr_ds_ciclo = 'PM' then ad.vl_desc_ciclo_pm
				else 0
			end * -1 as ppr_vl_pm
			,pedagios.atp_dc_valor as ppr_vl_pedagio
			,cast(0.00 as decimal(7,2)) as ppr_vl_aluguel
			,cast(0.00 as decimal(7,2)) as ppr_vl_desconto
			,ad.vl_recarga as ppr_vl_recarga
			,cast(0.00 as decimal(7,2)) as ppr_vl_pontos
			,cast(0.00 as decimal(7,2)) as ppr_vl_pacotes
			,cast(0.00 as decimal(7,2)) as ppr_vl_desconto_flex_rota
			,cast(0.00 as decimal(7,2)) as ppr_vl_desconto_cartao_flex_rota
			,cast(0.00 as decimal(7,2)) as ppr_vl_adicional_km
			,ad.bfa_tipo_adicional_faixa
			,case
				when ad.bfa_tipo_adicional_rota = 1 then ad.bfa_vl_adicional_rota
				else 0
			end as ppr_vl_rota
			,isnull(ad.bfa_calcula_por_parada, 1) as bfa_calcula_por_parada
			,case when isnull(ad.bfa_calcula_por_parada, 1) = 1 then a.ppr_qt_paradas else a.ppr_qt_pontos end as ppr_ponto_parada
			,cast(0 as decimal(10,2)) as ppr_vl_ponto_parada
		into #tb_pgto_periodo_rota_calc
		from
			#tb_pgto_periodo_rota a
			join adicionais ad
				on a.ppr_cd_periodo = ad.ppr_cd_periodo
				and a.ppr_cd_rota = ad.ppr_cd_rota
				and a.ppr_cd_pagamento_rota = ad.ppr_cd_pagamento_rota
			left join (
						select
							atp_ds_rota
							,atp_cd_codigo_cliente
							,sum(atp_dc_valor) as atp_dc_valor
						from
							tb_atm_pedagios with(nolock)
						where
							atp_in_excluido = 0
							and atp_cd_codigo_status = 1
						group by
							atp_ds_rota
							,atp_cd_codigo_cliente
					) pedagios
				on cast(a.ppr_cd_rota as varchar(50)) = pedagios.atp_ds_rota
				and pedagios.atp_cd_codigo_cliente = @CodigoCliente

		
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
			#tb_pgto_periodo_rota_calc
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
			,'Rotas duplicadas ao calcular adicional' pee_ds_erro
			,getdate() pee_dh_criacao
		from
			#rotas_duplicadas d
			join #tb_pgto_periodo_rota_calc r on d.ppr_cd_rota = r.ppr_cd_rota


		--remove rotas duplicados
		delete
			r
		from
			#tb_pgto_periodo_rota_calc r
			join #rotas_duplicadas r2 on r.ppr_cd_rota = r2.ppr_cd_rota
		
		


		------------------------------------------------------------
		-- ATUALIZA VALOR DOS ADICIONAIS
		------------------------------------------------------------

		-- Documentação: tb_lista — Tipos de calculos para pagamento de adicionais por faixa de ponto ou paradas (bfa_tipo_adicional_faixa)

		-- Calcula adicional de paradas por quantidade / faixa
		update
			a
		set
			a.ppr_vl_ponto_parada = isnull(b.ppr_vl_paradas, 0)
		from
			#tb_pgto_periodo_rota_calc as a
			inner join (
						select
							a.bfa_cd_base_frete_adicional_motorista
							,a.ppr_cd_rota
							,sum(
								case
									when ppr_ponto_parada >= bfa_fx_ini
										then (
												(case when ppr_ponto_parada < bfa_fx_fim then ppr_ponto_parada else bfa_fx_fim end)
												- case when bfa_fx_ini = 0 then bfa_fx_ini else bfa_fx_ini - 1 end
											) * bfa_fx_valor
									else 0
								end
							) as ppr_vl_paradas
						from
							#tb_pgto_periodo_rota_calc as a
							inner join (
										select
											bfp_cd_adcional_parada
											,bfa_cd_adicional_motorista
											,bfa_fx_ini
											,bfa_fx_fim
											,bfa_fx_valor
											,bfa_tipo_valor
											,bfa_dia_util
										from
											#tb_parametro_paradas_km
										where
											bfa_tipo_valor = 3
											and isnull(tipo_fx_1,1331) in (1331,1332) --considera apenas parada ou ponto
									) as adcParadaCalc
								on adcParadaCalc.bfa_cd_adicional_motorista = a.bfa_cd_base_frete_adicional_motorista
								and (a.ppr_dia_util = adcParadaCalc.bfa_dia_util or adcParadaCalc.bfa_dia_util is null)
						group by
							bfa_cd_base_frete_adicional_motorista
							,a.ppr_cd_rota
					) as b
				on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_base_frete_adicional_motorista
				and a.ppr_cd_rota = b.ppr_cd_rota
		

		-- Calcula adicional de pontos por quantidade / faixa
		update
			a
		set
			a.ppr_vl_pacotes = isnull(b.ppr_vl_pacotes, 0)
		from
			#tb_pgto_periodo_rota_calc as a
			inner join (
						select
							a.bfa_cd_base_frete_adicional_motorista
							,a.ppr_cd_rota
							,sum(
								case
									when case when tipo_fx_1 = 1333 then ppr_qt_pacotes_entregues else ppr_qt_pacotes end >= bfa_fx_ini
										then (
												(case when case when tipo_fx_1 = 1333 then ppr_qt_pacotes_entregues else ppr_qt_pacotes end < bfa_fx_fim then case when tipo_fx_1 = 1333 then ppr_qt_pacotes_entregues else ppr_qt_pacotes end else bfa_fx_fim end)
												- case when bfa_fx_ini = 0 then bfa_fx_ini else bfa_fx_ini - 1 end
											) * bfa_fx_valor
									else 0
								end
							) as ppr_vl_pacotes
						from
							#tb_pgto_periodo_rota_calc as a
							inner join (
										select
											bfp_cd_adcional_parada
											,bfa_cd_adicional_motorista
											,bfa_fx_ini
											,bfa_fx_fim
											,bfa_fx_valor
											,bfa_tipo_valor
											,bfa_dia_util
											,tipo_fx_1
										from
											#tb_parametro_paradas_km
										where
											bfa_tipo_valor = 3  
											and tipo_fx_1 in (1333, 1345) --considera apenas pacotes
									) as adcPacotesCalc
								on adcPacotesCalc.bfa_cd_adicional_motorista = a.bfa_cd_base_frete_adicional_motorista
								and (a.ppr_dia_util = adcPacotesCalc.bfa_dia_util or adcPacotesCalc.bfa_dia_util is null)
						group by
							bfa_cd_base_frete_adicional_motorista
							,a.ppr_cd_rota
					) as b
				on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_base_frete_adicional_motorista
				and a.ppr_cd_rota = b.ppr_cd_rota


		-- Novo cálculo de frete: faixa fixa de ponto/parada e faixa km
		drop table if exists #vl_paradas
		select
			*
			,case
				when bfa_tipo_valor = 2 then
					case
						when ppr_ponto_parada >= bfa_fx_ini and ppr_ponto_parada <= bfa_fx_fim
							and ((ppr_total_km > bfa_fx_ini_2 -1) and ppr_total_km <= bfa_fx_fim_2 or bfa_fx_ini_2 is null)
							then bfa_fx_valor
						else 0
					end
				when bfa_tipo_valor = 1 then
					case
						when ppr_ponto_parada >= bfa_fx_ini and ppr_ponto_parada <= bfa_fx_fim
							and ((ppr_total_km > bfa_fx_ini_2 -1) and ppr_total_km <= bfa_fx_fim_2 or bfa_fx_ini_2 is null)
							then bfa_fx_valor * ppr_ponto_parada
						else 0
					end
			end as ppr_vl_ponto_parada_novo
		into #vl_paradas
		from
			#tb_pgto_periodo_rota_calc as a
			left join #tb_parametro_paradas_km as b
				on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_adicional_motorista
				and (a.ppr_dia_util = b.bfa_dia_util or b.bfa_dia_util is null)
		where
			ppr_vl_base > 0
			and b.bfa_tipo_valor in (1, 2)
			and isnull(b.tipo_fx_1,1331) in (1331,1332) --considera apenas parada ou ponto


		 --Calcula valor de pacote 
		drop table if exists #vl_pacotes
		select
			*
			,case
				when bfa_tipo_valor = 2 then
					case
						when case when tipo_fx_1 = 1333 then ppr_qt_pacotes_entregues else ppr_qt_pacotes end >= bfa_fx_ini and case when tipo_fx_1 = 1333 then ppr_qt_pacotes_entregues else ppr_qt_pacotes end <= bfa_fx_fim
							and (
								(tipo_fx_2 = 1331 and ppr_qt_paradas >= bfa_fx_ini_2 and ppr_qt_paradas <= bfa_fx_fim_2)
								or (isnull(tipo_fx_2,0) <> 1331 and ((ppr_total_km > bfa_fx_ini_2 -1) and ppr_total_km <= bfa_fx_fim_2))
								or bfa_fx_ini_2 is null
							)
							then bfa_fx_valor
						else 0
					end
				when bfa_tipo_valor = 1 then
					case
						when case when tipo_fx_1 = 1333 then ppr_qt_pacotes_entregues else ppr_qt_pacotes end >= bfa_fx_ini and case when tipo_fx_1 = 1333 then ppr_qt_pacotes_entregues else ppr_qt_pacotes end <= bfa_fx_fim
							and (
								(tipo_fx_2 = 1331 and ppr_qt_paradas >= bfa_fx_ini_2 and ppr_qt_paradas <= bfa_fx_fim_2)
								or (isnull(tipo_fx_2,0) <> 1331 and ((ppr_total_km > bfa_fx_ini_2 -1) and ppr_total_km <= bfa_fx_fim_2))
								or bfa_fx_ini_2 is null
							)
							then bfa_fx_valor * case when tipo_fx_1 = 1333 then ppr_qt_pacotes_entregues else ppr_qt_pacotes end
						else 0
					end
			end as ppr_vl_pacote_novo
			into #vl_pacotes
		from
			#tb_pgto_periodo_rota_calc as a
			left join #tb_parametro_paradas_km as b
				on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_adicional_motorista
				and (a.ppr_dia_util = b.bfa_dia_util or b.bfa_dia_util is null)
		where
			ppr_vl_base > 0
			and b.bfa_tipo_valor in (1, 2)
			and b.tipo_fx_1 in (1333,1345)


		-- Remove linhas que não entraram na regra
		delete
			#vl_paradas
		where
			ppr_vl_ponto_parada_novo = 0

		delete
			#vl_pacotes
		where
			ppr_vl_pacote_novo = 0

		-- Atualiza valor adicional (paradas / pontos conforme bfa_calcula_por_parada)
		update
			a
		set
			a.ppr_vl_paradas = case
									when a.bfa_calcula_por_parada = 1 then isnull(b.ppr_vl_ponto_parada_novo, 0) + isnull(a.ppr_vl_ponto_parada, 0)
									else 0
								end
			,a.ppr_vl_pontos = case
									when a.bfa_calcula_por_parada = 0 then isnull(b.ppr_vl_ponto_parada_novo, 0) + isnull(a.ppr_vl_ponto_parada, 0)
									else 0
								end
		from
			#tb_pgto_periodo_rota_calc as a
			left join #vl_paradas as b on a.ppr_cd_rota = b.ppr_cd_rota


		-- Atualiza valor pacote
		update
			a
		set
			a.ppr_vl_pacotes = isnull(a.ppr_vl_pacotes,0) + isnull(b.ppr_vl_pacote_novo, 0)
		from
			#tb_pgto_periodo_rota_calc as a
			left join #vl_pacotes as b on a.ppr_cd_rota = b.ppr_cd_rota


		-- Soma valor por faixa / valor adicional rota / valor adicional fixo / pacote
		update
			#tb_pgto_periodo_rota_calc
		set
			ppr_vl_paradas = isnull(ppr_vl_paradas, 0) + case when bfa_calcula_por_parada = 1 then ppr_vl_rota + isnull(bfa_vl_adicional, 0) else 0 end
			,ppr_vl_pontos = isnull(ppr_vl_pontos, 0) + case when bfa_calcula_por_parada = 0 then ppr_vl_rota + isnull(bfa_vl_adicional, 0) else 0 end
			,ppr_vl_pacotes = isnull(ppr_vl_pacotes,0)

		drop table if exists #tb_pgto_periodo_rota_calc_tratado
		select distinct
			*
		into #tb_pgto_periodo_rota_calc_tratado
		from
			#tb_pgto_periodo_rota_calc as a

		-- Zera adicional quando rota é ambulância (bases com regra aplicada)
		update
			a
		set
			ppr_vl_paradas = 0
			,ppr_vl_pontos = 0
		from
			#tb_pgto_periodo_rota_calc_tratado as a
		where
			ppr_in_ambulancia = 1
			and regra_ambulancia is not null

		-- Zera adicional para veículos de frota fixa (Decargo)
		update
			a
		set
			ppr_vl_paradas = 0
			,ppr_vl_pontos = 0
		from
			#tb_pgto_periodo_rota_calc_tratado as a
			inner join tb_veiculos as b
				on a.ppr_ds_placa = b.vei_ds_placa
				and b.vei_in_ativo = 1
				and b.vei_valor_fixo is not null
				and b.vei_cd_cliente in (68, 66)

		-- Zera adicional para rotas SAMEDAY
		update
			a
		set
			ppr_vl_paradas = 0
			,ppr_vl_pontos = 0
		from
			#tb_pgto_periodo_rota_calc_tratado as a
		where
			ppr_cd_desconto_sd = 1


		update 
			p
		set
			p.ppr_vl_paradas      = isnull(p2.ppr_vl_paradas, 0),
			p.ppr_vl_pontos       = isnull(p2.ppr_vl_pontos, 0),
			p.ppr_vl_pacotes      = ISNULL(p2.ppr_vl_pacotes, 0),  
			p.ppr_vl_risco        = p2.ppr_vl_risco,
			p.ppr_vl_adicional_km = p2.ppr_vl_adicional_km,
			p.ppr_vl_ajudante     = p2.ppr_vl_ajudante,
			p.ppr_vl_dom_fer      = p2.ppr_vl_dom,
			p.ppr_vl_fer          = p2.ppr_vl_fer,
			p.ppr_vl_recarga      = p2.ppr_vl_recarga,
			p.ppr_vl_bonus_ds     = p2.ppr_vl_bonus_ds,
			p.ppr_vl_pedagio      = p2.ppr_vl_pedagio,
			p.ppr_vl_base         = p.ppr_vl_base + ISNULL(p2.ppr_vl_pm, 0)
		FROM
			tb_pgto_periodo_rota p
			join #tb_pgto_periodo_rota_calc_tratado p2 ON p.ppr_cd_rota = p2.ppr_cd_rota
														and p.ppr_cd_periodo = p2.ppr_cd_periodo
														and p.ppr_cd_pagamento_rota = p2.ppr_cd_pagamento_rota



		--zera valores de quem não recebe adicional por critério da base frete
		update
			p
		set
			p.ppr_vl_paradas = 0
			,p.ppr_vl_pacotes = 0
			,p.ppr_vl_pontos = 0
			,p.ppr_vl_risco = 0
			,p.ppr_vl_adicional_km = 0
			,p.ppr_vl_ajudante = 0
			,p.ppr_vl_dom_fer = 0
			,p.ppr_vl_fer = 0
			,p.ppr_vl_recarga = 0
			,p.ppr_vl_bonus_ds = 0
			,p.ppr_vl_pedagio = 0
		from
			tb_pgto_periodo_rota p
			join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
										and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
										and e.mtn_cd_operacao = @Operacao
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento
			and p.ppr_cd_tipo_pgto = 1362
			and p.ppr_in_excluido = 0
			and e.mtn_cd_status in (34,228,38,1298)
			and p.ppr_in_calcular_adicional = 0
			

	end --fim do if que verifica se o período pode sofrer alterações

end --fim procedure
GO
