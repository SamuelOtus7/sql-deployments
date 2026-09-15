-- ============================================================
-- BASELINE: dbo.usp_spe_return_order_upload_import
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_spe_return_order_upload_import]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_spe_return_order_upload_import]
    @idtransportadora INT,
    @SLSTrackingNumber VARCHAR(150),
    @ZipcodeName VARCHAR(200) = NULL,
    @BuyerName VARCHAR(250) = NULL,
    @DriverName VARCHAR(250) = NULL,
    @CurrentStationReceivedTime VARCHAR(100) = NULL,
    @ShopeeOrderSN VARCHAR(150) = NULL,
    @Longitude VARCHAR(100) = NULL,
    @Latitude VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @LongitudeConvertida VARCHAR(100);
    DECLARE @LatitudeConvertida VARCHAR(100);

    SET @LongitudeConvertida =
        CASE
            WHEN @Longitude IS NULL THEN NULL
            WHEN @Longitude LIKE '%,%,%' THEN STUFF(REPLACE(@Longitude, ',', ''), CHARINDEX(',', @Longitude), 0, '.')
            WHEN @Longitude LIKE '%,%'   THEN REPLACE(@Longitude, ',', '.')
            ELSE @Longitude
        END;

    SET @LatitudeConvertida =
        CASE
            WHEN @Latitude IS NULL THEN NULL
            WHEN @Latitude LIKE '%,%,%' THEN STUFF(REPLACE(@Latitude, ',', ''), CHARINDEX(',', @Latitude), 0, '.')
            WHEN @Latitude LIKE '%,%'   THEN REPLACE(@Latitude, ',', '.')
            ELSE @Latitude
        END;

    IF @SLSTrackingNumber IS NULL OR LTRIM(RTRIM(@SLSTrackingNumber)) = ''
    BEGIN
        INSERT INTO dbo.tb_spe_return_order_upload_error_log
        (
            ProcedureName, ErrorType, ErrorMessage,
            idtransportadora, SLSTrackingNumber, ZipcodeName, BuyerName, DriverName,
            CurrentStationReceivedTime, ShopeeOrderSN,
            LongitudeOriginal, LatitudeOriginal, LongitudeConvertida, LatitudeConvertida
        )
        VALUES
        (
            OBJECT_NAME(@@PROCID), 'VALIDATION', 'SLSTrackingNumber nulo ou vazio.',
            @idtransportadora, @SLSTrackingNumber, @ZipcodeName, @BuyerName, @DriverName,
            @CurrentStationReceivedTime, @ShopeeOrderSN,
            @Longitude, @Latitude, @LongitudeConvertida, @LatitudeConvertida
        );

        RAISERROR('Importacao rejeitada: SLSTrackingNumber nulo ou vazio.', 16, 1);
        RETURN;
    END;

    IF (@LongitudeConvertida IS NOT NULL AND TRY_CONVERT(DECIMAL(12,6), @LongitudeConvertida) IS NULL)
       OR (@LatitudeConvertida IS NOT NULL AND TRY_CONVERT(DECIMAL(12,6), @LatitudeConvertida) IS NULL)
    BEGIN
        INSERT INTO dbo.tb_spe_return_order_upload_error_log
        (
            ProcedureName, ErrorType, ErrorMessage,
            idtransportadora, SLSTrackingNumber, ZipcodeName, BuyerName, DriverName,
            CurrentStationReceivedTime, ShopeeOrderSN,
            LongitudeOriginal, LatitudeOriginal, LongitudeConvertida, LatitudeConvertida
        )
        VALUES
        (
            OBJECT_NAME(@@PROCID), 'VALIDATION', 'Longitude/Latitude invalidas apos conversao.',
            @idtransportadora, @SLSTrackingNumber, @ZipcodeName, @BuyerName, @DriverName,
            @CurrentStationReceivedTime, @ShopeeOrderSN,
            @Longitude, @Latitude, @LongitudeConvertida, @LatitudeConvertida
        );

        RAISERROR('Importacao rejeitada: Longitude/Latitude invalidas.', 16, 1);
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM dbo.tb_spe_return_order_upload t
        WHERE t.idtransportadora = @idtransportadora
          AND t.SLSTrackingNumber = @SLSTrackingNumber
    )
    BEGIN
        INSERT INTO dbo.tb_spe_return_order_upload_error_log
        (
            ProcedureName, ErrorType, ErrorMessage,
            idtransportadora, SLSTrackingNumber, ZipcodeName, BuyerName, DriverName,
            CurrentStationReceivedTime, ShopeeOrderSN,
            LongitudeOriginal, LatitudeOriginal, LongitudeConvertida, LatitudeConvertida
        )
        VALUES
        (
            OBJECT_NAME(@@PROCID), 'DUPLICATE', 'Registro duplicado para (idtransportadora, SLSTrackingNumber).',
            @idtransportadora, @SLSTrackingNumber, @ZipcodeName, @BuyerName, @DriverName,
            @CurrentStationReceivedTime, @ShopeeOrderSN,
            @Longitude, @Latitude, @LongitudeConvertida, @LatitudeConvertida
        );

        RETURN;
    END;

    BEGIN TRY
        INSERT INTO dbo.tb_spe_return_order_upload
        (
            idtransportadora,
            SLSTrackingNumber,
            ZipcodeName,
            BuyerName,
            DriverName,
            CurrentStationReceivedTime,
            ShopeeOrderSN,
            Longitude,
            Latitude
        )
        VALUES
        (
            @idtransportadora,
            @SLSTrackingNumber,
            @ZipcodeName,
            @BuyerName,
            @DriverName,
            @CurrentStationReceivedTime,
            @ShopeeOrderSN,
            @LongitudeConvertida,
            @LatitudeConvertida
        );
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.tb_spe_return_order_upload_error_log
        (
            ProcedureName, ErrorType, ErrorMessage,
            idtransportadora, SLSTrackingNumber, ZipcodeName, BuyerName, DriverName,
            CurrentStationReceivedTime, ShopeeOrderSN,
            LongitudeOriginal, LatitudeOriginal, LongitudeConvertida, LatitudeConvertida
        )
        VALUES
        (
            OBJECT_NAME(@@PROCID), 'ERROR', ERROR_MESSAGE(),
            @idtransportadora, @SLSTrackingNumber, @ZipcodeName, @BuyerName, @DriverName,
            @CurrentStationReceivedTime, @ShopeeOrderSN,
            @Longitude, @Latitude, @LongitudeConvertida, @LatitudeConvertida
        );

        THROW;
    END CATCH;
END;
GO
