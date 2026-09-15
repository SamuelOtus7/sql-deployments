-- ============================================================
-- BASELINE: dbo.vw_documentos_enviados
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_documentos_enviados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_documentos_enviados] AS

SELECT 
    'Termos de Aceite' AS Grupo,
    tra_cd_termo_aceite AS Cd_documento,
	tra_cd_cliente AS TenantId,
    tra_nm_termo_aceite AS Descricao_documento,
    tra_in_ativo AS Ativo,
    tra_in_excluido AS Excluido,
    tra_dh_modificacao AS DataModificacao
FROM tb_termos_aceites

UNION ALL

SELECT
    'Contratos' AS Grupo,
    ctt_cd_contrato AS Cd_documento,
	ctt_cd_cliente AS TenantId,
    ctt_nm_contrato AS Descricao_documento,
    ctt_in_ativo AS Ativo,
    ctt_in_excluido AS Excluido,
    ctt_dh_modificacao AS DataModificacao
FROM tb_contratos

UNION ALL

SELECT 
    'Formulario' AS Grupo,
    frm_cd_formulario AS Cd_documento,
	cli_cd_codigo_cliente AS TenantId,
    frm_nm_formulario AS Descricao_documento,
    frm_in_ativo AS Ativo,
    0 AS Excluido,
    frm_dh_modificacao AS DataModificacao
FROM tb_formularios

UNION ALL

SELECT 
    'Comprovantes' AS Grupo,
    cmp_cd_comprovante AS Cd_documento,
	cmp_cd_cliente as TenantId,
    cmp_nm_comprovante AS Descricao_documento,
    cmp_in_ativo AS Ativo,
    cmp_in_excluido AS Excluido,
    cmp_dh_modificacao AS DataModificacao
FROM tb_comprovantes;
GO
