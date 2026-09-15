-- ============================================================
-- BASELINE: dbo.UspLoadImpostosPrefatura
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadImpostosPrefatura]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspLoadImpostosPrefatura]
    @IdTransportadora BIGINT,
    @Ano INT,
    @Mes TINYINT,
    @Quinzena TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        ------------------------------------------------------------
        -- Limpa registros anteriores da mesma referência
        ------------------------------------------------------------
        DELETE FROM dbo.tb_fin_prefatura_impostos
        WHERE IdTransportadora = @IdTransportadora
          AND Ano = @Ano
          AND Mes = @Mes
          AND Quinzena = @Quinzena;

        ------------------------------------------------------------
        -- Cria tabela temporária base com os dados brutos
        ------------------------------------------------------------
        IF OBJECT_ID('tempdb..#prefatura_impostos') IS NOT NULL
            DROP TABLE #prefatura_impostos;

        SELECT DISTINCT
            IdTransportadora,
            Ano,
            Mes,
            Quinzena,
            Produto AS Descricao,
            Pais AS IdRota,
            Transportadora AS Cidade,
            TRY_CAST(Column8 AS DECIMAL(15,2)) AS ValorImposto,
            DATEFROMPARTS(Ano, Mes, CASE WHEN Quinzena = 1 THEN 1 ELSE 16 END) AS DataQuinzena,
            GETDATE() AS DataAtualizacao
        INTO #prefatura_impostos
        FROM dbo.tb_fin_prefatura_upload WITH (NOLOCK)
        WHERE IdTransportadora = @IdTransportadora
          AND Ano = @Ano
          AND Mes = @Mes
          AND Quinzena = @Quinzena
          AND (Produto LIKE '%ISS%'
		  OR Produto LIKE '%CTE%');;

        ------------------------------------------------------------
        -- Remove registros sem valor ou sem descrição
        ------------------------------------------------------------
        DELETE FROM #prefatura_impostos
        WHERE ValorImposto IS NULL OR ValorImposto = 0 OR Descricao IS NULL;

        ------------------------------------------------------------
        -- Insere na tabela final (tb_fin_prefatura_impostos)
        ------------------------------------------------------------
        INSERT INTO dbo.tb_fin_prefatura_impostos
        (
            IdTransportadora,
            Ano,
            Mes,
            Quinzena,
            Descricao,
            Cidade,
            ValorImposto,
            DataQuinzena,
            DataAtualizacao
        )
        SELECT
            IdTransportadora,
            Ano,
            Mes,
            Quinzena,
            Descricao,
            Cidade,
            ValorImposto,
            DataQuinzena,
            DataAtualizacao
        FROM #prefatura_impostos;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO
