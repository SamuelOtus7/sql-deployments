-- ============================================================
-- BASELINE: dbo.tb_spe_return_order_upload
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_return_order_upload]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_return_order_upload](
	[OrderID] [varchar](100) NULL,
	[SLSTrackingNumber] [varchar](150) NULL,
	[ShopeeOrderSN] [varchar](150) NULL,
	[Longitude] [varchar](100) NULL,
	[Latitude] [varchar](100) NULL,
	[SortCodeName] [varchar](200) NULL,
	[ZipcodeName] [varchar](200) NULL,
	[BuyerName] [varchar](250) NULL,
	[BuyerPhone] [varchar](100) NULL,
	[BuyerAddress] [varchar](1000) NULL,
	[LocationType] [varchar](100) NULL,
	[PostalCode] [varchar](50) NULL,
	[DriverID] [varchar](100) NULL,
	[DriverName] [varchar](250) NULL,
	[DriverPhone] [varchar](100) NULL,
	[ReceivedTime] [varchar](100) NULL,
	[CurrentStationReceivedTime] [varchar](100) NULL,
	[DeliveringTime] [varchar](100) NULL,
	[DeliveredTime] [varchar](100) NULL,
	[OnHoldTime] [varchar](100) NULL,
	[OnHoldReason] [varchar](1000) NULL,
	[RescheduleDate] [varchar](100) NULL,
	[Status] [varchar](100) NULL,
	[RejectRemark] [varchar](1000) NULL,
	[CODAmount] [varchar](100) NULL,
	[ManifestNumber] [varchar](150) NULL,
	[OrderAccount] [varchar](150) NULL,
	[OriginalASF] [varchar](100) NULL,
	[RoundingASF] [varchar](100) NULL,
	[TotalOfOnHoldTimes] [varchar](100) NULL,
	[RescheduleTime] [varchar](100) NULL,
	[DeliveryAttempts] [varchar](100) NULL,
	[BulkyType] [varchar](150) NULL,
	[SLATargetDate] [varchar](100) NULL,
	[TimeToSLA] [varchar](100) NULL,
	[PaymentMethod] [varchar](100) NULL,
	[CurrentStation] [varchar](200) NULL,
	[ReturnDestination] [varchar](200) NULL,
	[ShopID] [varchar](100) NULL,
	[ShopCategory] [varchar](150) NULL,
	[Inbound3PL] [varchar](150) NULL,
	[Outbound3PL] [varchar](150) NULL,
	[Channel] [varchar](150) NULL,
	[TN3PL] [varchar](150) NULL,
	[CalculationStatus] [varchar](150) NULL,
	[ZoneID] [varchar](100) NULL,
	[ZoneName] [varchar](150) NULL,
	[DestinationStation] [varchar](200) NULL,
	[NextStation] [varchar](200) NULL,
	[PickupStation] [varchar](200) NULL,
	[DriverContractType] [varchar](150) NULL,
	[PickUpTime] [varchar](100) NULL,
	[CollectedTime] [varchar](100) NULL,
	[TransportedToSpTime] [varchar](100) NULL,
	[SLATag] [varchar](100) NULL,
	[HighValue] [varchar](100) NULL,
	[SpecicalDgType] [varchar](150) NULL,
	[DamagedTag] [varchar](100) NULL,
	[ChargeableWeight] [varchar](100) NULL,
	[LiquidTag] [varchar](100) NULL,
	[FragileTag] [varchar](100) NULL,
	[MagneticTag] [varchar](100) NULL,
	[NumberOfReturnOnHold] [varchar](100) NULL,
	[idtransportadora] [int] NULL
) ON [PRIMARY]
GO
