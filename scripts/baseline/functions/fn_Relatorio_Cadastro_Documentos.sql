-- ============================================================
-- BASELINE: dbo.fn_Relatorio_Cadastro_Documentos
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_Relatorio_Cadastro_Documentos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_Relatorio_Cadastro_Documentos]
(
    @codcliente int = NULL
)
RETURNS TABLE
AS
RETURN

--select distinct cme_ds_status from fn_Relatorio_Cadastro_Documentos(59)

--declare @codcliente int  = 59;

WITH RotasFiltradas AS (
    SELECT DISTINCT
         r.nomemotorista
        ,r.usuarioda
        ,r.servicecenter
        ,c.cli_cd_codigo_cliente
    FROM tb_ml_rotas AS r WITH (NOLOCK)
    LEFT JOIN tb_clientes AS c
        ON r.IdTransportadora = c.cli_id_logistics
    WHERE 1 = 1
      AND (c.cli_cd_codigo_cliente = @codcliente OR @codcliente IS NULL)
      AND r.datareferencia >= CAST(GETDATE() - 30 AS date)
      AND r.excluido = 0
      AND r.statusrota <> 'planned'
    --AND r.NomeMotorista = 'Adailson de Lima Souza Santos'
),
MotoristaContrato AS (
    SELECT DISTINCT
        envi.cde_cd_cliente,
        envi.cde_cd_usuario,
        ttc.ttc_nm_tipo
    FROM tb_contratos_documentos_enviados AS envi WITH (NOLOCK)
    INNER JOIN tb_contratos AS cont WITH (NOLOCK)
        ON cont.ctt_cd_contrato = envi.cde_cd_contrato
    LEFT JOIN tb_contratos_tipo_contrato AS ctn WITH (NOLOCK)
        ON ctn.ctn_cd_contrato = cont.ctt_cd_contrato
       AND ctn.ctn_in_ativo = 1
       AND ctn.ctn_in_excluido = 0
    LEFT JOIN tb_tipo_contrato AS ttc WITH (NOLOCK)
        ON ttc.ttc_cd_tipo_contrato = ctn.ctn_cd_tipo_contrato
       AND ttc.ttc_in_ativo = 1
       AND ttc.ttc_in_excluido = 0
)

-- 1º bloco: Comprovantes
SELECT
    'Comprovantes' AS Grupo,
    rf.nomemotorista,
    rf.usuarioda,
    rf.cli_cd_codigo_cliente,
    cmp.cmp_nm_comprovante,
    CASE WHEN rf.usuarioda IS NULL THEN 'Sem usuario' ELSE ISNULL(envi.cme_ds_status, 'Sem documento') END cme_ds_status,
    1 CampoTotal,
    CASE WHEN envi.cme_ds_status IS NOT NULL THEN 1 ELSE 0 END CampoPreenchido,
    CASE WHEN envi.cme_ds_status IS NULL THEN 1 ELSE 0 END CampoEmBranco,
    servicecenter,
    CAST(cme_dh_criacao AS date) DataEnvio,
    mc.ttc_nm_tipo
FROM RotasFiltradas AS rf
LEFT JOIN (
    SELECT
         cmp_cd_comprovante,
         cmp_nm_comprovante,
         cmp_cd_cliente
    FROM tb_comprovantes
    WHERE cmp_in_ativo = 1
      AND cmp_in_excluido = 0
      --AND cmp_cd_cliente = @codcliente
) AS cmp
    ON rf.cli_cd_codigo_cliente = cmp.cmp_cd_cliente
LEFT JOIN tb_comprovantes_enviados AS envi
    ON cmp.cmp_cd_comprovante = envi.cme_cd_comprovante
   AND rf.usuarioda = envi.cme_cd_usuario
LEFT JOIN MotoristaContrato AS mc
    ON rf.cli_cd_codigo_cliente = mc.cde_cd_cliente
   AND rf.usuarioda = mc.cde_cd_usuario

UNION ALL

-- 2º bloco: Formulários
SELECT
    'Formulario' AS Grupo,
    rf.nomemotorista,
    rf.usuarioda,
    rf.cli_cd_codigo_cliente,
    frm.frm_nm_formulario,
    CASE WHEN rf.usuarioda IS NULL THEN 'Sem usuario'
         ELSE CASE WHEN resp.frr_json_formulario_resposta IS NOT NULL THEN 'Enviado' ELSE 'Sem documento' END
    END cme_ds_status,
    1 CampoTotal,
    CASE WHEN resp.frr_json_formulario_resposta IS NOT NULL THEN 1 ELSE 0 END CampoPreenchido,
    CASE WHEN resp.frr_json_formulario_resposta IS NULL THEN 1 ELSE 0 END CampoEmBranco,
    servicecenter,
    CAST(frr_dh_criacao AS date) DataEnvio,
    mc.ttc_nm_tipo
FROM RotasFiltradas AS rf
LEFT JOIN (
    SELECT
         frm_cd_formulario,
         frm_nm_formulario,
         cli_cd_codigo_cliente
    FROM tb_formularios
    WHERE 1 = 1
      --and cli_cd_codigo_cliente = @codcliente
      AND frm_in_ativo = 1
) AS frm
    ON rf.cli_cd_codigo_cliente = frm.cli_cd_codigo_cliente
LEFT JOIN tb_formularios_respostas AS resp
    ON resp.cli_cd_codigo_cliente = frm.cli_cd_codigo_cliente
   AND resp.frr_cd_formulario = frm.frm_cd_formulario
   AND rf.usuarioda = resp.frr_cd_usr_criacao
LEFT JOIN MotoristaContrato AS mc
    ON rf.cli_cd_codigo_cliente = mc.cde_cd_cliente
   AND rf.usuarioda = mc.cde_cd_usuario

UNION ALL

-- 3º bloco: Documentos Enviados
SELECT
    'Doc Enviados' AS Grupo,
    rf.nomemotorista,
    rf.usuarioda,
    rf.cli_cd_codigo_cliente,
    doc.cdn_nm_documento,
    CASE WHEN rf.usuarioda IS NULL THEN 'Sem usuario' ELSE ISNULL(envi.cde_ds_status, 'Sem documento') END cde_ds_status,
    1 CampoTotal,
    CASE WHEN envi.cde_ds_status IS NOT NULL THEN 1 ELSE 0 END CampoPreenchido,
    CASE WHEN envi.cde_ds_status IS NULL THEN 1 ELSE 0 END CampoEmBranco,
    servicecenter,
    CAST(cde_dh_criacao AS date) AS DataEnvio,
    doc.ttc_nm_tipo
FROM RotasFiltradas AS rf
LEFT JOIN (
    SELECT
         cont.ctt_cd_contrato,
         cont.ctt_nm_contrato,
         cont.ctt_cd_cliente,
         nesc.cdn_cd_contrato_documento_necessario,
         nesc.cdn_nm_documento,
         ttc.ttc_nm_tipo
    FROM tb_contratos AS cont
    INNER JOIN tb_contratos_documentos_necessarios AS nesc
        ON cont.ctt_cd_contrato = nesc.cdn_cd_contrato
    LEFT JOIN tb_contratos_tipo_contrato AS ctn
        ON ctn.ctn_cd_contrato = cont.ctt_cd_contrato
       AND ctn.ctn_in_ativo = 1
       AND ctn.ctn_in_excluido = 0
    LEFT JOIN tb_tipo_contrato AS ttc
        ON ttc.ttc_cd_tipo_contrato = ctn.ctn_cd_tipo_contrato
       AND ttc.ttc_in_ativo = 1
       AND ttc.ttc_in_excluido = 0
    WHERE 1 = 1
    --and cont.ctt_cd_cliente = @codcliente
) AS doc
    ON rf.cli_cd_codigo_cliente = doc.ctt_cd_cliente
LEFT JOIN tb_contratos_documentos_enviados AS envi
    ON rf.cli_cd_codigo_cliente = envi.cde_cd_cliente
   AND doc.ctt_cd_contrato = envi.cde_cd_contrato
   AND rf.usuarioda = envi.cde_cd_usuario

UNION ALL

-- 3º bloco: Documentos Enviados
SELECT
    'Termos Aceite' AS Grupo,
    rf.nomemotorista,
    rf.usuarioda,
    rf.cli_cd_codigo_cliente,
    doc.tra_nm_termo_aceite,
    --case when rf.usuarioda is null then 'Sem usuario' else  isnull(envi.cde_ds_status,'Sem documento')  end cde_ds_status,
    CASE WHEN rf.usuarioda IS NULL THEN 'Sem usuario'
         ELSE CASE WHEN envi.tac_cd_termo_aceite_confirmado IS NOT NULL THEN 'Enviado' ELSE 'Sem documento' END
    END,
    1 CampoTotal,
    CASE WHEN envi.tac_cd_termo_aceite_confirmado IS NOT NULL THEN 1 ELSE 0 END CampoPreenchido,
    CASE WHEN envi.tac_cd_termo_aceite_confirmado IS NULL THEN 1 ELSE 0 END CampoEmBranco,
    servicecenter,
    CAST(tac_dh_criacao AS date) AS DataEnvio,
    mc.ttc_nm_tipo
FROM RotasFiltradas AS rf
LEFT JOIN (
    SELECT
        tra_cd_cliente,
        tra_cd_termo_aceite,
        tra_nm_termo_aceite
    FROM tb_termos_aceites AS a
    --where tra_cd_cliente = 59

    --and cont.ctt_cd_cliente = @codcliente
) AS doc
    ON rf.cli_cd_codigo_cliente = doc.tra_cd_cliente
LEFT JOIN tb_termos_aceites_confirmados AS envi
    ON rf.cli_cd_codigo_cliente = envi.tac_cd_cliente
   AND doc.tra_cd_termo_aceite = envi.tac_cd_termo_aceite
   AND rf.usuarioda = envi.tac_cd_usuario
LEFT JOIN MotoristaContrato AS mc
    ON rf.cli_cd_codigo_cliente = mc.cde_cd_cliente
   AND rf.usuarioda = mc.cde_cd_usuario;
GO
