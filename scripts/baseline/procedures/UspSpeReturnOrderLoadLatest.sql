-- ============================================================
-- BASELINE: dbo.UspSpeReturnOrderLoadLatest
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSpeReturnOrderLoadLatest]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
  02_proc_usp_spe_return_order_load_latest.sql
  Procedure de carga para produção:
  - Obtém automaticamente o último LoteId da staging por IdTransportadora + DataReferencia.
  - Limpa produção no recorte (refresh).
  - Insere registros válidos.
  - Registra problemas em tb_spe_return_order_error_log.
*/

CREATE   PROCEDURE [dbo].[UspSpeReturnOrderLoadLatest]
(
    @IdTransportadora INT,
    @DataReferencia DATE
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @DataReferencia IS NULL
    BEGIN
        RAISERROR('@DataReferencia e obrigatorio.', 16, 1);
        RETURN;
    END;

    DECLARE @LoteIdAlvo BIGINT;

    SELECT @LoteIdAlvo = MAX(u.LoteId)
    FROM dbo.tb_spe_return_order_upload u
    WHERE u.IdTransportadora = @IdTransportadora
      AND u.DataReferencia = @DataReferencia;

    IF @LoteIdAlvo IS NULL
    BEGIN
        RAISERROR('Nenhum lote encontrado na staging para os parametros informados.', 16, 1);
        RETURN;
    END;

    ;WITH Fonte AS
    (
        SELECT
            u.*,
            LTRIM(RTRIM(ISNULL(u.OrderID, ''))) AS OrderIDTrim,
            ROW_NUMBER() OVER (PARTITION BY LTRIM(RTRIM(ISNULL(u.OrderID, ''))) ORDER BY u.Id) AS RnOrder
        FROM dbo.tb_spe_return_order_upload u
        WHERE u.IdTransportadora = @IdTransportadora
          AND u.DataReferencia = @DataReferencia
          AND u.LoteId = @LoteIdAlvo
    )
    INSERT INTO dbo.tb_spe_return_order_error_log
    (
        IdTransportadora, DataReferencia, DataImportacao, LoteId, OrderID,
        ErrorType, ErrorMessage, JsonPayload
    )
    SELECT
        f.IdTransportadora,
        f.DataReferencia,
        f.DataImportacao,
        f.LoteId,
        NULL,
        'INVALID_ORDERID',
        'Order ID vazio ou nulo na staging.',
        (
            SELECT f.Id, f.ShopeeOrderSN, f.SLSTrackingNumber, f.BuyerName, f.Status
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
    FROM Fonte f
    WHERE f.OrderIDTrim = '';

    ;WITH Fonte AS
    (
        SELECT
            u.*,
            LTRIM(RTRIM(ISNULL(u.OrderID, ''))) AS OrderIDTrim,
            ROW_NUMBER() OVER (PARTITION BY LTRIM(RTRIM(ISNULL(u.OrderID, ''))) ORDER BY u.Id) AS RnOrder
        FROM dbo.tb_spe_return_order_upload u
        WHERE u.IdTransportadora = @IdTransportadora
          AND u.DataReferencia = @DataReferencia
          AND u.LoteId = @LoteIdAlvo
    )
    INSERT INTO dbo.tb_spe_return_order_error_log
    (
        IdTransportadora, DataReferencia, DataImportacao, LoteId, OrderID,
        ErrorType, ErrorMessage, JsonPayload
    )
    SELECT
        d.IdTransportadora,
        d.DataReferencia,
        d.DataImportacao,
        d.LoteId,
        d.OrderIDTrim,
        'DUPLICATE_IN_STAGE',
        'Order ID duplicado no lote da staging.',
        (
            SELECT d.Id, d.ShopeeOrderSN, d.SLSTrackingNumber, d.BuyerName, d.Status
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
    FROM Fonte d
    WHERE d.OrderIDTrim <> ''
      AND d.RnOrder > 1;

    BEGIN TRAN;

    DELETE p
    FROM dbo.tb_spe_return_order p
    WHERE p.IdTransportadora = @IdTransportadora
      AND p.DataReferencia = @DataReferencia;

    ;WITH Fonte AS
    (
        SELECT
            u.*,
            LTRIM(RTRIM(ISNULL(u.OrderID, ''))) AS OrderIDTrim,
            ROW_NUMBER() OVER (PARTITION BY LTRIM(RTRIM(ISNULL(u.OrderID, ''))) ORDER BY u.Id) AS RnOrder
        FROM dbo.tb_spe_return_order_upload u
        WHERE u.IdTransportadora = @IdTransportadora
          AND u.DataReferencia = @DataReferencia
          AND u.LoteId = @LoteIdAlvo
    ),
    Inserivel AS
    (
        SELECT *
        FROM Fonte
        WHERE OrderIDTrim <> ''
          AND RnOrder = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.tb_spe_return_order p
              WHERE p.OrderID = LTRIM(RTRIM(ISNULL(Fonte.OrderID, '')))
          )
    )
    INSERT INTO dbo.tb_spe_return_order
    (
        IdTransportadora, DataReferencia, DataImportacao, LoteId,
        OrderID, SLSTrackingNumber, ShopeeOrderSN, Longitude, Latitude, SortCodeName, ZipcodeName,
        BuyerName, BuyerPhone, BuyerAddress, LocationType, PostalCode, DriverID, DriverName, DriverPhone,
        ReceivedTime, CurrentStationReceivedTime, DeliveringTime, DeliveredTime, OnHoldTime, OnHoldReason,
        RescheduleDate, [Status], RejectRemark, CODAmount, ManifestNumber, OrderAccount, OriginalASF, RoundingASF,
        TotalOfOnHoldTimes, RescheduleTime, DeliveryAttempts, BulkyType, SLATargetDate, TimeToSLA, PaymentMethod,
        CurrentStation, ReturnDestination, ShopID, ShopCategory, Inbound3PL, Outbound3PL, [Channel], TN3PL,
        CalculationStatus, ZoneID, ZoneName, DestinationStation, NextStation, PickupStation, DriverContractType,
        PickUpTime, CollectedTime, TransportedToSpTime, SLATag, HighValue, SpecicalDgType, DamagedTag,
        ChargeableWeight, LiquidTag, FragileTag, MagneticTag, NumberOfReturnOnHold
    )
    SELECT
        i.IdTransportadora,
        i.DataReferencia,
        i.DataImportacao,
        i.LoteId,

        i.OrderIDTrim,
        i.SLSTrackingNumber,
        i.ShopeeOrderSN,
        TRY_CONVERT(DECIMAL(10,7), REPLACE(i.Longitude, ',', '.')),
        TRY_CONVERT(DECIMAL(10,7), REPLACE(i.Latitude, ',', '.')),
        i.SortCodeName,
        i.ZipcodeName,
        i.BuyerName,
        i.BuyerPhone,
        i.BuyerAddress,
        i.LocationType,
        i.PostalCode,
        i.DriverID,
        i.DriverName,
        i.DriverPhone,

        COALESCE(TRY_CONVERT(DATETIME2(0), i.ReceivedTime, 103), TRY_CONVERT(DATETIME2(0), i.ReceivedTime, 120), TRY_CONVERT(DATETIME2(0), i.ReceivedTime, 126)),
        COALESCE(TRY_CONVERT(DATETIME2(0), i.CurrentStationReceivedTime, 103), TRY_CONVERT(DATETIME2(0), i.CurrentStationReceivedTime, 120), TRY_CONVERT(DATETIME2(0), i.CurrentStationReceivedTime, 126)),
        COALESCE(TRY_CONVERT(DATETIME2(0), i.DeliveringTime, 103), TRY_CONVERT(DATETIME2(0), i.DeliveringTime, 120), TRY_CONVERT(DATETIME2(0), i.DeliveringTime, 126)),
        COALESCE(TRY_CONVERT(DATETIME2(0), i.DeliveredTime, 103), TRY_CONVERT(DATETIME2(0), i.DeliveredTime, 120), TRY_CONVERT(DATETIME2(0), i.DeliveredTime, 126)),
        COALESCE(TRY_CONVERT(DATETIME2(0), i.OnHoldTime, 103), TRY_CONVERT(DATETIME2(0), i.OnHoldTime, 120), TRY_CONVERT(DATETIME2(0), i.OnHoldTime, 126)),
        i.OnHoldReason,
        COALESCE(TRY_CONVERT(DATE, i.RescheduleDate, 103), TRY_CONVERT(DATE, i.RescheduleDate, 120), TRY_CONVERT(DATE, i.RescheduleDate, 126)),
        i.Status,
        i.RejectRemark,
        TRY_CONVERT(DECIMAL(18,2), REPLACE(REPLACE(i.CODAmount, '.', ''), ',', '.')),
        i.ManifestNumber,
        i.OrderAccount,
        TRY_CONVERT(DECIMAL(18,4), REPLACE(REPLACE(i.OriginalASF, '.', ''), ',', '.')),
        TRY_CONVERT(DECIMAL(18,4), REPLACE(REPLACE(i.RoundingASF, '.', ''), ',', '.')),
        TRY_CONVERT(INT, i.TotalOfOnHoldTimes),
        TRY_CONVERT(INT, i.RescheduleTime),
        TRY_CONVERT(INT, i.DeliveryAttempts),
        i.BulkyType,
        COALESCE(TRY_CONVERT(DATETIME2(0), i.SLATargetDate, 103), TRY_CONVERT(DATETIME2(0), i.SLATargetDate, 120), TRY_CONVERT(DATETIME2(0), i.SLATargetDate, 126)),
        i.TimeToSLA,
        i.PaymentMethod,
        i.CurrentStation,
        i.ReturnDestination,
        i.ShopID,
        i.ShopCategory,
        i.Inbound3PL,
        i.Outbound3PL,
        i.Channel,
        i.TN3PL,
        i.CalculationStatus,
        i.ZoneID,
        i.ZoneName,
        i.DestinationStation,
        i.NextStation,
        i.PickupStation,
        i.DriverContractType,
        COALESCE(TRY_CONVERT(DATETIME2(0), i.PickUpTime, 103), TRY_CONVERT(DATETIME2(0), i.PickUpTime, 120), TRY_CONVERT(DATETIME2(0), i.PickUpTime, 126)),
        COALESCE(TRY_CONVERT(DATETIME2(0), i.CollectedTime, 103), TRY_CONVERT(DATETIME2(0), i.CollectedTime, 120), TRY_CONVERT(DATETIME2(0), i.CollectedTime, 126)),
        COALESCE(TRY_CONVERT(DATETIME2(0), i.TransportedToSpTime, 103), TRY_CONVERT(DATETIME2(0), i.TransportedToSpTime, 120), TRY_CONVERT(DATETIME2(0), i.TransportedToSpTime, 126)),
        i.SLATag,
        CASE
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.HighValue, '')))) IN ('1','TRUE','YES','SIM','Y') THEN 1
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.HighValue, '')))) IN ('0','FALSE','NO','NAO','N') THEN 0
            ELSE NULL
        END,
        i.SpecicalDgType,
        CASE
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.DamagedTag, '')))) IN ('1','TRUE','YES','SIM','Y') THEN 1
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.DamagedTag, '')))) IN ('0','FALSE','NO','NAO','N') THEN 0
            ELSE NULL
        END,
        TRY_CONVERT(DECIMAL(18,3), REPLACE(REPLACE(i.ChargeableWeight, '.', ''), ',', '.')),
        CASE
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.LiquidTag, '')))) IN ('1','TRUE','YES','SIM','Y') THEN 1
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.LiquidTag, '')))) IN ('0','FALSE','NO','NAO','N') THEN 0
            ELSE NULL
        END,
        CASE
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.FragileTag, '')))) IN ('1','TRUE','YES','SIM','Y') THEN 1
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.FragileTag, '')))) IN ('0','FALSE','NO','NAO','N') THEN 0
            ELSE NULL
        END,
        CASE
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.MagneticTag, '')))) IN ('1','TRUE','YES','SIM','Y') THEN 1
            WHEN UPPER(LTRIM(RTRIM(ISNULL(i.MagneticTag, '')))) IN ('0','FALSE','NO','NAO','N') THEN 0
            ELSE NULL
        END,
        TRY_CONVERT(INT, i.NumberOfReturnOnHold)
    FROM Inserivel i;

    COMMIT TRAN;

    SELECT
        @IdTransportadora AS IdTransportadora,
        @DataReferencia AS DataReferencia,
        @LoteIdAlvo AS LoteIdProcessado,
        (SELECT COUNT_BIG(1)
         FROM dbo.tb_spe_return_order_upload u
         WHERE u.IdTransportadora = @IdTransportadora
           AND u.DataReferencia = @DataReferencia
           AND u.LoteId = @LoteIdAlvo) AS QtdeStagingLote,
        (SELECT COUNT_BIG(1)
         FROM dbo.tb_spe_return_order p
         WHERE p.IdTransportadora = @IdTransportadora
           AND p.DataReferencia = @DataReferencia) AS QtdeProducaoPosCarga,
        (SELECT COUNT_BIG(1)
         FROM dbo.tb_spe_return_order_error_log e
         WHERE e.IdTransportadora = @IdTransportadora
           AND e.DataReferencia = @DataReferencia
           AND e.LoteId = @LoteIdAlvo) AS QtdeLogErro;
END;
GO
