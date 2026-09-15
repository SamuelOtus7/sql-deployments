-- ============================================================
-- BASELINE: dbo.UspPbiMonProcessoAcaoExecutar
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspPbiMonProcessoAcaoExecutar]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspPbiMonProcessoAcaoExecutar]
    @processo_id     INT,
    @parametros_json NVARCHAR(MAX)  = NULL,
    @ds_usuario      NVARCHAR(100)  = NULL,
    @acao_log_id     BIGINT         = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dh_inicio   DATETIME2(3) = SYSDATETIME();
    DECLARE @proc_acao   VARCHAR(128);
    DECLARE @proc_qualif NVARCHAR(300);
    DECLARE @object_id   INT;
    DECLARE @sql         NVARCHAR(MAX);
    DECLARE @fragmentos  NVARCHAR(MAX);
    DECLARE @declaracoes NVARCHAR(MAX);
    DECLARE @msg         NVARCHAR(2000);
    DECLARE @linhas      INT;

    SET @ds_usuario      = ISNULL(@ds_usuario, SUSER_SNAME());
    SET @parametros_json = NULLIF(LTRIM(RTRIM(ISNULL(@parametros_json, N''))), N'');
    SET @parametros_json = ISNULL(@parametros_json, N'{}');

    IF ISJSON(@parametros_json) = 0
    BEGIN
        RAISERROR('@parametros_json nao e um JSON valido.', 16, 1);
        RETURN;
    END

    IF LEFT(LTRIM(@parametros_json), 1) <> N'{'
    BEGIN
        RAISERROR('@parametros_json deve ser um objeto JSON no formato {"@param":"valor"}.', 16, 1);
        RETURN;
    END

    SELECT
        @proc_acao = p.proc_acao,
        @object_id = OBJECT_ID(CASE WHEN p.proc_acao LIKE '%.%' THEN p.proc_acao ELSE 'dbo.' + p.proc_acao END, 'P')
    FROM dbo.tb_pbi_mon_processo AS p
    WHERE p.processo_id = @processo_id
      AND p.in_ativo = 1
      AND p.in_acao_habilitada = 1
      AND p.proc_acao IS NOT NULL;

    IF @proc_acao IS NULL
    BEGIN
        RAISERROR('Processo inexistente, inativo ou sem acao habilitada.', 16, 1);
        RETURN;
    END

    IF @object_id IS NULL
    BEGIN
        SET @msg = N'A procedure cadastrada em proc_acao nao existe neste banco: ' + CAST(@proc_acao AS NVARCHAR(128));
        RAISERROR(@msg, 16, 1);
        RETURN;
    END

    SELECT @proc_qualif = QUOTENAME(SCHEMA_NAME(o.schema_id)) + N'.' + QUOTENAME(o.name)
    FROM sys.objects AS o WHERE o.object_id = @object_id;

    DECLARE @Enviado TABLE (nm_parametro NVARCHAR(128) NOT NULL PRIMARY KEY);

    INSERT INTO @Enviado (nm_parametro)
    SELECT DISTINCT CASE WHEN LEFT(k.[key], 1) = '@' THEN k.[key] ELSE '@' + k.[key] END
    FROM OPENJSON(@parametros_json) AS k
    WHERE k.[type] <> 0 AND LTRIM(RTRIM(ISNULL(k.[value], N''))) <> N'';

    DECLARE @faltantes NVARCHAR(2000);

    SELECT @faltantes = STRING_AGG(ISNULL(v.ds_label, v.nm_parametro) + N' (' + v.nm_parametro + N')', N', ') WITHIN GROUP (ORDER BY v.nr_ordem)
    FROM dbo.vw_pbi_mon_processo_acao_param AS v
    WHERE v.processo_id = @processo_id
      AND v.in_parametro_existe = 1
      AND v.in_obrigatorio = 1
      AND NOT EXISTS (SELECT 1 FROM @Enviado AS e WHERE e.nm_parametro = v.nm_parametro);

    IF @faltantes IS NOT NULL
    BEGIN
        SET @msg = LEFT(N'Parametros obrigatorios nao informados: ' + @faltantes, 2000);
        EXEC dbo.UspPbiMonProcessoAcaoRegistrarLog
             @processo_id = @processo_id, @proc_acao = @proc_acao, @ds_usuario = @ds_usuario,
             @parametros_json = @parametros_json, @comando = NULL, @in_sucesso = 0,
             @ds_mensagem = @msg, @nr_duracao_ms = 0, @linhas = NULL,
             @acao_log_id = @acao_log_id OUTPUT;
        RAISERROR(@msg, 16, 1);
        RETURN;
    END

    DECLARE @tipos_invalidos NVARCHAR(1000);

    SELECT @tipos_invalidos = STRING_AGG(v.nm_parametro + N' (' + v.ds_tipo_sql + N')', N', ')
    FROM dbo.vw_pbi_mon_processo_acao_param AS v
    INNER JOIN @Enviado AS e ON e.nm_parametro = v.nm_parametro
    WHERE v.processo_id = @processo_id
      AND v.in_parametro_existe = 1
      AND v.ds_tipo_sql NOT IN (N'int', N'bigint', N'smallint', N'tinyint', N'bit', N'decimal', N'numeric', N'money', N'smallmoney', N'float', N'real', N'date', N'datetime', N'datetime2', N'smalldatetime', N'time', N'char', N'varchar', N'nchar', N'nvarchar', N'uniqueidentifier');

    IF @tipos_invalidos IS NOT NULL
    BEGIN
        SET @msg = N'Tipo de parametro nao suportado pela execucao via tela: ' + @tipos_invalidos;
        RAISERROR(@msg, 16, 1);
        RETURN;
    END

    ;WITH Param AS
    (
        SELECT
            v.nm_parametro,
            v.nr_ordem,
            ROW_NUMBER() OVER (ORDER BY v.nr_ordem, v.nm_parametro) AS nr_seq,
            CASE
                WHEN v.ds_tipo_sql IN (N'char', N'varchar', N'nchar', N'nvarchar')
                    THEN v.ds_tipo_sql + N'(' + CASE WHEN v.nr_tamanho = -1 THEN N'max' ELSE CAST(v.nr_tamanho AS NVARCHAR(10)) END + N')'
                WHEN v.ds_tipo_sql IN (N'decimal', N'numeric')
                    THEN v.ds_tipo_sql + N'(' + CAST(v.nr_precisao AS NVARCHAR(10)) + N',' + CAST(v.nr_escala AS NVARCHAR(10)) + N')'
                WHEN v.ds_tipo_sql IN (N'datetime2', N'time')
                    THEN v.ds_tipo_sql + N'(' + CAST(v.nr_escala AS NVARCHAR(10)) + N')'
                ELSE v.ds_tipo_sql
            END AS ds_tipo_completo,
            v.ds_tipo_sql,
            N'JSON_VALUE(@json, ''$."' + v.nm_parametro + N'"'')' AS ds_leitura
        FROM dbo.vw_pbi_mon_processo_acao_param AS v
        INNER JOIN @Enviado AS e ON e.nm_parametro = v.nm_parametro
        WHERE v.processo_id = @processo_id AND v.in_parametro_existe = 1
    )
    SELECT
        @declaracoes = STRING_AGG(
            CAST(N'DECLARE @p' + CAST(p.nr_seq AS NVARCHAR(10)) + N' ' + p.ds_tipo_completo
                + N' = TRY_CAST('
                + CASE WHEN p.ds_tipo_sql = N'bit'
                       THEN N'CASE LOWER(' + p.ds_leitura + N') WHEN ''true'' THEN ''1'' WHEN ''false'' THEN ''0'' ELSE ' + p.ds_leitura + N' END'
                       ELSE p.ds_leitura END
                + N' AS ' + p.ds_tipo_completo + N');' AS NVARCHAR(MAX)),
            CHAR(13) + CHAR(10)) WITHIN GROUP (ORDER BY p.nr_seq),
        @fragmentos = STRING_AGG(
            CAST(p.nm_parametro + N' = @p' + CAST(p.nr_seq AS NVARCHAR(10)) AS NVARCHAR(MAX)),
            N', ') WITHIN GROUP (ORDER BY p.nr_seq)
    FROM Param AS p;

    SET @sql = ISNULL(@declaracoes + CHAR(13) + CHAR(10), N'')
             + N'EXEC ' + @proc_qualif
             + CASE WHEN @fragmentos IS NULL THEN N';' ELSE CHAR(13) + CHAR(10) + N'    ' + @fragmentos + N';' END;

    BEGIN TRY
        EXEC sys.sp_executesql @sql, N'@json NVARCHAR(MAX)', @json = @parametros_json;

        SET @linhas = @@ROWCOUNT;

        EXEC dbo.UspPbiMonProcessoAcaoRegistrarLog
             @processo_id = @processo_id, @proc_acao = @proc_acao, @ds_usuario = @ds_usuario,
             @parametros_json = @parametros_json, @comando = @sql, @in_sucesso = 1,
             @ds_mensagem = NULL, @nr_duracao_ms = NULL, @linhas = @linhas,
             @acao_log_id = @acao_log_id OUTPUT, @dh_inicio = @dh_inicio;
    END TRY
    BEGIN CATCH
        SET @msg = ERROR_MESSAGE();

        IF XACT_STATE() = -1 ROLLBACK TRANSACTION;

        EXEC dbo.UspPbiMonProcessoAcaoRegistrarLog
             @processo_id = @processo_id, @proc_acao = @proc_acao, @ds_usuario = @ds_usuario,
             @parametros_json = @parametros_json, @comando = @sql, @in_sucesso = 0,
             @ds_mensagem = @msg, @nr_duracao_ms = NULL, @linhas = NULL,
             @acao_log_id = @acao_log_id OUTPUT, @dh_inicio = @dh_inicio;

        THROW;
    END CATCH
END;
GO
