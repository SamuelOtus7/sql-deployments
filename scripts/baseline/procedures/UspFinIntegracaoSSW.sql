-- ============================================================
-- BASELINE: dbo.UspFinIntegracaoSSW
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinIntegracaoSSW]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspFinIntegracaoSSW]
(
    @IdEspelho INT
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.tb_pag_integracao_bancos (
        pib_cd_espelho,
        pib_cd_cliente,
        pib_dt_pagamento,
        pib_cd_tipo_transferencia,
        pib_cd_conta,
        pib_cd_digito_conta,
        pib_ds_tipo_conta,
        pib_cd_banco,
        pib_cd_agencia,
        pib_cd_digito_agencia,
        pib_nm_beneficiado,
        pib_cd_documento,
        pib_vl_pagamento,
        pib_ds_mensagem,
        pib_cd_status_irisys,
        pib_cd_status_terceiro,
        pib_ds_tipo_integracao,
        pib_ds_erro,
        pib_ds_chave_integracao,
        pib_dh_inclusao,
        pib_dh_processamento,
        pib_nr_tentativas,
        pib_ui_id,
        pib_ds_base
    )
    SELECT
        pag.mtn_cd_motorista_nfs AS CodigoEspelho,
        pag.mtn_cod_cliente AS CodigoCliente,
        per.pgp_dt_inicio AS DataPgamento,          -- competência = início do período
        1088 AS TipoTransferencia,
        NULL AS CdConta,
        NULL AS DigitoConta,
        NULL AS TipoConta,
        NULL AS CdBanco,
        NULL AS Agencia,
        NULL AS DigitoAgencia,
        mot.mot_nm_motorista AS Nome,
        ISNULL(mot_resp.mot_cpf, mot.mot_cpf) AS CPF,
        pag.mtn_vl_nfs AS Valor,
        'Integração Irisys - Pagamento período ' + per.pgp_nm_periodo + ' - Unidade ' + ISNULL(pag.mtn_base_principal, '') AS Mensagem,
        1084 AS StatusIrisys,
        NULL AS StatusTerceiro,
        1347 AS TipoIntegracao,
        NULL AS Erro,
        NULL AS ChaveIntegracao,
        GETDATE() AS Inclusao,                      -- timestamp real de inclusão
        NULL AS Processamento,
        0 AS Tentativas,
        NEWID() AS uid,
        CASE pag.mtn_base_principal
            WHEN 'EBA4'  THEN 'SAJ'
            WHEN 'EBA12' THEN 'ALG'
            WHEN 'EBA14' THEN 'SER'
            WHEN 'EBA25' THEN 'ILH'
            WHEN 'EBA2'  THEN 'RDP'
            WHEN 'SBA1'  THEN 'BA1'
            WHEN 'EBA19' THEN 'ITA'
            WHEN 'EBA11' THEN 'PAF'
            WHEN 'EBA21' THEN 'SEA'
            WHEN 'EBA16' THEN 'SNB'
            WHEN 'EBA3'  THEN 'JAC'
            WHEN 'SBA6'  THEN 'BA6'
            WHEN 'eba6'  THEN 'JUA'
            WHEN 'SBA2'  THEN 'BA2'
            WHEN 'EBA29' THEN 'VAL'
            WHEN 'EBA22' THEN 'ALM'
            WHEN 'SSE1'  THEN 'SE1'
            WHEN 'SPA1'  THEN 'PA1'
            WHEN 'ESE1'  THEN 'GLS'
            WHEN 'SBA3'  THEN 'BA3'
            WHEN 'SMG9'  THEN 'MG9'
            WHEN 'SMG7'  THEN 'MG7'
            WHEN 'SRD1'  THEN 'RD1'
            WHEN 'STO1'  THEN 'TO1'
            WHEN 'SMR2'  THEN 'MR2'
            WHEN 'SMG8'  THEN 'MG8'
            WHEN 'SBA4'  THEN 'BA2'
            WHEN 'EPA8'  THEN 'PA8'
            WHEN 'SMG8'  THEN 'MG8'
            WHEN 'SMS1'  THEN 'MS1'
            WHEN 'SDF2'  THEN 'DF2'

        END AS base
    FROM dbo.tb_pag_espelhos AS pag
    INNER JOIN dbo.tb_pgto_periodo AS per
        ON pag.mtn_cd_pgto_periodo = per.pgp_cd_periodo
    INNER JOIN dbo.tb_motorista AS mot
        ON pag.mtn_cd_motorista = mot.mot_cd_usuario
    INNER JOIN dbo.tb_usuario AS users
        ON mot.mot_cd_usuario = users.usr_cd_usuario
    LEFT JOIN dbo.tb_motorista AS mot_resp
        ON mot_resp.mot_cd_usuario = users.usr_cd_usr_responsavel_contrato
    LEFT JOIN dbo.tb_pag_integracao_bancos AS bancos
        ON pag.mtn_cd_motorista_nfs = bancos.pib_cd_espelho
    WHERE (pag.mtn_cd_motorista_nfs = @IdEspelho OR @IdEspelho IS NULL)
      AND pag.mtn_cod_cliente = 61
      AND pag.mtn_cd_status = 37
      AND pag.mtn_dh_envio_nfs >= '2026-01-01'
      AND bancos.pib_cd_espelho IS NULL;
END;
GO
