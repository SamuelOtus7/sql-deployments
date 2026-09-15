-- ============================================================
-- BASELINE: dbo.Usp_AlarmeScraperParado_GB
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeScraperParado_GB]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Usp_AlarmeScraperParado_GB]
AS
BEGIN
    BEGIN TRY
        IF DATEPART(MINUTE, GETDATE()) <> 0
        BEGIN
            DECLARE @Tolerancia INT = 10 * 60;
            DROP TABLE IF EXISTS #aux;

            SELECT *
            INTO #aux
            FROM vw_status_coletas
            WHERE tipo = 'Totalizadores';

            IF EXISTS (SELECT * FROM #aux WHERE tipo = 'Totalizadores' AND SegundosDesdeAUltimaColeta > @Tolerancia)
            BEGIN
                DECLARE @svcs VARCHAR(1000);
                DECLARE @mensagem VARCHAR(2000);

                SELECT @svcs = SUBSTRING(
                ( 
                    SELECT ServiceCenter AS 'data()'
                    FROM #aux 
                    WHERE SegundosDesdeAUltimaColeta > @Tolerancia
                    AND tipo = 'Totalizadores'
                    FOR XML PATH('')
                ), 2 , 9999);

                SET @mensagem = '*Alerta - ' + FORMAT(GETDATE(), 'dd/MM/yyyy HH:mm:ss')  +  CHAR(10) +
                    'Os Service Centers abaixo estão a mais de ' + CAST(ROUND(@Tolerancia / 60, 0) AS VARCHAR(15)) + ' minutos sem enviar registros para o banco de dados:\'
                    +  CHAR(10) + @svcs;

                
                RAISERROR (@mensagem, 16, 1);
            END;
        END;
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);

        SELECT 
            @ErrorMessage = ERROR_MESSAGE();

        SET @mensagem = @ErrorMessage;

        RAISERROR (@mensagem, 16, 1);
    END CATCH
END;
GO
