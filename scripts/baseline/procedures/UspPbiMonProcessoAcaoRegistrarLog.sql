-- ============================================================
-- BASELINE: dbo.UspPbiMonProcessoAcaoRegistrarLog
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspPbiMonProcessoAcaoRegistrarLog]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspPbiMonProcessoAcaoRegistrarLog]
    @processo_id     INT,
    @proc_acao       VARCHAR(128),
    @ds_usuario      NVARCHAR(100)  = NULL,
    @parametros_json NVARCHAR(MAX)  = NULL,
    @comando         NVARCHAR(MAX)  = NULL,
    @in_sucesso      BIT,
    @ds_mensagem     NVARCHAR(MAX)  = NULL,
    @nr_duracao_ms   INT            = NULL,
    @linhas          INT            = NULL,
    @dh_inicio       DATETIME2(3)   = NULL,
    @acao_log_id     BIGINT         = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dh_execucao DATETIME2(3) = SYSDATETIME();

    IF @nr_duracao_ms IS NULL AND @dh_inicio IS NOT NULL
        SET @nr_duracao_ms = DATEDIFF(MILLISECOND, @dh_inicio, @dh_execucao);

    INSERT INTO dbo.tb_pbi_mon_processo_acao_log
    (
        processo_id, dh_execucao, ds_usuario, proc_acao, ds_parametros_json,
        ds_comando_executado, in_sucesso, ds_mensagem, nr_duracao_ms, nr_linhas_afetadas
    )
    VALUES
    (
        @processo_id, ISNULL(@dh_inicio, @dh_execucao), @ds_usuario, @proc_acao, @parametros_json,
        @comando, @in_sucesso, LEFT(@ds_mensagem, 2000), @nr_duracao_ms, @linhas
    );

    SET @acao_log_id = SCOPE_IDENTITY();
END;
GO
