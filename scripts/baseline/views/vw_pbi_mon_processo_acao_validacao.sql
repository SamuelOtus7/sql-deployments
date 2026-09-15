-- ============================================================
-- BASELINE: dbo.vw_pbi_mon_processo_acao_validacao
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_mon_processo_acao_validacao]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_pbi_mon_processo_acao_validacao]
AS
WITH Acao AS
(
    SELECT
        p.processo_id,
        p.processo_codigo,
        p.proc_acao,
        p.proc_acao_params,
        p.in_acao_habilitada,
        OBJECT_ID(CASE WHEN p.proc_acao LIKE '%.%' THEN p.proc_acao ELSE 'dbo.' + p.proc_acao END) AS obj_id_qualquer,
        OBJECT_ID(CASE WHEN p.proc_acao LIKE '%.%' THEN p.proc_acao ELSE 'dbo.' + p.proc_acao END, 'P') AS obj_id_procedure
    FROM dbo.tb_pbi_mon_processo AS p
    WHERE p.proc_acao IS NOT NULL
)
SELECT a.processo_id, a.processo_codigo, a.proc_acao,
       N'PROC_INEXISTENTE' AS cd_problema, N'ALTA' AS ds_severidade,
       N'A procedure cadastrada em proc_acao nao existe neste banco.' AS ds_detalhe,
       CAST(NULL AS NVARCHAR(128)) AS nm_parametro
FROM Acao AS a WHERE a.obj_id_qualquer IS NULL
UNION ALL
SELECT a.processo_id, a.processo_codigo, a.proc_acao, N'PROC_NAO_E_PROCEDURE', N'ALTA',
       N'O objeto cadastrado em proc_acao existe, mas nao e uma stored procedure.', NULL
FROM Acao AS a WHERE a.obj_id_qualquer IS NOT NULL AND a.obj_id_procedure IS NULL
UNION ALL
SELECT a.processo_id, a.processo_codigo, a.proc_acao, N'CONTRATO_AUSENTE', N'MEDIA',
       N'in_acao_habilitada = 1 mas proc_acao_params esta NULL. Use ''[]'' quando a procedure nao tiver parametros.', NULL
FROM Acao AS a WHERE a.in_acao_habilitada = 1 AND a.proc_acao_params IS NULL
UNION ALL
SELECT a.processo_id, a.processo_codigo, a.proc_acao, N'NOME_PARAMETRO_AUSENTE', N'ALTA',
       N'Existe item em proc_acao_params sem a chave "nome".', NULL
FROM Acao AS a
CROSS APPLY OPENJSON(ISNULL(a.proc_acao_params, N'[]')) WITH (nome NVARCHAR(128) N'$.nome') AS j
WHERE j.nome IS NULL
UNION ALL
SELECT v.processo_id, v.processo_codigo, v.proc_acao, N'PARAMETRO_INEXISTENTE', N'ALTA',
       N'O parametro cadastrado no JSON nao existe na assinatura da procedure.', v.nm_parametro
FROM dbo.vw_pbi_mon_processo_acao_param AS v WHERE v.in_parametro_existe = 0
UNION ALL
SELECT a.processo_id, a.processo_codigo, a.proc_acao, N'PARAMETRO_OBRIGATORIO_AUSENTE', N'ALTA',
       N'Parametro obrigatorio da procedure (sem valor default) nao esta cadastrado em proc_acao_params.', sp.name
FROM Acao AS a
INNER JOIN sys.parameters AS sp ON sp.object_id = a.obj_id_procedure AND sp.is_output = 0 AND sp.has_default_value = 0 AND sp.parameter_id > 0
WHERE NOT EXISTS (SELECT 1 FROM dbo.vw_pbi_mon_processo_acao_param AS v WHERE v.processo_id = a.processo_id AND v.nm_parametro = sp.name)
UNION ALL
SELECT v.processo_id, MIN(v.processo_codigo), MIN(v.proc_acao), N'PARAMETRO_DUPLICADO', N'MEDIA',
       N'O mesmo parametro aparece mais de uma vez em proc_acao_params.', v.nm_parametro
FROM dbo.vw_pbi_mon_processo_acao_param AS v
GROUP BY v.processo_id, v.nm_parametro HAVING COUNT(*) > 1;
GO
