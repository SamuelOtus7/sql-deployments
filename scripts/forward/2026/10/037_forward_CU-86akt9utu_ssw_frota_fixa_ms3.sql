/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akt9utu
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-07
  Descricao    : Vincula o tipo de contrato Frota Fixa Campo Grande
                 (tb_tipo_contrato.ttc_cd_tipo_contrato = 498, cliente 61)
                 a unidade MS3 no SSW (dbo.UspFinIntegracaoSSW):
                 1) CASE pib_ds_base passa a discriminar por TIPO DE CONTRATO:
                    espelhos com mtn_cd_tipo_contrato = 498 recebem 'MS3'
                    independente da base. Adiciona WHEN 'SMS3' THEN 'MS3' por
                    redundancia e MANTEM 'SMS1' -> 'MS1' — diverge do arquivo
                    SSW_RODOPRIME.sql original (que remapeava SMS1 -> MS3):
                    evidencia em PROD mostra que espelhos SMS1 sao a operacao
                    regular de Campo Grande (mtn_cd_tipo_contrato NULL, 138
                    espelhos integrados como MS1), enquanto SMS3 e exclusivo
                    do contrato 498 (82 espelhos). Remapear SMS1 enviaria a
                    operacao regular para a unidade errada.
                 2) Correcao de dados: devolve a fila de envio (status 1084,
                    erro/tentativas zerados) as linhas SMS3 gravadas com
                    base NULL. A proc nao reinsere espelhos ja integrados
                    (anti-join + UX_tb_pag_integracao_bancos_cd_espelho), por
                    isso o UPDATE corretivo e necessario.
                 OBS: o 'USE db_Irisys' do arquivo original foi removido para
                 permitir execucao em QAS (db_IrisysDev).
  Rollback     : scripts/rollback/2026/10/037_rollback_CU-86akt9utu_ssw_frota_fixa_ms3.sql
  Objetos      : dbo.UspFinIntegracaoSSW (CREATE OR ALTER),
                 dbo.tb_pag_integracao_bancos (UPDATE corretivo)
  Dependencias : job "DriveAnalytics - Insert SSW Rodoprime" (agenda a proc);
                 consumidor SSW usa pib_ds_base como campo Unidade
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspFinIntegracaoSSW'))
        THROW 50001, 'Procedure dbo.UspFinIntegracaoSSW nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_pag_integracao_bancos'))
        THROW 50002, 'Tabela dbo.tb_pag_integracao_bancos nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_pag_espelhos'))
        THROW 50003, 'Tabela dbo.tb_pag_espelhos nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. SCRIPT PRINCIPAL — 2.1 Procedure
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
        CASE
            -- CU-86akt9utu: Frota Fixa Campo Grande = tipo de contrato 498
            -- (tb_tipo_contrato, cliente 61). Discriminado por contrato e nao
            -- por base, pois SMS1 e a operacao regular de CG (sem contrato).
            WHEN pag.mtn_cd_tipo_contrato = 498 THEN 'MS3'
            ELSE CASE pag.mtn_base_principal
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
            WHEN 'SMS3'  THEN 'MS3'
            WHEN 'SDF2'  THEN 'DF2'
            WHEN 'SDF1'  THEN 'DF1'

            END
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
-- 2.2 Correcao de dados — linhas SMS3 gravadas com base NULL em erro
--============================================================================
BEGIN TRY
    UPDATE b
    SET b.pib_ds_base = 'MS3', b.pib_cd_status_irisys = 1084, b.pib_cd_status_terceiro = NULL,
        b.pib_ds_erro = NULL, b.pib_nr_tentativas = 0, b.pib_dh_processamento = NULL
    FROM dbo.tb_pag_integracao_bancos b
    INNER JOIN dbo.tb_pag_espelhos pag ON b.pib_cd_espelho = pag.mtn_cd_motorista_nfs
    WHERE pag.mtn_base_principal = 'SMS3' AND b.pib_ds_base IS NULL AND b.pib_cd_status_irisys = 1086
      AND b.pib_ds_erro = 'Campo Unidade nao informado ou vazio';

    PRINT 'Linhas SMS3 recolocadas na fila de envio: ' + CAST(@@ROWCOUNT AS VARCHAR);
END TRY
BEGIN CATCH
    PRINT 'ERRO (correcao de dados): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 3. POS-CHECKS
--============================================================================
BEGIN TRY
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspFinIntegracaoSSW')) NOT LIKE '%WHEN ''SMS3''%'
        THROW 50004, 'Mapeamento SMS3 nao encontrado na procedure.', 1;
    IF EXISTS (
        SELECT 1
        FROM dbo.tb_pag_integracao_bancos b
        INNER JOIN dbo.tb_pag_espelhos pag
            ON b.pib_cd_espelho = pag.mtn_cd_motorista_nfs
        WHERE pag.mtn_base_principal = 'SMS3'
          AND b.pib_ds_base IS NULL)
        THROW 50005, 'Ainda existem linhas SMS3 com pib_ds_base NULL.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pos-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
