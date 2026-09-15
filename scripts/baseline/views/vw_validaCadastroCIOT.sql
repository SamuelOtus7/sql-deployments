-- ============================================================
-- BASELINE: dbo.vw_validaCadastroCIOT
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validaCadastroCIOT]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[vw_validaCadastroCIOT] as
SELECT 
	mot_cd_motorista as IdMotorista,
    mot_nm_motorista AS NomeMotorista,
    CASE 
        WHEN mot_ds_vehicle_rntrc IS NULL OR mot_ds_vehicle_rntrc = '' THEN 'RNTRC não preenchido. ' ELSE '' END +
        CASE WHEN mot_cpf IS NULL OR mot_cpf = '' THEN 'CPF não preenchido. ' ELSE '' END +
        CASE WHEN mot_cnt_vl_telefone IS NULL OR mot_cnt_vl_telefone = '' THEN 'Número de telefone fixo não preenchido. ' ELSE '' END +
        CASE WHEN mot_cnt_vl_celular IS NULL OR mot_cnt_vl_celular = '' THEN 'Número de celular não preenchido. ' ELSE '' END +
        CASE WHEN mot_cnt_vl_email IS NULL OR mot_cnt_vl_email = '' THEN 'Email não preenchido. ' ELSE '' END +
        CASE WHEN mot_end_nm_bairro IS NULL OR mot_end_nm_bairro = '' THEN 'Bairro não preenchido. ' ELSE '' END +
        CASE WHEN mot_end_ds_rua IS NULL OR mot_end_ds_rua = '' THEN 'Endereço rua não preenchido. ' ELSE '' END +
        CASE WHEN mot_end_vl_numero IS NULL THEN 'Endereço número não preenchido. ' ELSE '' END +
        CASE WHEN mot_end_vl_cep IS NULL OR mot_end_vl_cep = '' THEN 'CEP não preenchido. ' ELSE '' END +
        CASE WHEN mot_end_vl_cd_ibge IS NULL OR mot_end_vl_cd_ibge = '' THEN 'Código IBGE do município não preenchido. ' ELSE '' END +
        CASE WHEN mot_ds_plate IS NULL OR mot_ds_plate = '' THEN 'Placa não preenchida. ' ELSE '' END +
        CASE WHEN mot_cd_numero_cartao IS NULL OR mot_cd_numero_cartao = '' THEN 'Número do cartão não preenchido. ' ELSE '' END +
        CASE WHEN mot_gr_vl_rg_motorista IS NULL OR mot_gr_vl_rg_motorista = '' THEN 'RG não preenchido. ' ELSE '' END +
        CASE WHEN mot_ds_orgao_emissor_rg IS NULL OR mot_ds_orgao_emissor_rg = '' THEN 'Orgao Emissor não preenchido. ' ELSE '' END +
        CASE WHEN mot_dt_nascimento IS NULL THEN 'Data de nascimento não preenchida. ' ELSE '' END +
        CASE WHEN mot_gr_nm_mae IS NULL OR mot_gr_nm_mae = '' THEN 'Nome da mãe não preenchido. ' ELSE '' END +
        CASE WHEN mot_gr_nm_pai IS NULL OR mot_gr_nm_pai = '' THEN 'Nome do pai não preenchido. ' ELSE '' END +
        CASE WHEN mot_ds_nacionalidade IS NULL OR mot_ds_nacionalidade = '' THEN 'Nacionalidade não preenchida. ' ELSE '' END +
		CASE WHEN vei_ds_tipo_rodado IS NULL OR vei_ds_tipo_rodado = '' THEN 'Tipo Rodado não preenchido. ' ELSE '' END + 
		CASE WHEN vei_ds_tipo_carroceria IS NULL OR vei_ds_tipo_carroceria = '' THEN 'Tipo Carroceria não preenchido. ' ELSE '' END 		AS Mensagem
		
FROM 
    [dbo].[tb_motorista] a WITH (NOLOCK)
	  join tb_veiculos b with(nolock)
	on a.mot_ds_plate = b.vei_ds_placa
WHERE 
    mot_cd_status = 1 and mot_cd_cliente = 47
	and mot_pag_cd_tipo_pagamento = 2

    
	AND (
        mot_ds_vehicle_rntrc IS NULL OR mot_ds_vehicle_rntrc = '' OR
        mot_cpf IS NULL OR mot_cpf = '' OR
        mot_cnt_vl_telefone IS NULL OR mot_cnt_vl_telefone = '' OR
        mot_cnt_emg_vl_telefone IS NULL OR mot_cnt_emg_vl_telefone = '' OR
        mot_cnt_vl_email IS NULL OR mot_cnt_vl_email = '' OR
        mot_end_nm_bairro IS NULL OR mot_end_nm_bairro = '' OR
        mot_end_ds_rua IS NULL OR mot_end_ds_rua = '' OR
        mot_end_vl_numero IS NULL OR
        mot_end_vl_cep IS NULL OR mot_end_vl_cep = '' OR
        mot_end_vl_cd_ibge IS NULL OR mot_end_vl_cd_ibge = '' OR
        mot_ds_plate IS NULL OR mot_ds_plate = '' OR
        mot_cd_numero_cartao IS NULL OR mot_cd_numero_cartao = '' OR
        mot_gr_vl_rg_motorista IS NULL OR mot_gr_vl_rg_motorista = '' OR
        mot_ds_orgao_emissor_rg IS NULL OR mot_ds_orgao_emissor_rg = '' OR
        mot_dt_nascimento IS NULL OR
        mot_gr_nm_mae IS NULL OR mot_gr_nm_mae = '' OR
        mot_gr_nm_pai IS NULL OR mot_gr_nm_pai = '' OR
        mot_ds_nacionalidade IS NULL OR mot_ds_nacionalidade = '' OR
		vei_ds_tipo_rodado IS NULL OR vei_ds_tipo_rodado ='' OR
		vei_ds_tipo_carroceria IS NULL OR vei_ds_tipo_carroceria = ''
    );
GO
