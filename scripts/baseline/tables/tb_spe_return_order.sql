-- ============================================================
-- BASELINE: dbo.tb_spe_return_order
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_return_order]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_return_order](
	[ReturnOrderId] [bigint] IDENTITY(1,1) NOT NULL,
	[idtransportadora] [int] NOT NULL,
	[codigopacote] [varchar](150) NOT NULL,
	[ZipcodeName] [varchar](200) NULL,
	[BuyerName] [varchar](250) NULL,
	[DriverName] [varchar](250) NULL,
	[CurrentStationReceivedTime] [datetime2](0) NULL,
	[ShopeeOrderSN] [varchar](150) NULL,
	[Longitude] [decimal](18, 6) NULL,
	[Latitude] [decimal](18, 6) NULL,
	[DataImportacao] [datetime2](0) NOT NULL,
	[DestinationStation] [varchar](200) NULL,
	[DriverID] [varchar](100) NULL,
	[Cidade] [varchar](200) NULL,
 CONSTRAINT [PK_tb_spe_return_order] PRIMARY KEY CLUSTERED 
(
	[ReturnOrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
