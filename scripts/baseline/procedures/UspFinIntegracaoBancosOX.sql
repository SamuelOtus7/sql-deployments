-- ============================================================
-- BASELINE: dbo.UspFinIntegracaoBancosOX
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinIntegracaoBancosOX]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[UspFinIntegracaoBancosOX]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MsgErroCnpj VARCHAR(200) = N'Erro ao integrar: CNPJ do titular ausente ou inválido';
    DECLARE @MsgErroBanco VARCHAR(200) = N'Erro ao integrar: banco de pagamento não cadastrado para o motorista';
    DECLARE @MsgErroBancoDiferente VARCHAR(200) = N'Erro ao integrar: banco de pagamento diferente de OxPay';
    DECLARE @StatusIrisysErro INT = 1086;
    DECLARE @StatusTerceiroErro INT = 1349;
    DECLARE @StatusIrisysSucesso INT = 1084;
    DECLARE @TipoIntegracaoSucesso INT = 1083;
    DECLARE @TipoIntegracaoErro INT = 1083;
    DECLARE @NrTentativasErroValidacao INT = 4;

    MERGE INTO dbo.tb_pag_integracao_bancos WITH (HOLDLOCK) AS tgt
    USING (
        SELECT
            src_base.pib_cd_espelho,
            src_base.pib_cd_cliente,
            src_base.pib_dt_pagamento,
            src_base.pib_cd_tipo_transferencia,
            src_base.pib_cd_conta,
            src_base.pib_cd_digito_conta,
            src_base.pib_ds_tipo_conta,
            src_base.pib_cd_banco,
            src_base.pib_cd_agencia,
            src_base.pib_cd_digito_agencia,
            src_base.pib_nm_beneficiado,
            src_base.pib_cd_documento,
            src_base.pib_vl_pagamento,
            src_base.pib_ds_mensagem,
            CASE
                WHEN src_base.mot_cd_banco IS NULL THEN @StatusIrisysErro
                WHEN src_base.mot_cd_banco <> 1153 THEN @StatusIrisysErro
                WHEN src_base.pib_cd_documento = '' THEN @StatusIrisysErro
                ELSE @StatusIrisysSucesso
            END AS pib_cd_status_irisys,
            CASE
                WHEN src_base.mot_cd_banco IS NULL
                  OR src_base.mot_cd_banco <> 1153
                  OR src_base.pib_cd_documento = ''
                THEN @StatusTerceiroErro
                ELSE NULL
            END AS pib_cd_status_terceiro,
            CASE
                WHEN src_base.mot_cd_banco IS NULL
                  OR src_base.mot_cd_banco <> 1153
                  OR src_base.pib_cd_documento = ''
                THEN @TipoIntegracaoErro
                ELSE @TipoIntegracaoSucesso
            END AS pib_ds_tipo_integracao,
            CASE
                WHEN src_base.mot_cd_banco IS NULL THEN @MsgErroBanco
                WHEN src_base.mot_cd_banco <> 1153 THEN @MsgErroBancoDiferente
                WHEN src_base.pib_cd_documento = '' THEN @MsgErroCnpj
                ELSE NULL
            END AS pib_ds_erro,
            src_base.pib_ds_chave_integracao,
            src_base.pib_dh_inclusao,
            src_base.pib_dh_processamento,
            CASE
                WHEN src_base.mot_cd_banco IS NULL
                  OR src_base.mot_cd_banco <> 1153
                  OR src_base.pib_cd_documento = ''
                THEN @NrTentativasErroValidacao
                ELSE 0
            END AS pib_nr_tentativas,
            src_base.pib_ds_base,
            src_base.pib_nm_lote
        FROM (
            SELECT
                pag.mtn_cd_motorista_nfs AS pib_cd_espelho,
                pag.mtn_cod_cliente AS pib_cd_cliente,
                ISNULL(pag.mtn_dt_prevista_pagamento, DATEADD(DAY, 15, per.pgp_dt_fim)) AS pib_dt_pagamento,
                1087 AS pib_cd_tipo_transferencia,
                NULL AS pib_cd_conta,
                NULL AS pib_cd_digito_conta,
                NULL AS pib_ds_tipo_conta,
                'OX' AS pib_cd_banco,
                NULL AS pib_cd_agencia,
                NULL AS pib_cd_digito_agencia,
                pag.mtn_nome_motorista AS pib_nm_beneficiado,
                ISNULL(
                    CASE
                        WHEN mot.mot_pag_cnpj_titular IS NOT NULL
                         AND LTRIM(RTRIM(mot.mot_pag_cnpj_titular)) <> ''
                            THEN mot.mot_pag_cnpj_titular
                        WHEN ISNULL(par_cpf.prm_ds_valor, 'true') = 'true'
                         AND mot.mot_cpf IS NOT NULL
                         AND LTRIM(RTRIM(mot.mot_cpf)) <> ''
                            THEN mot.mot_cpf
                        ELSE NULL
                    END,
                    ''
                ) AS pib_cd_documento,
                pag.mtn_vl_nfs AS pib_vl_pagamento,
                pag.mtn_nome_motorista + '-' + pag.mtn_base_principal AS pib_ds_mensagem,
                NULL AS pib_ds_chave_integracao,
                GETDATE() AS pib_dh_inclusao,
                NULL AS pib_dh_processamento,
                0 AS pib_nr_tentativas,
                pag.mtn_base_principal AS pib_ds_base,
                per.pgp_nm_periodo AS pib_nm_lote,
                mot.mot_cd_banco
            FROM dbo.tb_pag_espelhos AS pag
            INNER JOIN dbo.tb_parametros AS par
                ON pag.mtn_cod_cliente = par.prm_cod_cliente
               AND par.prm_ds_chave = 'OXPay_CriarOrdem'
               AND par.prm_ds_valor = 'true'
            LEFT JOIN dbo.tb_parametros AS par_cpf
                ON pag.mtn_cod_cliente = par_cpf.prm_cod_cliente
               AND par_cpf.prm_ds_categoria = N'Integração OxPay'
               AND par_cpf.prm_ds_chave = 'OXPay_UtilizaCPF'
            INNER JOIN dbo.tb_pgto_periodo AS per
                ON pag.mtn_cd_pgto_periodo = per.pgp_cd_periodo
            INNER JOIN dbo.tb_motorista AS mot
                ON pag.mtn_cd_motorista = mot.mot_cd_usuario
            WHERE pag.mtn_cod_cliente IN (56, 37)
              AND pag.mtn_cd_status = 39
              AND ISNULL(pag.mtn_dt_prevista_pagamento, CAST(GETDATE() AS date)) <= CAST(GETDATE() AS date)
        ) AS src_base
    ) AS src
    ON tgt.pib_cd_espelho = src.pib_cd_espelho
   AND tgt.pib_cd_cliente = src.pib_cd_cliente
    WHEN MATCHED
         AND tgt.pib_ds_chave_integracao IS NULL
         AND (
                (
                    tgt.pib_cd_status_irisys = @StatusIrisysErro
                    AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                    AND tgt.pib_ds_erro IS NOT NULL
                    AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                    AND src.pib_cd_status_terceiro IS NULL
                    AND src.pib_ds_erro IS NULL
                )
                OR (
                    tgt.pib_cd_status_irisys = @StatusIrisysSucesso
                    AND tgt.pib_dt_pagamento <> src.pib_dt_pagamento
                )
             )
        THEN UPDATE SET
            tgt.pib_cd_status_irisys = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_cd_status_irisys
                ELSE tgt.pib_cd_status_irisys
            END,
            tgt.pib_cd_status_terceiro = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_cd_status_terceiro
                ELSE tgt.pib_cd_status_terceiro
            END,
            tgt.pib_ds_tipo_integracao = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_ds_tipo_integracao
                ELSE tgt.pib_ds_tipo_integracao
            END,
            tgt.pib_ds_erro = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN NULL
                ELSE tgt.pib_ds_erro
            END,
            tgt.pib_cd_documento = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_cd_documento
                ELSE tgt.pib_cd_documento
            END,
            tgt.pib_dt_pagamento = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_dt_pagamento
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND tgt.pib_dt_pagamento <> src.pib_dt_pagamento
                THEN src.pib_dt_pagamento
                ELSE tgt.pib_dt_pagamento
            END,
            tgt.pib_vl_pagamento = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_vl_pagamento
                ELSE tgt.pib_vl_pagamento
            END,
            tgt.pib_nm_beneficiado = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_nm_beneficiado
                ELSE tgt.pib_nm_beneficiado
            END,
            tgt.pib_ds_mensagem = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_ds_mensagem
                ELSE tgt.pib_ds_mensagem
            END,
            tgt.pib_ds_base = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_ds_base
                ELSE tgt.pib_ds_base
            END,
            tgt.pib_nm_lote = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN src.pib_nm_lote
                ELSE tgt.pib_nm_lote
            END,
            tgt.pib_nr_tentativas = CASE
                WHEN tgt.pib_cd_status_irisys = @StatusIrisysErro
                 AND tgt.pib_cd_status_terceiro = @StatusTerceiroErro
                 AND tgt.pib_ds_erro IS NOT NULL
                 AND src.pib_cd_status_irisys = @StatusIrisysSucesso
                 AND src.pib_cd_status_terceiro IS NULL
                 AND src.pib_ds_erro IS NULL
                THEN 0
                ELSE tgt.pib_nr_tentativas
            END
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (
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
            pib_ds_base,
            pib_nm_lote
        )
        VALUES (
            src.pib_cd_espelho,
            src.pib_cd_cliente,
            src.pib_dt_pagamento,
            src.pib_cd_tipo_transferencia,
            src.pib_cd_conta,
            src.pib_cd_digito_conta,
            src.pib_ds_tipo_conta,
            src.pib_cd_banco,
            src.pib_cd_agencia,
            src.pib_cd_digito_agencia,
            src.pib_nm_beneficiado,
            src.pib_cd_documento,
            src.pib_vl_pagamento,
            src.pib_ds_mensagem,
            src.pib_cd_status_irisys,
            src.pib_cd_status_terceiro,
            src.pib_ds_tipo_integracao,
            src.pib_ds_erro,
            src.pib_ds_chave_integracao,
            src.pib_dh_inclusao,
            src.pib_dh_processamento,
            src.pib_nr_tentativas,
            src.pib_ds_base,
            src.pib_nm_lote
        );
END;
GO
