/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akt9utu
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-07
  Descricao    : Reverte o forward 037:
                 1) Restaura dbo.UspFinIntegracaoSSW para a versao vigente em
                    PROD em 07/10/2026 (OBJECT_DEFINITION capturado antes do
                    deploy): 'SMS1' -> 'MS1' e SEM mapeamento 'SMS3'.
                 2) Recoloca as 40 linhas SMS3 corrigidas no estado de erro
                    original (base NULL, status_irisys 1086, status_terceiro
                    1349, erro "Campo Unidade nao informado ou vazio",
                    tentativas originais por espelho).
                 OBS: somente linhas ainda pendentes (status_irisys = 1084 e
                 base 'MS3') sao revertidas — linhas ja reprocessadas pelo
                 fluxo SSW nao sao alteradas, pois nao e possivel desfazer um
                 envio de pagamento ja realizado. Linhas novas inseridas pela
                 versao MS3 nao sao tocadas (filtro pelos 40 espelhos do
                 snapshot).
  Forward ref  : scripts/forward/2026/10/037_forward_CU-86akt9utu_ssw_frota_fixa_ms3.sql
  Objetos      : dbo.UspFinIntegracaoSSW (CREATE OR ALTER),
                 dbo.tb_pag_integracao_bancos (UPDATE reverso)
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspFinIntegracaoSSW'))
        THROW 50001, 'Procedure dbo.UspFinIntegracaoSSW nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. SCRIPT DE ROLLBACK — 2.1 Restaura versao anterior da procedure
--============================================================================
CREATE OR ALTER PROCEDURE [dbo].[UspFinIntegracaoSSW]
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
            WHEN 'SDF1'  THEN 'DF1'

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

--============================================================================
-- 2.2 Reverte a correcao de dados nas 40 linhas SMS3 (snapshot 07/10/2026)
--     Somente linhas ainda pendentes (status 1084, base MS3) sao revertidas.
--============================================================================
BEGIN TRY
    UPDATE b
    SET b.pib_ds_base = NULL, b.pib_cd_status_irisys = 1086, b.pib_cd_status_terceiro = 1349,
        b.pib_ds_erro = 'Campo Unidade nao informado ou vazio',
        b.pib_nr_tentativas = CASE b.pib_cd_espelho WHEN 1589459 THEN 6 WHEN 1589479 THEN 5 WHEN 1596786 THEN 5 ELSE 4 END
    FROM dbo.tb_pag_integracao_bancos b
    WHERE b.pib_cd_status_irisys = 1084 AND b.pib_ds_base = 'MS3' AND b.pib_cd_espelho IN (
        1589443, 1589444, 1589445, 1589446, 1589447, 1589448, 1589449, 1589450,
        1589451, 1589452, 1589453, 1589454, 1589456, 1589457, 1589459, 1589460,
        1589461, 1589462, 1589463, 1589464, 1589465, 1589466, 1589467, 1589468,
        1589469, 1589470, 1589471, 1589472, 1589473, 1589474, 1589475, 1589476,
        1589477, 1589478, 1589479, 1589480, 1589481, 1595645, 1596786, 1599843);

    PRINT 'Linhas SMS3 revertidas ao estado de erro: ' + CAST(@@ROWCOUNT AS VARCHAR);
END TRY
BEGIN CATCH
    PRINT 'ERRO (reversao de dados): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 3. POS-CHECKS
--============================================================================
BEGIN TRY
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspFinIntegracaoSSW')) LIKE '%WHEN ''SMS3''%'
        THROW 50004, 'Mapeamento SMS3 ainda presente na procedure.', 1;
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspFinIntegracaoSSW')) NOT LIKE '%WHEN ''SMS1''  THEN ''MS1''%'
        THROW 50005, 'Mapeamento SMS1 -> MS1 nao restaurado na procedure.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pos-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
