-- ============================================================
-- BASELINE: dbo.UspFinGeraTestesFinanceiro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraTestesFinanceiro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspFinGeraTestesFinanceiro]  (
	@CodPeriodoPagamento int,
	@FaseTeste varchar(100)
)
as
begin

	declare @Servidor varchar(100) = (SELECT @@SERVERNAME)
	declare @Banco varchar(100) = (SELECT DB_NAME())

	/*
	drop table if exists tb_pgto_periodo_rota_teste_calculo
	drop table if exists tb_pag_espelhos_teste_calculo
	select cast(null as varchar(100)) ppr_fase_teste, * into tb_pgto_periodo_rota_teste_calculo from tb_pgto_periodo_rota where 1=0
	select cast(null as varchar(100)) mtn_fase_teste, * into tb_pag_espelhos_teste_calculo from tb_pag_espelhos where 1=0
	*/

	--apaga testes
	delete tb_pgto_periodo_rota_teste_calculo where ppr_cd_periodo = @CodPeriodoPagamento and ppr_fase_teste = @FaseTeste
	delete tb_pag_espelhos_teste_calculo where mtn_cd_pgto_periodo = @CodPeriodoPagamento and mtn_fase_teste = @FaseTeste

	--apaga espelhos
	--só realiza o delete caso esteja em ambiente de homologação e base de teste
	if isnull(@Servidor,'') <> 'OTUS7-3' and isnull(@Banco,'') <> 'db_Irisys'
	begin
		delete tb_pgto_periodo_rota where ppr_cd_periodo = @CodPeriodoPagamento
		delete tb_pag_espelhos where mtn_cd_pgto_periodo = @CodPeriodoPagamento
	end

	
	--executa 2 vezes por precaução (caso tenha algum processo que possa dar erro na 2 vezes que execute)
	exec [dbo].[UspDetalhePagamento] @CodPeriodoPagamento
	exec [dbo].[UspDetalhePagamento] @CodPeriodoPagamento


	--insere resultado do teste
	insert into tb_pgto_periodo_rota_teste_calculo (ppr_fase_teste, ppr_cd_periodo, ppr_cd_rota, ppr_cd_faixa_km, ppr_ds_placa, ppr_ds_tipo_veiculo, ppr_ds_ciclo, ppr_qt_pacotes, ppr_qt_pontos, ppr_qt_paradas, ppr_in_area_risco, ppr_in_ajudante, ppr_in_dom_fer, ppr_vl_base, ppr_vl_paradas, ppr_vl_risco, ppr_vl_ajudante, ppr_vl_dom_fer, ppr_vl_lancamentos, ppr_vl_total_km_real, ppr_vl_total_km_minimo, ppr_vl_total_km_prefatura, ppr_vl_total, ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido, ppr_cd_motorista, ppr_vl_insucessos, ppr_vl_success_delivery, ppr_qt_pacotes_entregues, ppr_qt_pacotes_pendentes, ppr_bfm_vl_FaixaKM, ppr_bfm_vl_adicional_domingo, ppr_bfm_vl_adicional_ciclo_pm, ppr_bfm_vl_paradas0_60, ppr_bfm_vl_paradas61_75, ppr_bfm_vl_paradas76_85, ppr_bfm_vl_paradas86_90, ppr_bfm_vl_paradas_acima_90, ppr_bfm_vl_adicional_ajudante, ppr_bfm_vl_adicional_risco, ppr_bfm_vl_insucesso, ppr_lcto_dt_lancamento, ppr_lcto_ciclo, ppr_lcto_tipo, ppr_lcto_vl_risco_ajudante, ppr_lcto_qt_pacotes, ppr_lcto_qt_pontos, ppr_lcto_observacao, ppr_lcto_usr_criacao, ppr_lcto_dh_modificacao, ppr_lcto_usr_modificacao, ppr_lcto_vl_apoio, ppr_id_transportadora, ppr_cd_motorista_nfs, ppr_usou_app, ppr_data_referencia, ppr_base_principal, ppr_tipo_rota, ppr_nome_motorista, ppr_cd_pgto_espelho, ppr_vl_bonus, ppr_vl_pm, ppr_vl_valor_frete, ppr_total_km, ppr_nm_cidade, ppr_vl_pedagio, ppr_lcto_cd_lancamento, ppr_vl_aluguel, ppr_vl_desconto, ppr_vl_recarga, ppr_vl_pontos, ppr_vl_pacotes, ppr_per_endereco_nao_visitado, ppr_cd_tipo, ppr_nm_cluster, ppr_total_km_meli, ppr_total_km_rtt, ppr_vl_desconto_flex_rota, ppr_vl_desconto_cartao_flex_rota, ppr_in_zerar_vl, ppr_fl_desconto, ppr_vl_bonus_ds, ppr_vl_adicional_km, ppr_vl_fer, ppr_vl_dom, ppr_in_dom, ppr_in_fer, ppr_cd_lc_cartao_flex, ValidFrom, ValidTo, ppr_nm_pgto, ppr_qt_faixa, ppr_qtd_enderecos_visitados, ppr_in_ambulancia, ppr_in_sab, ppr_qt_enderecos_nao_visitados, ppr_vl_faixa, ppr_vl_bonus_campanha, ppr_vl_bonus_sla, ppr_vl_adicional_pct_min, ppr_in_avulso, ppr_cd_desconto_ds, ppr_vl_parada_iss, ppr_vl_parada_Comercial, ppr_vl_parada_RDM, ppr_vl_parada_Gestao, ppr_vl_iss, ppr_vl_Comercial, ppr_vl_RDM, ppr_vl_Gestao, ppr_vl_pnr, ppr_vl_pct_perdido, ppr_vl_endr_nvisitado, ppr_vl_lan_ambulancia, ppr_vl_lan_backup, ppr_vl_lan_abastecimento, ppr_cd_tipo_pgto, ppr_cd_desconto_sd, ppr_vl_end_nvisitado, ppr_vl_sem_rota, ppr_vl_periodo_anterior, ppr_vl_lancamentos_rotas, ppr_cd_usr_modificacao_zerar)
	select 
		@FaseTeste ppr_fase_teste, ppr_cd_periodo, ppr_cd_rota, ppr_cd_faixa_km, ppr_ds_placa, ppr_ds_tipo_veiculo, ppr_ds_ciclo, ppr_qt_pacotes, ppr_qt_pontos, ppr_qt_paradas, ppr_in_area_risco, ppr_in_ajudante, ppr_in_dom_fer, ppr_vl_base, ppr_vl_paradas, ppr_vl_risco, ppr_vl_ajudante, ppr_vl_dom_fer, ppr_vl_lancamentos, ppr_vl_total_km_real, ppr_vl_total_km_minimo, ppr_vl_total_km_prefatura, ppr_vl_total, ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido, ppr_cd_motorista, ppr_vl_insucessos, ppr_vl_success_delivery, ppr_qt_pacotes_entregues, ppr_qt_pacotes_pendentes, ppr_bfm_vl_FaixaKM, ppr_bfm_vl_adicional_domingo, ppr_bfm_vl_adicional_ciclo_pm, ppr_bfm_vl_paradas0_60, ppr_bfm_vl_paradas61_75, ppr_bfm_vl_paradas76_85, ppr_bfm_vl_paradas86_90, ppr_bfm_vl_paradas_acima_90, ppr_bfm_vl_adicional_ajudante, ppr_bfm_vl_adicional_risco, ppr_bfm_vl_insucesso, ppr_lcto_dt_lancamento, ppr_lcto_ciclo, ppr_lcto_tipo, ppr_lcto_vl_risco_ajudante, ppr_lcto_qt_pacotes, ppr_lcto_qt_pontos, ppr_lcto_observacao, ppr_lcto_usr_criacao, ppr_lcto_dh_modificacao, ppr_lcto_usr_modificacao, ppr_lcto_vl_apoio, ppr_id_transportadora, ppr_cd_motorista_nfs, ppr_usou_app, ppr_data_referencia, ppr_base_principal, ppr_tipo_rota, ppr_nome_motorista, ppr_cd_pgto_espelho, ppr_vl_bonus, ppr_vl_pm, ppr_vl_valor_frete, ppr_total_km, ppr_nm_cidade, ppr_vl_pedagio, ppr_lcto_cd_lancamento, ppr_vl_aluguel, ppr_vl_desconto, ppr_vl_recarga, ppr_vl_pontos, ppr_vl_pacotes, ppr_per_endereco_nao_visitado, ppr_cd_tipo, ppr_nm_cluster, ppr_total_km_meli, ppr_total_km_rtt, ppr_vl_desconto_flex_rota, ppr_vl_desconto_cartao_flex_rota, ppr_in_zerar_vl, ppr_fl_desconto, ppr_vl_bonus_ds, ppr_vl_adicional_km, ppr_vl_fer, ppr_vl_dom, ppr_in_dom, ppr_in_fer, ppr_cd_lc_cartao_flex, ValidFrom, ValidTo, ppr_nm_pgto, ppr_qt_faixa, ppr_qtd_enderecos_visitados, ppr_in_ambulancia, ppr_in_sab, ppr_qt_enderecos_nao_visitados, ppr_vl_faixa, ppr_vl_bonus_campanha, ppr_vl_bonus_sla, ppr_vl_adicional_pct_min, ppr_in_avulso, ppr_cd_desconto_ds, ppr_vl_parada_iss, ppr_vl_parada_Comercial, ppr_vl_parada_RDM, ppr_vl_parada_Gestao, ppr_vl_iss, ppr_vl_Comercial, ppr_vl_RDM, ppr_vl_Gestao, ppr_vl_pnr, ppr_vl_pct_perdido, ppr_vl_endr_nvisitado, ppr_vl_lan_ambulancia, ppr_vl_lan_backup, ppr_vl_lan_abastecimento, ppr_cd_tipo_pgto, ppr_cd_desconto_sd, ppr_vl_end_nvisitado, ppr_vl_sem_rota, ppr_vl_periodo_anterior, ppr_vl_lancamentos_rotas, ppr_cd_usr_modificacao_zerar
	from 
		tb_pgto_periodo_rota 
	where 
		ppr_cd_periodo = @CodPeriodoPagamento


	insert into tb_pag_espelhos_teste_calculo (mtn_fase_teste, mtn_cd_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_in_gerar_pdf, mtn_ds_linkespelho, mtn_base_principal, mtn_nome_motorista, mtn_cd_status_pdf_massa, mtn_dt_data_criacao_pdf_massa, mtn_dh_envio_nfs, mtn_dh_envio_push_notification, mtn_vl_imposto, mtn_vl_liquido, mtn_ds_link_nfs_secundario, mtn_dh_envio_nfs_secundario, mtn_in_zerar_espelho, mtn_vl_desconto, mtn_cd_operacao, ValidFrom, ValidTo, mtn_ds_Banco, mtn_ds_NomeTitular, mtn_ds_CpfTitular, mtn_ds_CnpjTitular, mtn_ds_Agencia, mtn_ds_Conta, mtn_ds_TipoConta, mtn_ds_TipoChavePix, mtn_ds_ChavePix, mtn_ds_CnpjEmpresa, mtn_ds_RazaoSocial, mtn_ds_NomeFantasia, mtn_cd_tipo_contrato, mtn_cd_status_validacao_automatica_nfse, mtn_dh_envio_nfs_terceiro, mtn_ds_link_nfs_terceiro, mtn_dh_envio_nfs_quarto, mtn_ds_link_nfs_quarto, mtn_cd_usr_espelho_pdf, mtn_in_processamento_em_massa)
	select 
		@FaseTeste mtn_fase_teste, mtn_cd_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_in_gerar_pdf, mtn_ds_linkespelho, mtn_base_principal, mtn_nome_motorista, mtn_cd_status_pdf_massa, mtn_dt_data_criacao_pdf_massa, mtn_dh_envio_nfs, mtn_dh_envio_push_notification, mtn_vl_imposto, mtn_vl_liquido, mtn_ds_link_nfs_secundario, mtn_dh_envio_nfs_secundario, mtn_in_zerar_espelho, mtn_vl_desconto, mtn_cd_operacao, ValidFrom, ValidTo, mtn_ds_Banco, mtn_ds_NomeTitular, mtn_ds_CpfTitular, mtn_ds_CnpjTitular, mtn_ds_Agencia, mtn_ds_Conta, mtn_ds_TipoConta, mtn_ds_TipoChavePix, mtn_ds_ChavePix, mtn_ds_CnpjEmpresa, mtn_ds_RazaoSocial, mtn_ds_NomeFantasia, mtn_cd_tipo_contrato, mtn_cd_status_validacao_automatica_nfse, mtn_dh_envio_nfs_terceiro, mtn_ds_link_nfs_terceiro, mtn_dh_envio_nfs_quarto, mtn_ds_link_nfs_quarto, mtn_cd_usr_espelho_pdf, mtn_in_processamento_em_massa
	from 
		tb_pag_espelhos
	where 
		mtn_cd_pgto_periodo = @CodPeriodoPagamento


end

GO
