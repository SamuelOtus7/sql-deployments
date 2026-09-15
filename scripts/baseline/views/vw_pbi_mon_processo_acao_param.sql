-- ============================================================
-- BASELINE: dbo.vw_pbi_mon_processo_acao_param
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_mon_processo_acao_param]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_pbi_mon_processo_acao_param]
AS
WITH Acao AS
(
    SELECT
        p.processo_id,
        p.processo_codigo,
        p.processo_nome,
        p.plataforma,
        p.proc_acao,
        p.ds_acao_botao,
        p.in_acao_habilitada,
        p.proc_acao_params,
        OBJECT_ID(
            CASE
                WHEN p.proc_acao LIKE '%.%' THEN p.proc_acao
                ELSE 'dbo.' + p.proc_acao
            END,
            'P'
        ) AS acao_object_id
    FROM dbo.tb_pbi_mon_processo AS p
    WHERE p.proc_acao IS NOT NULL
)
SELECT
    a.processo_id,
    a.processo_codigo,
    a.processo_nome,
    a.plataforma,
    a.proc_acao,
    a.ds_acao_botao,
    a.in_acao_habilitada,
    CASE WHEN LEFT(j.nome, 1) = '@' THEN j.nome ELSE '@' + j.nome END AS nm_parametro,
    ISNULL(j.label, j.nome) AS ds_label,
    TYPE_NAME(sp.user_type_id) AS ds_tipo_sql,
    CASE
        WHEN sp.max_length = -1 THEN -1
        WHEN TYPE_NAME(sp.user_type_id) IN (N'nvarchar', N'nchar') THEN sp.max_length / 2
        ELSE sp.max_length
    END AS nr_tamanho,
    sp.precision AS nr_precisao,
    sp.scale AS nr_escala,
    CAST(COALESCE(j.obrigatorio, CASE WHEN sp.has_default_value = 1 THEN 0 ELSE 1 END) AS BIT) AS in_obrigatorio,
    CAST(COALESCE(j.ordem, sp.parameter_id) AS INT) AS nr_ordem,
    j.valor_default AS ds_valor_default,
    j.ds_ajuda AS ds_ajuda,
    CAST(CASE WHEN sp.parameter_id IS NULL THEN 0 ELSE 1 END AS BIT) AS in_parametro_existe
FROM Acao AS a
CROSS APPLY OPENJSON(ISNULL(a.proc_acao_params, N'[]'))
    WITH
    (
        nome          NVARCHAR(128)  N'$.nome',
        label         NVARCHAR(200)  N'$.label',
        obrigatorio   BIT            N'$.obrigatorio',
        ordem         INT            N'$.ordem',
        valor_default NVARCHAR(400)  N'$.valor_default',
        ds_ajuda      NVARCHAR(1000) N'$.ds_ajuda'
    ) AS j
LEFT JOIN sys.parameters AS sp
       ON sp.object_id = a.acao_object_id
      AND sp.name = CASE WHEN LEFT(j.nome, 1) = '@' THEN j.nome ELSE '@' + j.nome END;
GO
