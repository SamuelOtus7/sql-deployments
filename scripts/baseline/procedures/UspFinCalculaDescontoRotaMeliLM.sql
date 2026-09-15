-- ============================================================
-- BASELINE: dbo.UspFinCalculaDescontoRotaMeliLM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinCalculaDescontoRotaMeliLM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 23/03/2026
-- Description:	Calcula descontos das rotas
-- =============================================
CREATE PROCEDURE [dbo].[UspFinCalculaDescontoRotaMeliLM] (
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
		-- CALCULA DESCONTOS
		------------------------------------------------------------
		drop table if exists #tb_pgto_periodo_rota_descontos
		select
			p.ppr_cd_pagamento_rota
			,p.ppr_cd_periodo
			,p.ppr_cd_rota
			,p.ppr_cd_motorista_nfs
			,p.ppr_cd_faixa_km
			,p.ppr_ds_placa
			,p.ppr_ds_tipo_veiculo
			,p.ppr_ds_ciclo
			,p.ppr_qt_faixa
			,p.ppr_qt_paradas
			,p.ppr_qt_pontos
			,p.ppr_in_sab
			,p.ppr_in_dom
			,p.ppr_in_fer
			,p.ppr_vl_success_delivery
			,p.ppr_qt_enderecos_nao_visitados
			,p.ppr_vl_base
			,p.ppr_vl_paradas
			,p.ppr_in_ambulancia
			,p.ppr_qt_pacotes_entregues
			,p.ppr_cd_desconto_ds
			,p.ppr_base_principal
			,isnull(ppr_base_calculo,ppr_base_principal) ppr_base_calculo
			,p.ppr_data_referencia
			,p.ppr_nm_cidade
			into #tb_pgto_periodo_rota_descontos
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


		DROP TABLE IF EXISTS #tb_pgto_periodo_rota_calc_descontos;
	    
		WITH descontos AS (
        SELECT
            a.ppr_cd_periodo,
            a.ppr_cd_rota,

			--Acrencentar nessa consulta novos parametros de desconto
            COALESCE(adcplaca.bfa_perc_ds, adplaca.bfa_perc_ds,ad.bfa_perc_ds, adc.bfa_perc_ds) AS perc_ds,
			COALESCE(adcplaca.bfa_qtd_enderecos_nao_visitados,adplaca.bfa_qtd_enderecos_nao_visitados,ad.bfa_qtd_enderecos_nao_visitados,adc.bfa_qtd_enderecos_nao_visitados) nao_visitados_regra

        FROM 
			#tb_pgto_periodo_rota_descontos a
			join tb_pag_espelhos b ON b.mtn_cd_motorista_nfs = a.ppr_cd_motorista_nfs
			LEFT JOIN tb_dra_tipo_veiculo tv ON a.ppr_ds_tipo_veiculo = tv.tvl_nm_tipo_veiculo
			LEFT JOIN tb_fin_base_frete_adicional_motorista ad ON b.mtn_cod_cliente = ad.bfa_cd_transportadora
															   AND a.ppr_base_calculo = ad.bfa_cd_service_center
															   AND tv.tvl_cd_tipo_veiculo = ad.bfa_cd_tipo_veiculo
															   AND ad.bfa_nm_cidade IS NULL
															   and (
																	(@ParamUtilizaContrato = 1 and isnull(b.mtn_cd_tipo_contrato, -1) = isnull(ad.bfa_cd_tipo_contrato, -1))
																	or @ParamUtilizaContrato = 0
																)
															   AND a.ppr_data_referencia BETWEEN ad.bfa_data_inicio_vigencia AND ISNULL(ad.bfa_data_fim_vigencia, CONVERT(DATE, DATEADD(YEAR, 1, GETDATE())))
															   and ad.bfa_cd_operacao = @Operacao
															   and ad.bfa_cd_codigo_cliente = @IdCliTransportadora
															   and ad.bfa_ds_placa is null

			LEFT JOIN tb_fin_base_frete_adicional_motorista adc ON b.mtn_cod_cliente = adc.bfa_cd_transportadora
															   AND a.ppr_base_calculo = adc.bfa_cd_service_center
															   AND tv.tvl_cd_tipo_veiculo = adc.bfa_cd_tipo_veiculo
															   AND a.ppr_nm_cidade = adc.bfa_nm_cidade
															    and (
																	(@ParamUtilizaContrato = 1 and isnull(b.mtn_cd_tipo_contrato, -1) = isnull(ad.bfa_cd_tipo_contrato, -1))
																	or @ParamUtilizaContrato = 0
																)
															   AND a.ppr_data_referencia BETWEEN adc.bfa_data_inicio_vigencia AND ISNULL(adc.bfa_data_fim_vigencia, CONVERT(DATE, DATEADD(YEAR, 1, GETDATE())))
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
			a.ppr_cd_pagamento_rota,
			a.ppr_cd_periodo,
			a.ppr_cd_rota,
			a.ppr_cd_faixa_km,
			a.ppr_ds_placa,
			a.ppr_ds_tipo_veiculo,
			a.ppr_ds_ciclo,
			a.ppr_qt_faixa,
			a.ppr_qt_paradas,
			a.ppr_qt_pontos,
			a.ppr_in_sab,
			a.ppr_in_dom,
			a.ppr_in_fer,
			--a.ppr_in_dom_fer,
			a.ppr_vl_success_delivery,
			a.ppr_qt_enderecos_nao_visitados,
			a.ppr_vl_base,
			a.ppr_vl_paradas,
			a.ppr_in_ambulancia,
			a.ppr_qt_pacotes_entregues,

			ad.perc_ds,
			ad.nao_visitados_regra,

			a.ppr_cd_desconto_ds
			INTO #tb_pgto_periodo_rota_calc_descontos
		FROM	
			#tb_pgto_periodo_rota_descontos a
			join descontos ad ON a.ppr_cd_periodo = ad.ppr_cd_periodo AND a.ppr_cd_rota = ad.ppr_cd_rota;


		--Descontos--

		--Sera aplicada as regras de descontos
		--declare @CodPeriodoPagamento int = 1322
		
		--Desconto Delivery Success (performance)
		/*	DIAS DE SEMANA: SE <90% ZERA-SE O VALOR DO ESPELHO (VALOR BASE E ADICIONAIS)
			SÁBADO, DOMINGO E FERIADO: SE <90% ZERA-SE O VALOR DO ESPELHO (VALOR BASE E ADICIONAIS)
				, MAS SERÁ PAGO CASO TENHA VISITADO TODOS OS ENDEREÇOS --falta incluir
		*/
		
		--Atualiza o Valor Base
		update	
			pgto
		set		
			pgto.ppr_vl_base =	case	
									when pgto.ppr_in_sab = 1 or pgto.ppr_in_dom = 1 or pgto.ppr_in_fer = 1
										then	case 
												when pgto.ppr_vl_success_delivery < perc_ds and pgto.ppr_qt_enderecos_nao_visitados = nao_visitados_regra
													then pgto.ppr_vl_base 
												when pgto.ppr_vl_success_delivery < perc_ds and pgto.ppr_qt_enderecos_nao_visitados > nao_visitados_regra
													then 0
												else pgto.ppr_vl_base
												end
									else	case 
											when pgto.ppr_vl_success_delivery < perc_ds 
												then 0 
											else pgto.ppr_vl_base 
											end
									end ,
		--Campo para identificar o Desconto da Rota pelo DS
		pgto.ppr_cd_desconto_ds =	case	
									when pgto.ppr_in_sab = 1 or pgto.ppr_in_dom = 1 or pgto.ppr_in_fer = 1
										then	case 
												when pgto.ppr_vl_success_delivery < perc_ds and pgto.ppr_qt_enderecos_nao_visitados = nao_visitados_regra
													then 0
												when pgto.ppr_vl_success_delivery < perc_ds and pgto.ppr_qt_enderecos_nao_visitados > nao_visitados_regra
													then 1
												else 0
												end
									else	case 
											when pgto.ppr_vl_success_delivery < perc_ds 
												then 1
											else 0
											end
									end
		from	
			#tb_pgto_periodo_rota_calc_descontos as pgto with(nolock)
		--Tratar dados de service center nao cadastrados (não aplicar descontos)
		where	
			perc_ds is not null
			and nao_visitados_regra is not null

		

		--Regra somente de DS (Sem considerar a regar de Endereços não visitados)
		update	
			pgto
		set		
			pgto.ppr_vl_base =	case	
									when pgto.ppr_vl_success_delivery < perc_ds 
										then 0
										else pgto.ppr_vl_base
									end
									 ,
		
		--Campo para identificar o Desconto da Rota pelo DS
		pgto.ppr_cd_desconto_ds =	case	
									when pgto.ppr_vl_success_delivery < perc_ds 
										then 1
										else 0
									end

		from	
			#tb_pgto_periodo_rota_calc_descontos as pgto with(nolock)	
		--Tratar dados de service center nao cadastrados (não aplicar descontos)
		where	
			perc_ds is not null
			and nao_visitados_regra is null	
					   			 		  



		--Atualiza o Valor Adicional de Paradas/Ponto
		update	
			pgto
		set		
			pgto.ppr_vl_paradas =	case	
										when pgto.ppr_in_sab = 1 or pgto.ppr_in_dom = 1 or pgto.ppr_in_fer = 1 
											then	case 
													when pgto.ppr_vl_success_delivery < perc_ds and pgto.ppr_qt_enderecos_nao_visitados = nao_visitados_regra
														then pgto.ppr_vl_paradas 
													when pgto.ppr_vl_success_delivery < perc_ds and pgto.ppr_qt_enderecos_nao_visitados > nao_visitados_regra
														then 0
													else pgto.ppr_vl_paradas
													end
										else	case 
												when pgto.ppr_vl_success_delivery < perc_ds 
													then 0 
												else pgto.ppr_vl_paradas 
												end
										end

		from	
			#tb_pgto_periodo_rota_calc_descontos as pgto 

		--Tratar dados de service center nao cadastrados (não aplicar descontos)
		where	
			perc_ds is not null
			and nao_visitados_regra is not null	


		--Atualiza o Valor Adicional de Paradas/Ponto - Regra somente de DS (Sem considerar a regar de Endereços não visitados)
		update	
			pgto
		set		
			pgto.ppr_vl_paradas =	case	
										when pgto.ppr_vl_success_delivery < perc_ds 
											then 0
											else pgto.ppr_vl_paradas
										end

		from	
			#tb_pgto_periodo_rota_calc_descontos as pgto 
		--Tratar dados de service center nao cadastrados (não aplicar descontos)
		where	
			perc_ds is not null
			and nao_visitados_regra is null




		DROP TABLE IF EXISTS #tb_pgto_periodo_rota_calc_descontos_tratado;
		select  
			distinct *
			into #tb_pgto_periodo_rota_calc_descontos_tratado
		from    
			#tb_pgto_periodo_rota_calc_descontos as a

	
		MERGE INTO tb_pgto_periodo_rota AS target
		USING #tb_pgto_periodo_rota_calc_descontos_tratado AS source
			ON target.ppr_cd_pagamento_rota = source.ppr_cd_pagamento_rota
		WHEN MATCHED THEN
        UPDATE SET
            target.ppr_vl_paradas         = ISNULL(source.ppr_vl_paradas, 0),
            target.ppr_cd_desconto_ds     = ISNULL(source.ppr_cd_desconto_ds, 0),
            target.ppr_vl_base            = source.ppr_vl_base;


			

	end

end

GO
