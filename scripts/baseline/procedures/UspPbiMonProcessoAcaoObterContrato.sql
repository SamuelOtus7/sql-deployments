-- ============================================================
-- BASELINE: dbo.UspPbiMonProcessoAcaoObterContrato
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspPbiMonProcessoAcaoObterContrato]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspPbiMonProcessoAcaoObterContrato]
    @processo_id     INT          = NULL,
    @processo_codigo VARCHAR(50)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @processo_id IS NULL AND @processo_codigo IS NULL
    BEGIN
        RAISERROR('Informe @processo_id ou @processo_codigo.', 16, 1);
        RETURN;
    END

    SELECT @processo_id = p.processo_id
    FROM dbo.tb_pbi_mon_processo AS p
    WHERE (@processo_id IS NOT NULL AND p.processo_id = @processo_id)
       OR (@processo_id IS NULL AND p.processo_codigo = @processo_codigo);

    IF @processo_id IS NULL
    BEGIN
        RAISERROR('Processo nao encontrado.', 16, 1);
        RETURN;
    END

    SELECT
        p.processo_id,
        p.processo_codigo,
        p.processo_nome,
        p.plataforma,
        p.proc_acao,
        ISNULL(p.ds_acao_botao, N'Executar') AS ds_acao_botao,
        p.in_acao_habilitada,
        p.in_ativo,
        CAST(CASE WHEN p.in_ativo = 1 AND p.in_acao_habilitada = 1 AND p.proc_acao IS NOT NULL
                   AND OBJECT_ID(CASE WHEN p.proc_acao LIKE '%.%' THEN p.proc_acao ELSE 'dbo.' + p.proc_acao END, 'P') IS NOT NULL
                  THEN 1 ELSE 0 END AS BIT) AS in_acao_disponivel,
        (SELECT COUNT(*) FROM dbo.vw_pbi_mon_processo_acao_param AS v WHERE v.processo_id = p.processo_id) AS qt_parametros
    FROM dbo.tb_pbi_mon_processo AS p
    WHERE p.processo_id = @processo_id;

    SELECT
        v.nm_parametro,
        v.ds_label,
        v.ds_tipo_sql,
        v.nr_tamanho,
        v.nr_precisao,
        v.nr_escala,
        v.in_obrigatorio,
        v.nr_ordem,
        v.ds_valor_default,
        v.ds_ajuda
    FROM dbo.vw_pbi_mon_processo_acao_param AS v
    WHERE v.processo_id = @processo_id
      AND v.in_parametro_existe = 1
    ORDER BY v.nr_ordem, v.nm_parametro;
END;
GO
