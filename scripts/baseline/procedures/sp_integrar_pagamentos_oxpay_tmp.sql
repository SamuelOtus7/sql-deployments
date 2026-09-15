-- ============================================================
-- BASELINE: dbo.sp_integrar_pagamentos_oxpay_tmp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_integrar_pagamentos_oxpay_tmp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE

 PROCEDURE [dbo].[sp_integrar_pagamentos_oxpay_tmp] (@CodCliente INT, @Periodo VARCHAR(50)) AS BEGIN

SET NOCOUNT ON;
SET XACT_ABORT ON; 

BEGIN TRANSACTION; 

        /* =========================================
           1. Inserção na tabela de integração
           ========================================= */

    INSERT INTO tb_pag_integracao_bancos_tmp (pib_cd_espelho , pib_cd_cliente , pib_dt_pagamento , pib_cd_tipo_transferencia , pib_cd_conta , pib_cd_digito_conta , pib_ds_tipo_conta , pib_cd_banco , pib_cd_agencia , pib_cd_digito_agencia , pib_nm_beneficiado , pib_cd_documento , pib_vl_pagamento , pib_ds_mensagem , pib_cd_status_irisys , pib_cd_status_terceiro , pib_ds_tipo_integracao , pib_ds_erro , pib_ds_chave_integracao , pib_dh_inclusao , pib_dh_processamento , pib_nr_tentativas)
    SELECT   pag.mtn_cd_motorista_nfs AS CodigoEspelho,
             pag.mtn_cod_cliente AS CodigoCliente,
             dateadd(DAY, 15, per.pgp_dt_fim) AS Pgamento,
             1087 AS TipoTransferencia, --VALIDAR TIPO OXPAY,
             NULL AS CdConta,
             NULL AS DigitoConta,
             NULL AS TipoConta,
             'OX' AS CdBanco,
             NULL AS Agencia,
             NULL AS DigitoAgencia,
             mot.mot_nm_motorista AS Nome,
             CASE
                 WHEN mot_cd_banco = 1153 THEN mot_pag_cnpj_titular
                 ELSE mot.mot_cpf
             END AS CPF,
             pag.mtn_vl_nfs AS Valor,
             'Pagamento espelho - ' + per.pgp_nm_periodo AS Mensagem,
             1084 AS StatusIrisys,
             NULL AS StatusTerceiro,
             1083 AS TipoIntegracao, --VALOR FIXO PARA OXPay,
             NULL AS Erro,
             NULL AS ChaveIntegracao,
             getdate() AS Inclusao,
             NULL AS Processamento,
             0 AS Tentativas
    FROM      tb_pag_espelhos AS pag
              JOIN tb_parametros AS par ON pag.mtn_cod_cliente = par.prm_cod_cliente
              AND par.prm_ds_chave = 'OXPay_CriarOrdem'
              AND prm_ds_valor = 'true'
              JOIN tb_pgto_periodo AS per ON pag.mtn_cd_pgto_periodo = per.pgp_cd_periodo
              JOIN tb_motorista AS mot ON pag.mtn_cd_motorista = mot.mot_cd_usuario
              JOIN [vw_espelhos_nfse] AS nfs ON nfs.CodigoEspelho = pag.mtn_cd_motorista_nfs
    WHERE     mtn_cod_cliente = 61
              AND StatusEspelho = 'Documento aprovado' -- se for diferente prescisa vir na tabela de log
              AND mot_pag_cnpj_titular IS NOT NULL -- se for diferente prescisa vir na tabela de log
              AND pgp_nm_periodo = '2Q DEZEMBRO 2025 LM'
              AND mtn_base_principal = 'ESE1' 

  
    /* =========================================
       2. Insert no Log
       ========================================= */
    INSERT INTO tb_pag_integracao_log
    (
        log_dt,
        log_cd_espelho,
        log_mensagem 
    )
    SELECT
        GETDATE(),
        pag.mtn_cd_motorista_nfs ,
        StatusEspelho  
    FROM    tb_pag_espelhos AS pag
            JOIN tb_parametros AS par ON pag.mtn_cod_cliente = par.prm_cod_cliente
            AND par.prm_ds_chave = 'OXPay_CriarOrdem'
            AND prm_ds_valor = 'true'
            JOIN tb_pgto_periodo AS per ON pag.mtn_cd_pgto_periodo = per.pgp_cd_periodo
            JOIN tb_motorista AS mot ON pag.mtn_cd_motorista = mot.mot_cd_usuario
            JOIN [vw_espelhos_nfse] AS nfs ON nfs.CodigoEspelho = pag.mtn_cd_motorista_nfs
            LEFT JOIN tb_pag_integracao_bancos AS intoxy ON pib_cd_espelho = mtn_cd_motorista_nfs
    WHERE   StatusEspelho  <> 'Documento aprovado'
            AND intoxy.pib_cd_espelho   is null


    /* =========================================
       3. Update no Log
       ========================================= */

    UPDATE log
    SET
        log.log_dt       = GETDATE(),
        log.log_mensagem = nfs.StatusEspelho
    FROM tb_pag_integracao_log AS log
    JOIN tb_pag_espelhos AS pag
        ON log.log_cd_espelho = pag.mtn_cd_motorista_nfs
    JOIN tb_parametros AS par
        ON pag.mtn_cod_cliente = par.prm_cod_cliente
       AND par.prm_ds_chave = 'OXPay_CriarOrdem'
       AND par.prm_ds_valor = 'true'
    JOIN tb_pgto_periodo AS per
        ON pag.mtn_cd_pgto_periodo = per.pgp_cd_periodo
    JOIN tb_motorista AS mot
        ON pag.mtn_cd_motorista = mot.mot_cd_usuario
    JOIN vw_espelhos_nfse AS nfs
        ON nfs.CodigoEspelho = pag.mtn_cd_motorista_nfs
    LEFT JOIN tb_pag_integracao_bancos AS intoxy
        ON intoxy.pib_cd_espelho = pag.mtn_cd_motorista_nfs
    WHERE nfs.StatusEspelho <> 'Documento aprovado'
      AND intoxy.pib_cd_espelho IS NULL;

      COMMIT TRANSACTION; 
  END; 
GO
