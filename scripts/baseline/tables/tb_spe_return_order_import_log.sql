-- ============================================================
-- BASELINE: dbo.tb_spe_return_order_import_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_return_order_import_log]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_return_order_import_log](
	[LogId] [bigint] IDENTITY(1,1) NOT NULL,
	[ProcessId] [uniqueidentifier] NOT NULL,
	[LogDate] [datetime2](0) NOT NULL,
	[ErrorType] [varchar](50) NOT NULL,
	[ErrorDetail] [varchar](500) NOT NULL,
	[idtransportadora] [int] NULL,
	[codigopacote] [varchar](150) NULL,
	[ShopeeOrderSN] [varchar](150) NULL,
	[CurrentStationReceivedTimeRaw] [varchar](100) NULL,
	[LongitudeRaw] [varchar](100) NULL,
	[LatitudeRaw] [varchar](100) NULL,
 CONSTRAINT [PK_tb_spe_return_order_import_log] PRIMARY KEY CLUSTERED 
(
	[LogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
