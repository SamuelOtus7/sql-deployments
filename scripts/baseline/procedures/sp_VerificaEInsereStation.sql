-- ============================================================
-- BASELINE: dbo.sp_VerificaEInsereStation
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_VerificaEInsereStation]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_VerificaEInsereStation]
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Usando MERGE para inserir apenas registros ausentes
        MERGE INTO tb_spe_stationsv2 AS Target
        USING (
            -- Substitua este SELECT pelo seu SELECT correto que traz os registros a serem inseridos
            SELECT 
                DISTINCT 
                trip_hub_id AS IdStation,
                JSON_VALUE(aux.JsonData, '$.data.agency_id') AS IdTransportadora,
                COALESCE(trip_number, 'N/A') AS CodigoStation,
                trip_hub_name AS NomeStation
            FROM db_Irisys_Json.dbo.tb_spe_webhook AS aux
            CROSS APPLY OPENJSON(aux.JsonData, '$.data.body.content_data.data')
            WITH (
                trip_hub_id INT '$.trip_hub_id',
                trip_hub_name NVARCHAR(255) '$.trip_hub_name',
                trip_number NVARCHAR(50) '$.trip_number'
            )
            WHERE TipoJson = 'trip_info'
        ) AS Source
        ON Target.IdStation = Source.IdStation
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                IdStation,
                IdTransportadora,
                CodigoStation,
                NomeStation
            )
            VALUES (
                Source.IdStation,
                Source.IdTransportadora,
                Source.CodigoStation,
                Source.NomeStation
            );

        -- Confirmar a transação
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Reverter transação em caso de erro
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
