-- ============================================================
-- BASELINE: dbo.UspFlexRota_validacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFlexRota_validacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create  PROCEDURE [dbo].[UspFlexRota_validacao](@CodPeriodoPagamento INT, @data_inicial DATE, @data_final DATE)

AS

BEGIN

DECLARE @CodPeriodoPagamentoRegra INT,
		@DataInicialRegra DATE,
		@DataFinalRegra DATE,
		@CodigoCliente INT

SET @DataInicialRegra = CONVERT(DATE,CONVERT(VARCHAR(6),@data_inicial,112) + '01')
SET @DataFinalRegra = CONVERT(DATE,DATEADD(DAY,-1,CONVERT(VARCHAR(6),DATEADD(MONTH,1,@data_final),112) + '01'))
SET @CodigoCliente = (SELECT pgp_cd_cliente FROM tb_pgto_periodo (NOLOCK) WHERE pgp_cd_periodo = @CodPeriodoPagamento)
SET @CodPeriodoPagamentoRegra = (SELECT	MAX(pgp_cd_periodo) FROM tb_pgto_periodo (NOLOCK) WHERE pgp_cd_cliente = @CodigoCliente AND pgp_dt_inicio BETWEEN @DataInicialRegra AND @DataFinalRegra)


/****************************************************** Desconto Flex Frota ******************************************************/

IF(@CodigoCliente = 47 AND @data_inicial >= '2025-03-16')
BEGIN

	DELETE FROM tb_pgto_periodo_rota_validacao
	WHERE ppr_data_referencia BETWEEN @DataInicialRegra AND @DataFinalRegra
		AND ISNULL(ppr_lcto_observacao,'') = 'Desconto Flex Frota'

	INSERT INTO tb_pgto_periodo_rota_validacao(
		ppr_cd_periodo,
		ppr_cd_rota,
		ppr_cd_faixa_km,
		ppr_ds_placa,
		ppr_ds_tipo_veiculo,
		ppr_ds_ciclo,
		ppr_qt_pacotes,
		ppr_qt_pontos,
		ppr_qt_paradas,
		ppr_in_area_risco,
		ppr_in_ajudante,
		ppr_in_dom_fer,
		ppr_vl_base,
		ppr_vl_paradas,
		ppr_vl_risco,
		ppr_vl_ajudante,
		ppr_vl_dom_fer,
		ppr_vl_lancamentos,
		ppr_vl_total_km_real,
		ppr_vl_total_km_minimo,
		ppr_vl_total_km_prefatura,
		ppr_vl_total,
		ppr_cd_usr_criacao,
		ppr_dh_modificacao,
		ppr_cd_usr_modificacao,
		ppr_in_ativo,
		ppr_in_excluido,
		ppr_cd_motorista,
		ppr_vl_insucessos,
		ppr_vl_success_delivery,
		ppr_qt_pacotes_entregues,
		ppr_qt_pacotes_pendentes,
		ppr_bfm_vl_FaixaKM,
		ppr_bfm_vl_adicional_domingo,
		ppr_bfm_vl_adicional_ciclo_pm,
		ppr_bfm_vl_paradas0_60,
		ppr_bfm_vl_paradas61_75,
		ppr_bfm_vl_paradas76_85,
		ppr_bfm_vl_paradas86_90,
		ppr_bfm_vl_paradas_acima_90,
		ppr_bfm_vl_adicional_ajudante,
		ppr_bfm_vl_adicional_risco,
		ppr_bfm_vl_insucesso,
		ppr_lcto_dt_lancamento,
		ppr_lcto_ciclo,
		ppr_lcto_tipo,
		ppr_lcto_vl_risco_ajudante,
		ppr_lcto_qt_pacotes,
		ppr_lcto_qt_pontos,
		ppr_lcto_observacao,
		ppr_lcto_usr_criacao,
		ppr_lcto_dh_modificacao,
		ppr_lcto_usr_modificacao,
		ppr_lcto_vl_apoio,
		ppr_id_transportadora,
		ppr_cd_motorista_nfs,
		ppr_usou_app,
		ppr_data_referencia,
		ppr_base_principal,
		ppr_tipo_rota,
		ppr_nome_motorista,
		ppr_cd_pgto_espelho,
		ppr_vl_bonus,
		ppr_vl_pm,
		ppr_vl_valor_frete,
		ppr_total_km,
		ppr_nm_cidade,
		ppr_vl_pedagio,
		ppr_lcto_cd_lancamento,
		ppr_vl_aluguel,
		ppr_vl_desconto,
		ppr_vl_recarga,
		ppr_vl_pontos,
		ppr_vl_pacotes,
		ppr_per_endereco_visitado,
		ppr_cd_tipo,
		ppr_nm_cluster,
		ppr_total_km_meli,
		ppr_total_km_rtt,
		ppr_vl_desconto_flex_rota,
		ppr_vl_desconto_cartao_flex_rota
	)

	SELECT	ppr_cd_periodo,
			ppr_cd_rota,
			ppr_cd_faixa_km,
			ppr_ds_placa,
			ppr_ds_tipo_veiculo,
			ppr_ds_ciclo,
			ppr_qt_pacotes,
			ppr_qt_pontos,
			ppr_qt_paradas,
			ppr_in_area_risco,
			ppr_in_ajudante,
			ppr_in_dom_fer,
			ppr_vl_base,
			ppr_vl_paradas,
			ppr_vl_risco,
			ppr_vl_ajudante,
			ppr_vl_dom_fer,
			ppr_vl_lancamentos,
			ppr_vl_total_km_real,
			ppr_vl_total_km_minimo,
			ppr_vl_total_km_prefatura,
			ppr_vl_total,
			ppr_cd_usr_criacao,
			ppr_dh_modificacao,
			ppr_cd_usr_modificacao,
			ppr_in_ativo,
			ppr_in_excluido,
			ppr_cd_motorista,
			ppr_vl_insucessos,
			ppr_vl_success_delivery,
			ppr_qt_pacotes_entregues,
			ppr_qt_pacotes_pendentes,
			ppr_bfm_vl_FaixaKM,
			ppr_bfm_vl_adicional_domingo,
			ppr_bfm_vl_adicional_ciclo_pm,
			ppr_bfm_vl_paradas0_60,
			ppr_bfm_vl_paradas61_75,
			ppr_bfm_vl_paradas76_85,
			ppr_bfm_vl_paradas86_90,
			ppr_bfm_vl_paradas_acima_90,
			ppr_bfm_vl_adicional_ajudante,
			ppr_bfm_vl_adicional_risco,
			ppr_bfm_vl_insucesso,
			ppr_lcto_dt_lancamento,
			ppr_lcto_ciclo,
			ppr_lcto_tipo,
			ppr_lcto_vl_risco_ajudante,
			ppr_lcto_qt_pacotes,
			ppr_lcto_qt_pontos,
			ppr_lcto_observacao,
			ppr_lcto_usr_criacao,
			ppr_lcto_dh_modificacao,
			ppr_lcto_usr_modificacao,
			ppr_lcto_vl_apoio,
			ppr_id_transportadora,
			ppr_cd_motorista_nfs,
			ppr_usou_app,
			ppr_data_referencia,
			ppr_base_principal,
			ppr_tipo_rota,
			ppr_nome_motorista,
			ppr_cd_pgto_espelho,
			ppr_vl_bonus,
			ppr_vl_pm,
			ppr_vl_valor_frete,
			ppr_total_km,
			ppr_nm_cidade,
			ppr_vl_pedagio,
			ppr_lcto_cd_lancamento,
			ppr_vl_aluguel,
			ppr_vl_desconto,
			ppr_vl_recarga,
			ppr_vl_pontos,
			ppr_vl_pacotes,
			ppr_per_endereco_visitado,
			ppr_cd_tipo,
			ppr_nm_cluster,
			ppr_total_km_meli,
			ppr_total_km_rtt,
			ppr_vl_desconto_flex_rota,
			ppr_vl_desconto_cartao_flex_rota
	FROM (
			SELECT	@CodPeriodoPagamentoRegra AS ppr_cd_periodo,
					NULL AS ppr_cd_rota,
					NULL AS ppr_cd_faixa_km,
					ppr_ds_placa,
					VEI.vei_ds_tipo AS ppr_ds_tipo_veiculo,
					NULL AS ppr_ds_ciclo,
					NULL AS ppr_qt_pacotes,
					NULL AS ppr_qt_pontos,
					NULL AS ppr_qt_paradas,
					NULL AS ppr_in_area_risco,
					NULL AS ppr_in_ajudante,
					NULL AS ppr_in_dom_fer,
					NULL AS ppr_vl_base,
					NULL AS ppr_vl_paradas,
					NULL AS ppr_vl_risco,
					NULL AS ppr_vl_ajudante,
					NULL AS ppr_vl_dom_fer,
					NULL AS ppr_vl_lancamentos,
					NULL AS ppr_vl_total_km_real,
					NULL AS ppr_vl_total_km_minimo,
					NULL AS ppr_vl_total_km_prefatura,
					bfa_vl_valor_desconto_flex_frota * -1 AS ppr_vl_total,
					8851 AS ppr_cd_usr_criacao,
					GETDATE() AS ppr_dh_modificacao,
					8851 AS ppr_cd_usr_modificacao,
					1 AS ppr_in_ativo,
					0 AS ppr_in_excluido,
					ppr_cd_motorista,
					NULL AS ppr_vl_insucessos,
					NULL AS ppr_vl_success_delivery,
					NULL AS ppr_qt_pacotes_entregues,
					NULL AS ppr_qt_pacotes_pendentes,
					NULL AS ppr_bfm_vl_FaixaKM,
					NULL AS ppr_bfm_vl_adicional_domingo,
					NULL AS ppr_bfm_vl_adicional_ciclo_pm,
					NULL AS ppr_bfm_vl_paradas0_60,
					NULL AS ppr_bfm_vl_paradas61_75,
					NULL AS ppr_bfm_vl_paradas76_85,
					NULL AS ppr_bfm_vl_paradas86_90,
					NULL AS ppr_bfm_vl_paradas_acima_90,
					NULL AS ppr_bfm_vl_adicional_ajudante,
					NULL AS ppr_bfm_vl_adicional_risco,
					NULL AS ppr_bfm_vl_insucesso,
					NULL AS ppr_lcto_dt_lancamento,
					NULL AS ppr_lcto_ciclo,
					NULL AS ppr_lcto_tipo,
					NULL AS ppr_lcto_vl_risco_ajudante,
					NULL AS ppr_lcto_qt_pacotes,
					NULL AS ppr_lcto_qt_pontos,
					'Desconto Flex Frota' AS ppr_lcto_observacao,
					NULL AS ppr_lcto_usr_criacao,
					NULL AS ppr_lcto_dh_modificacao,
					NULL AS ppr_lcto_usr_modificacao,
					NULL AS ppr_lcto_vl_apoio,
					NULL AS ppr_id_transportadora,
					ppr_cd_motorista_nfs,
					NULL AS ppr_usou_app,
					NULL AS ppr_data_referencia,
					NULL AS ppr_base_principal,
					NULL AS ppr_tipo_rota,
					ppr_nome_motorista,
					ppr_cd_pgto_espelho,
					NULL AS ppr_vl_bonus,
					NULL AS ppr_vl_pm,
					NULL AS ppr_vl_valor_frete,
					NULL AS ppr_total_km,
					NULL AS ppr_nm_cidade,
					NULL AS ppr_vl_pedagio,
					NULL AS ppr_lcto_cd_lancamento,
					NULL AS ppr_vl_aluguel,
					NULL AS ppr_vl_desconto,
					NULL AS ppr_vl_recarga,
					NULL AS ppr_vl_pontos,
					NULL AS ppr_vl_pacotes,
					NULL AS ppr_per_endereco_visitado,
					'LM' AS ppr_cd_tipo,
					NULL AS ppr_nm_cluster,
					NULL AS ppr_total_km_meli,
					NULL AS ppr_total_km_rtt,
					bfa_vl_valor_desconto_flex_frota * -1 AS ppr_vl_desconto_flex_rota,
					NULL AS ppr_vl_desconto_cartao_flex_rota,
					ROW_NUMBER() OVER(PARTITION BY ppr_nome_motorista ORDER BY ppr_cd_pgto_espelho DESC) AS ID
			FROM tb_pgto_periodo_rota_validacao						 AS PPR (NOLOCK)
			INNER JOIN tb_veiculos							 AS VEI (NOLOCK) ON VEI.vei_ds_placa		  = PPR.ppr_ds_placa
			INNER JOIN tb_pgto_periodo						 AS PGT (NOLOCK) ON PGT.pgp_cd_periodo		  = PPR.ppr_cd_periodo
			INNER JOIN tb_dra_tipo_veiculo					 AS TVE (NOLOCK) ON TVE.tvl_nm_tipo_veiculo	  = VEI.vei_ds_tipo
			INNER JOIN tb_fin_base_frete_adicional_motorista AS FAM (NOLOCK) ON FAM.bfa_cd_transportadora = PGT.pgp_cd_cliente
																			AND FAM.bfa_cd_service_center = PPR.ppr_base_principal
																			AND FAM.bfa_cd_tipo_veiculo	  = TVE.tvl_cd_tipo_veiculo
																			AND FAM.bfa_vl_valor_desconto_flex_frota IS NOT NULL
			WHERE ppr_in_excluido = 0
				AND ppr_data_referencia BETWEEN @DataInicialRegra AND @DataFinalRegra
				AND PGT.pgp_cd_cliente = @CodigoCliente
				AND ppr_cd_rota IS NOT NULL
				AND ISNULL(VEI.vei_ds_tipo,'') IN ('Frota Fixa Large Master','MeliOne Van Frota Fixa','MeliOne VUC','MeliOne Yellow Pool',
												   'Rental Utilitário com Ajudante','Rental Utilitário sem Ajudante','Utilitários','Utilitários SDD',
												   'Van','Van Frota Fixa - Equipe dupla','Van Frota Fixa - Equipe única','Veículo de Passeio',
												   'VUC Dedicado com Ajudante','Vuc Rental TKS','Vuc SDD','Yellow Pool Large Van – Equipe dupla')
				AND EXISTS (
								SELECT 1
								FROM tb_integracao_flex_eventos
								WHERE iev_cd_codigo_cliente = @CodigoCliente
									AND CONVERT(DATE,iev_dh_data_hora_evento) BETWEEN @DataInicialRegra AND @DataFinalRegra
									AND iev_cd_codigo_cliente = PGT.pgp_cd_cliente
									AND iev_ds_nome_motorista = PPR.ppr_nome_motorista
							)
			GROUP BY ppr_ds_placa,
					 VEI.vei_ds_tipo,
					 bfa_vl_valor_desconto_flex_frota * -1,
					 ppr_cd_motorista,
					 ppr_cd_motorista_nfs,
					 ppr_nome_motorista,
					 ppr_cd_pgto_espelho,
					 bfa_vl_valor_desconto_flex_frota * -1
		) AS TAB
	WHERE ID = 1


	/****************************************************** Desconto Cartão Flex Frota ******************************************************/

	DELETE FROM tb_pgto_periodo_rota_validacao
	WHERE ppr_cd_periodo = @CodPeriodoPagamento
		AND ISNULL(ppr_lcto_observacao,'') = 'Desconto Cartão Flex Frota'

	INSERT INTO tb_pgto_periodo_rota_validacao(
		ppr_cd_periodo,
		ppr_cd_rota,
		ppr_cd_faixa_km,
		ppr_ds_placa,
		ppr_ds_tipo_veiculo,
		ppr_ds_ciclo,
		ppr_qt_pacotes,
		ppr_qt_pontos,
		ppr_qt_paradas,
		ppr_in_area_risco,
		ppr_in_ajudante,
		ppr_in_dom_fer,
		ppr_vl_base,
		ppr_vl_paradas,
		ppr_vl_risco,
		ppr_vl_ajudante,
		ppr_vl_dom_fer,
		ppr_vl_lancamentos,
		ppr_vl_total_km_real,
		ppr_vl_total_km_minimo,
		ppr_vl_total_km_prefatura,
		ppr_vl_total,
		ppr_cd_usr_criacao,
		ppr_dh_modificacao,
		ppr_cd_usr_modificacao,
		ppr_in_ativo,
		ppr_in_excluido,
		ppr_cd_motorista,
		ppr_vl_insucessos,
		ppr_vl_success_delivery,
		ppr_qt_pacotes_entregues,
		ppr_qt_pacotes_pendentes,
		ppr_bfm_vl_FaixaKM,
		ppr_bfm_vl_adicional_domingo,
		ppr_bfm_vl_adicional_ciclo_pm,
		ppr_bfm_vl_paradas0_60,
		ppr_bfm_vl_paradas61_75,
		ppr_bfm_vl_paradas76_85,
		ppr_bfm_vl_paradas86_90,
		ppr_bfm_vl_paradas_acima_90,
		ppr_bfm_vl_adicional_ajudante,
		ppr_bfm_vl_adicional_risco,
		ppr_bfm_vl_insucesso,
		ppr_lcto_dt_lancamento,
		ppr_lcto_ciclo,
		ppr_lcto_tipo,
		ppr_lcto_vl_risco_ajudante,
		ppr_lcto_qt_pacotes,
		ppr_lcto_qt_pontos,
		ppr_lcto_observacao,
		ppr_lcto_usr_criacao,
		ppr_lcto_dh_modificacao,
		ppr_lcto_usr_modificacao,
		ppr_lcto_vl_apoio,
		ppr_id_transportadora,
		ppr_cd_motorista_nfs,
		ppr_usou_app,
		ppr_data_referencia,
		ppr_base_principal,
		ppr_tipo_rota,
		ppr_nome_motorista,
		ppr_cd_pgto_espelho,
		ppr_vl_bonus,
		ppr_vl_pm,
		ppr_vl_valor_frete,
		ppr_total_km,
		ppr_nm_cidade,
		ppr_vl_pedagio,
		ppr_lcto_cd_lancamento,
		ppr_vl_aluguel,
		ppr_vl_desconto,
		ppr_vl_recarga,
		ppr_vl_pontos,
		ppr_vl_pacotes,
		ppr_per_endereco_visitado,
		ppr_cd_tipo,
		ppr_nm_cluster,
		ppr_total_km_meli,
		ppr_total_km_rtt,
		ppr_vl_desconto_flex_rota,
		ppr_vl_desconto_cartao_flex_rota
	)

	SELECT	PPR.ppr_cd_periodo,
			NULL AS ppr_cd_rota,
			NULL AS ppr_cd_faixa_km,
			PPR.ppr_ds_placa,
			VEI.vei_ds_tipo AS ppr_ds_tipo_veiculo,
			NULL AS ppr_ds_ciclo,
			NULL AS ppr_qt_pacotes,
			NULL AS ppr_qt_pontos,
			NULL AS ppr_qt_paradas,
			NULL AS ppr_in_area_risco,
			NULL AS ppr_in_ajudante,
			NULL AS ppr_in_dom_fer,
			NULL AS ppr_vl_base,
			NULL AS ppr_vl_paradas,
			NULL AS ppr_vl_risco,
			NULL AS ppr_vl_ajudante,
			NULL AS ppr_vl_dom_fer,
			NULL AS ppr_vl_lancamentos,
			NULL AS ppr_vl_total_km_real,
			NULL AS ppr_vl_total_km_minimo,
			NULL AS ppr_vl_total_km_prefatura,
			FAM.bfa_vl_valor_desconto_cartao_flex_frota * -1 AS ppr_vl_total,
			8851 AS ppr_cd_usr_criacao,
			GETDATE() AS ppr_dh_modificacao,
			8851 AS ppr_cd_usr_modificacao,
			1 AS ppr_in_ativo,
			0 AS ppr_in_excluido,
			PPR.ppr_cd_motorista,
			NULL AS ppr_vl_insucessos,
			NULL AS ppr_vl_success_delivery,
			NULL AS ppr_qt_pacotes_entregues,
			NULL AS ppr_qt_pacotes_pendentes,
			NULL AS ppr_bfm_vl_FaixaKM,
			NULL AS ppr_bfm_vl_adicional_domingo,
			NULL AS ppr_bfm_vl_adicional_ciclo_pm,
			NULL AS ppr_bfm_vl_paradas0_60,
			NULL AS ppr_bfm_vl_paradas61_75,
			NULL AS ppr_bfm_vl_paradas76_85,
			NULL AS ppr_bfm_vl_paradas86_90,
			NULL AS ppr_bfm_vl_paradas_acima_90,
			NULL AS ppr_bfm_vl_adicional_ajudante,
			NULL AS ppr_bfm_vl_adicional_risco,
			NULL AS ppr_bfm_vl_insucesso,
			NULL AS ppr_lcto_dt_lancamento,
			NULL AS ppr_lcto_ciclo,
			NULL AS ppr_lcto_tipo,
			NULL AS ppr_lcto_vl_risco_ajudante,
			NULL AS ppr_lcto_qt_pacotes,
			NULL AS ppr_lcto_qt_pontos,
			'Desconto Cartão Flex Frota' AS ppr_lcto_observacao,
			NULL AS ppr_lcto_usr_criacao,
			NULL AS ppr_lcto_dh_modificacao,
			NULL AS ppr_lcto_usr_modificacao,
			NULL AS ppr_lcto_vl_apoio,
			NULL AS ppr_id_transportadora,
			PPR.ppr_cd_motorista_nfs,
			NULL AS ppr_usou_app,
			NULL AS ppr_data_referencia,
			NULL AS ppr_base_principal,
			NULL AS ppr_tipo_rota,
			PPR.ppr_nome_motorista,
			PPR.ppr_cd_pgto_espelho,
			NULL AS ppr_vl_bonus,
			NULL AS ppr_vl_pm,
			NULL AS ppr_vl_valor_frete,
			NULL AS ppr_total_km,
			NULL AS ppr_nm_cidade,
			NULL AS ppr_vl_pedagio,
			NULL AS ppr_lcto_cd_lancamento,
			NULL AS ppr_vl_aluguel,
			NULL AS ppr_vl_desconto,
			NULL AS ppr_vl_recarga,
			NULL AS ppr_vl_pontos,
			NULL AS ppr_vl_pacotes,
			NULL AS ppr_per_endereco_visitado,
			'LM' AS ppr_cd_tipo,
			NULL AS ppr_nm_cluster,
			NULL AS ppr_total_km_meli,
			NULL AS ppr_total_km_rtt,
			NULL AS ppr_vl_desconto_flex_rota,
			FAM.bfa_vl_valor_desconto_cartao_flex_frota * -1 AS ppr_vl_desconto_cartao_flex_rota
	FROM tb_pgto_periodo_rota_validacao						 AS PPR (NOLOCK)
	INNER JOIN tb_veiculos							 AS VEI (NOLOCK) ON VEI.vei_ds_placa		  = PPR.ppr_ds_placa
	INNER JOIN tb_pgto_periodo						 AS PGT (NOLOCK) ON PGT.pgp_cd_periodo		  = PPR.ppr_cd_periodo
	INNER JOIN tb_dra_tipo_veiculo					 AS TVE (NOLOCK) ON TVE.tvl_nm_tipo_veiculo	  = VEI.vei_ds_tipo
	INNER JOIN tb_fin_base_frete_adicional_motorista AS FAM (NOLOCK) ON FAM.bfa_cd_transportadora = PGT.pgp_cd_cliente
																	AND FAM.bfa_cd_service_center = PPR.ppr_base_principal
																	AND FAM.bfa_cd_tipo_veiculo	  = TVE.tvl_cd_tipo_veiculo
																	AND FAM.bfa_vl_valor_desconto_cartao_flex_frota IS NOT NULL
	WHERE ppr_in_excluido = 0
		AND ppr_cd_periodo = @CodPeriodoPagamento
		AND PGT.pgp_cd_cliente = @CodigoCliente
		AND ppr_cd_rota IS NOT NULL
		AND ISNULL(VEI.vei_ds_tipo,'') IN ('Frota Fixa Large Master','MeliOne Van Frota Fixa','MeliOne VUC','MeliOne Yellow Pool',
										   'Rental Utilitário com Ajudante','Rental Utilitário sem Ajudante','Utilitários','Utilitários SDD',
										   'Van','Van Frota Fixa - Equipe dupla','Van Frota Fixa - Equipe única','Veículo de Passeio',
										   'VUC Dedicado com Ajudante','Vuc Rental TKS','Vuc SDD','Yellow Pool Large Van – Equipe dupla')
		AND EXISTS (
						SELECT 1
						FROM tb_integracao_flex_eventos
						WHERE iev_cd_codigo_cliente = @CodigoCliente
							AND CONVERT(DATE,iev_dh_data_hora_evento) BETWEEN @DataInicialRegra AND @DataFinalRegra
							AND iev_cd_codigo_cliente = PGT.pgp_cd_cliente
							AND iev_ds_nome_motorista = PPR.ppr_nome_motorista
					)
	GROUP BY PPR.ppr_cd_periodo,
			 PPR.ppr_ds_placa,
			 VEI.vei_ds_tipo,
			 FAM.bfa_vl_valor_desconto_cartao_flex_frota * -1,
			 PPR.ppr_cd_motorista,
			 PPR.ppr_cd_motorista_nfs,
			 PPR.ppr_nome_motorista,
			 PPR.ppr_cd_pgto_espelho,
			 FAM.bfa_vl_valor_desconto_cartao_flex_frota * -1

END

ELSE
BEGIN
	RETURN
END

END
GO
