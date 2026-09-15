-- ============================================================
-- BASELINE: dbo.sp_import_tb_spe_return_order
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_import_tb_spe_return_order]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_import_tb_spe_return_order]  
(
    @idtransportadora INT,          -- obrigatorio
    @DataInicio DATETIME = NULL,    -- opcional
    @DataFim DATETIME = NULL        -- opcional
)
AS

set dateformat dmy
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @idtransportadora IS NULL
    BEGIN
        THROW 50001, 'Parametro @idtransportadora e obrigatorio.', 1;
    END;

    DECLARE @ProcessId UNIQUEIDENTIFIER = NEWID();
    DECLARE @Inserted INT = 0;
    DECLARE @Logged INT = 0;

    DECLARE @DataInicioEfetiva DATETIME2(0);
    DECLARE @DataFimEfetiva DATETIME2(0);

    -- Regra: se nao preencher, usa ultimos 2 dias
    SET @DataInicioEfetiva = ISNULL(CONVERT(DATETIME2(0), @DataInicio), DATEADD(DAY, -2, CONVERT(DATE, SYSDATETIME())));
    SET @DataFimEfetiva    = ISNULL(CONVERT(DATETIME2(0), @DataFim),    CONVERT(DATETIME2(0), SYSDATETIME()));

    IF @DataInicioEfetiva > @DataFimEfetiva
    BEGIN
        THROW 50002, '@DataInicio nao pode ser maior que @DataFim.', 1;
    END;

    IF OBJECT_ID('tempdb..#src') IS NOT NULL DROP TABLE #src;

    ;WITH src AS
    (
        SELECT
            u.idtransportadora,
            LTRIM(RTRIM(u.SLSTrackingNumber)) AS codigopacote,
            u.ZipcodeName,
            u.BuyerName,
            u.DriverName,
            NULLIF(LTRIM(RTRIM(u.DestinationStation)), '') AS DestinationStation,
            NULLIF(LTRIM(RTRIM(u.DriverID)), '') AS DriverID,
            CONVERT(varchar(16), TRY_CONVERT(datetime2(0), CurrentStationReceivedTime, 103), 120) AS CurrentStationReceivedTimeDT,
            CONVERT(varchar(16), TRY_CONVERT(datetime2(0), CurrentStationReceivedTime, 103), 120) AS CurrentStationReceivedTimeRaw,
            u.ShopeeOrderSN,
            u.Longitude AS LongitudeRaw,
            u.Latitude AS LatitudeRaw,
            TRY_CONVERT(DECIMAL(18,6),
                CASE
                    WHEN u.Longitude LIKE '%,%,%' THEN STUFF(REPLACE(u.Longitude, ',', ''), CHARINDEX(',', u.Longitude), 0, '.')
                    WHEN u.Longitude LIKE '%,%' THEN REPLACE(u.Longitude, ',', '.')
                    ELSE u.Longitude
                END
            ) AS LongitudeDec,
            TRY_CONVERT(DECIMAL(18,6),
                CASE
                    WHEN u.Latitude LIKE '%,%,%' THEN STUFF(REPLACE(u.Latitude, ',', ''), CHARINDEX(',', u.Latitude), 0, '.')
                    WHEN u.Latitude LIKE '%,%' THEN REPLACE(u.Latitude, ',', '.')
                    ELSE u.Latitude
                END
            ) AS LatitudeDec,
            ROW_NUMBER() OVER (
                PARTITION BY u.idtransportadora, LTRIM(RTRIM(u.SLSTrackingNumber))
                ORDER BY TRY_CONVERT(DATETIME2(0), u.CurrentStationReceivedTime, 103) DESC, u.ShopeeOrderSN DESC
            ) AS rn
        FROM dbo.tb_spe_return_order_upload u
        WHERE u.idtransportadora = @idtransportadora
  AND TRY_CONVERT(datetime2(0), u.CurrentStationReceivedTime, 103) >= @DataInicioEfetiva
  AND TRY_CONVERT(datetime2(0), u.CurrentStationReceivedTime, 103) < DATEADD(DAY, 1, @DataFimEfetiva)
    )
    SELECT *
    INTO #src
    FROM src;


    /* 1) Log: duplicado dentro do upload */
    INSERT INTO dbo.tb_spe_return_order_import_log
    (
        ProcessId, ErrorType, ErrorDetail, idtransportadora, codigopacote, ShopeeOrderSN,
        CurrentStationReceivedTimeRaw, LongitudeRaw, LatitudeRaw
    )
    SELECT
        @ProcessId,
        'DUPLICADO_UPLOAD',
        'Chave repetida no upload; somente rn=1 sera considerada',
        s.idtransportadora, s.codigopacote, s.ShopeeOrderSN,
        s.CurrentStationReceivedTimeRaw, s.LongitudeRaw, s.LatitudeRaw
    FROM #src s
    WHERE s.rn > 1;

    SET @Logged += @@ROWCOUNT;

    /* 2) Log: duplicado no destino */
    INSERT INTO dbo.tb_spe_return_order_import_log
    (
        ProcessId, ErrorType, ErrorDetail, idtransportadora, codigopacote, ShopeeOrderSN,
        CurrentStationReceivedTimeRaw, LongitudeRaw, LatitudeRaw
    )
    SELECT
        @ProcessId,
        'DUPLICADO_DESTINO',
        'Registro ja existe na tabela destino',
        s.idtransportadora, s.codigopacote, s.ShopeeOrderSN,
        s.CurrentStationReceivedTimeRaw, s.LongitudeRaw, s.LatitudeRaw
    FROM #src s
    INNER JOIN dbo.tb_spe_return_order d
        ON d.idtransportadora = s.idtransportadora
       AND d.codigopacote = s.codigopacote
    WHERE s.rn = 1;

    SET @Logged += @@ROWCOUNT;

    /* 3) Log: dados invalidos */
    INSERT INTO dbo.tb_spe_return_order_import_log
    (
        ProcessId, ErrorType, ErrorDetail, idtransportadora, codigopacote, ShopeeOrderSN,
        CurrentStationReceivedTimeRaw, LongitudeRaw, LatitudeRaw
    )
    SELECT
        @ProcessId,
        'DADO_INVALIDO',
        CASE
            WHEN s.idtransportadora IS NULL OR s.codigopacote IS NULL OR s.codigopacote = '' THEN 'Chave obrigatoria invalida'
            WHEN s.CurrentStationReceivedTimeDT IS NULL THEN 'CurrentStationReceivedTime invalida'
            WHEN s.LongitudeDec IS NULL OR s.LatitudeDec IS NULL THEN 'Longitude/Latitude nao numericas'
            WHEN s.LongitudeDec NOT BETWEEN -180 AND 180 OR s.LatitudeDec NOT BETWEEN -90 AND 90 THEN 'Longitude/Latitude fora da faixa geografica'
            ELSE 'Validacao nao mapeada'
        END,
        s.idtransportadora, s.codigopacote, s.ShopeeOrderSN,
        s.CurrentStationReceivedTimeRaw, s.LongitudeRaw, s.LatitudeRaw
    FROM #src s
    WHERE s.rn = 1
      AND (
            s.idtransportadora IS NULL
            OR s.codigopacote IS NULL OR s.codigopacote = ''
            OR s.CurrentStationReceivedTimeDT IS NULL
            OR s.LongitudeDec IS NULL OR s.LatitudeDec IS NULL
            OR s.LongitudeDec NOT BETWEEN -180 AND 180
            OR s.LatitudeDec NOT BETWEEN -90 AND 90
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.tb_spe_return_order d
          WHERE d.idtransportadora = s.idtransportadora
            AND d.codigopacote = s.codigopacote
      );

    SET @Logged += @@ROWCOUNT;

    /* 4) Insert apenas validos e nao duplicados */
    INSERT INTO dbo.tb_spe_return_order
    (
        idtransportadora, codigopacote, ZipcodeName, BuyerName, DriverName,
        DestinationStation, DriverID,
        CurrentStationReceivedTime, ShopeeOrderSN, Longitude, Latitude
    )
    SELECT
        s.idtransportadora, s.codigopacote, s.ZipcodeName, s.BuyerName, s.DriverName,
        s.DestinationStation, s.DriverID,
        s.CurrentStationReceivedTimeDT, s.ShopeeOrderSN, s.LongitudeDec, s.LatitudeDec
    FROM #src s
    WHERE s.rn = 1
      AND s.idtransportadora IS NOT NULL
      AND s.codigopacote IS NOT NULL AND s.codigopacote <> ''
      AND s.CurrentStationReceivedTimeDT IS NOT NULL
      AND s.LongitudeDec IS NOT NULL AND s.LatitudeDec IS NOT NULL
      AND s.LongitudeDec BETWEEN -180 AND 180
      AND s.LatitudeDec BETWEEN -90 AND 90
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.tb_spe_return_order d
          WHERE d.idtransportadora = s.idtransportadora
            AND d.codigopacote = s.codigopacote
      );

    SET @Inserted = @@ROWCOUNT;

    SELECT
        @ProcessId AS ProcessId,
        @idtransportadora AS idtransportadora,
        @DataInicioEfetiva AS DataInicioUtilizada,
        @DataFimEfetiva AS DataFimUtilizada,
        @Inserted AS InsertedRows,
        @Logged AS LoggedRows;
END
GO
