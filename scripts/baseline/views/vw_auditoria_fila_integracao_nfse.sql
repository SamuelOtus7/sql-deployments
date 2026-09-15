-- ============================================================
-- BASELINE: dbo.vw_auditoria_fila_integracao_nfse
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_auditoria_fila_integracao_nfse]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_auditoria_fila_integracao_nfse]
AS
SELECT
    emp.emp_cd_codigo_cliente              AS Tenant,
    esp.mtn_cd_motorista_nfs               AS CodigoEspelho,
    emp.emp_ds_cnpj                        AS CNPJ,

    esp.mtn_dh_criacao                     AS DataCriacao,
    esp.mtn_dh_envio_nfs                   AS DataEnvio,
    nfse.enf_dh_processamento              AS DataUltimoProcessamento,

    esp.mtn_cd_status                      AS StatusEspelho,
    esp.mtn_vl_nfs                         AS ValorEspelho,
    ISNULL(nfse.enf_qt_tentativas,0)       AS Tentativas,

    esp.mtn_ds_link_nfs                    AS LinkPrincipalEspelho,
    mtn_ds_link_nfs                        AS LinkPrincipalNFSE,
    esp.mtn_ds_link_nfs_secundario,
    esp.mtn_ds_link_nfs_terceiro,
    esp.mtn_ds_link_nfs_quarto,

    /* Flag final: entra ou não */
    CASE 
        WHEN 
            prm.prm_cd_parametro IS NOT NULL
            AND ISNULL(esp.mtn_ds_link_nfs,'') <> ''
            AND esp.mtn_dh_criacao >= '2025-12-01'
            AND esp.mtn_vl_nfs <> 0
            AND esp.mtn_cd_status IN (35,36)
            AND (
                    esp.mtn_ds_link_nfs_secundario IS NULL
                 OR esp.mtn_ds_link_nfs_terceiro   IS NULL
                 OR esp.mtn_ds_link_nfs_quarto     IS NULL
                )
            AND (
                    ISNULL(nfse.enf_qt_tentativas,0) < 50
                 OR (
                        ISNULL(nfse.enf_qt_tentativas,0) >= 50
                        AND (
                               nfse.enf_dh_processamento IS NULL
                            OR esp.mtn_dh_envio_nfs > nfse.enf_dh_processamento
                        )
                    )
                )
            AND (
                    nfse.enf_dh_processamento IS NULL
                 OR nfse.enf_dh_processamento <= esp.mtn_dh_envio_nfs
                )

        THEN 1 ELSE 0
    END AS EntraNaFila,

    /* Motivo detalhado */
    CASE 
        WHEN prm.prm_cd_parametro IS NULL
            THEN 'Bloqueado: Integração NFSe desabilitada para o cliente'

        WHEN ISNULL(esp.mtn_ds_link_nfs,'') = ''
            THEN 'Bloqueado: Espelho sem link principal'

        WHEN esp.mtn_dh_criacao < '2025-12-01'
            THEN 'Bloqueado: Espelho criado antes da data mínima'

        WHEN esp.mtn_vl_nfs = 0
            THEN 'Bloqueado: Valor do espelho zerado'

        WHEN esp.mtn_cd_status NOT IN (35,36)
            THEN 'Bloqueado: Status do espelho inválido para integração'

        WHEN 
            esp.mtn_ds_link_nfs_secundario IS NOT NULL
        AND esp.mtn_ds_link_nfs_terceiro   IS NOT NULL
        AND esp.mtn_ds_link_nfs_quarto     IS NOT NULL
            THEN 'Bloqueado: Espelho já completo (todos os links preenchidos)'

        WHEN ISNULL(nfse.enf_qt_tentativas,0) >= 50
         AND esp.mtn_dh_envio_nfs <= ISNULL(nfse.enf_dh_processamento,'19000101')
            THEN 'Bloqueado: Limite de tentativas atingido sem novo envio'

        WHEN nfse.enf_dh_processamento IS NOT NULL
         AND nfse.enf_dh_processamento > esp.mtn_dh_envio_nfs
            THEN 'Bloqueado: Espelho já processado após o último envio'

        WHEN ISNULL(nfse.enf_qt_tentativas,0) >= 50
         AND esp.mtn_dh_envio_nfs > nfse.enf_dh_processamento
            THEN 'Liberado: Nova nota enviada após limite de tentativas'

        WHEN nfse.enf_dh_processamento IS NULL
            THEN 'Liberado: Espelho nunca processado'

        ELSE 'Liberado: Reprocessamento permitido pelas regras'
    END AS MotivoAuditoria

FROM tb_pag_espelhos esp
JOIN tb_empresas emp
  ON emp.emp_cd_codigo_cliente = esp.mtn_cod_cliente

LEFT JOIN tb_pag_espelhos_nfse nfse
  ON nfse.enf_cd_espelho = esp.mtn_cd_motorista_nfs

LEFT JOIN tb_parametros prm
  ON prm.prm_cod_cliente = esp.mtn_cod_cliente
 AND prm.prm_ds_chave = 'Integração NFSe Habilitada'
 AND prm.prm_ds_valor = 'true';
GO
