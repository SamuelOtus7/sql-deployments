-- ============================================================
-- BASELINE: dbo.tb_spe_return_order_upload_error_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_return_order_upload_error_log]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_return_order_upload_error_log](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[LogDate] [datetime2](0) NOT NULL,
	[ProcedureName] [sysname] NULL,
	[ErrorType] [varchar](50) NOT NULL,
	[ErrorMessage] [varchar](1000) NOT NULL,
	[idtransportadora] [int] NULL,
	[SLSTrackingNumber] [varchar](150) NULL,
	[ZipcodeName] [varchar](200) NULL,
	[BuyerName] [varchar](250) NULL,
	[DriverName] [varchar](250) NULL,
	[CurrentStationReceivedTime] [varchar](100) NULL,
	[ShopeeOrderSN] [varchar](150) NULL,
	[LongitudeOriginal] [varchar](100) NULL,
	[LatitudeOriginal] [varchar](100) NULL,
	[LongitudeConvertida] [varchar](100) NULL,
	[LatitudeConvertida] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
