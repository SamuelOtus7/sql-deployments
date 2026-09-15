-- ============================================================
-- BASELINE: dbo.Usp_processar_validacoes_gerais
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_processar_validacoes_gerais]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[Usp_processar_validacoes_gerais]
    @data DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @data = ISNULL(@data, DATEADD(DAY,-1,CAST(GETDATE() AS DATE)));

    DECLARE
        @vld_cd_validacao INT,
        @vld_ds_sql_script VARCHAR(MAX),
        @vld_cd_cliente INT,
        @sql_exec NVARCHAR(MAX),
        @vld_vl_casos_totais INT,
        @vld_vl_inconsistencias INT;

    DECLARE val_cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT g.vld_cd_validacao,
           g.vld_ds_sql_script,
           c.vlc_cd_cliente
      FROM tb_validacoes_gerais AS g
      JOIN tb_validacoes_gerais_config AS c
        ON g.vld_cd_validacao = c.vlc_cd_validacao
     WHERE g.vld_int_ativo = 1
       AND c.vlc_int_ativo = 1;

    OPEN val_cur;
    FETCH NEXT FROM val_cur INTO 
        @vld_cd_validacao, @vld_ds_sql_script, @vld_cd_cliente;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql_exec = N'
            DECLARE @cliente INT = ' + CAST(@vld_cd_cliente AS VARCHAR(10)) + N';
            DECLARE @data DATE = ''' + CONVERT(VARCHAR(10), @data, 120) + N''';
            ' + @vld_ds_sql_script + N';
        ';

        BEGIN TRY
            CREATE TABLE #res(vl_casos_totais INT, vl_inconsistencias INT);

            INSERT INTO #res
            EXEC sp_executesql @sql_exec;

            SELECT
                @vld_vl_casos_totais = vl_casos_totais,
                @vld_vl_inconsistencias = vl_inconsistencias
              FROM #res;

            DROP TABLE #res;

			DELETE FROM tb_validacoes_gerais_resultados
			WHERE vlr_cd_cliente = @vld_cd_cliente
				  and vlr_dt_resultado = @data
				  and vlr_cd_validacao = @vld_cd_validacao

            INSERT INTO tb_validacoes_gerais_resultados
            VALUES
            (
                @vld_cd_cliente,
                @data,
                @vld_cd_validacao,
                @vld_vl_casos_totais,
                @vld_vl_inconsistencias,
                GETDATE()
            );
        END TRY
        BEGIN CATCH
            DECLARE 
                @ErrMsg NVARCHAR(4000),
                @ErrSeverity INT,
                @ErrState INT,
                @dt_str VARCHAR(10),
                @msg NVARCHAR(4000);

            SET @ErrMsg = ERROR_MESSAGE();
            SET @ErrSeverity = ERROR_SEVERITY();
            SET @ErrState = ERROR_STATE();
            SET @dt_str = CONVERT(VARCHAR(10), @data, 120);
            SET @msg = FORMATMESSAGE(
                'Erro validação=%d cliente=%d data=%s: %s',
                @vld_cd_validacao, @vld_cd_cliente, @dt_str, @ErrMsg
            );

            RAISERROR(@msg, @ErrSeverity, @ErrState);
            RETURN;
        END CATCH;

        FETCH NEXT FROM val_cur INTO 
            @vld_cd_validacao, @vld_ds_sql_script, @vld_cd_cliente;
    END;

    CLOSE val_cur;
    DEALLOCATE val_cur;
END;
GO
