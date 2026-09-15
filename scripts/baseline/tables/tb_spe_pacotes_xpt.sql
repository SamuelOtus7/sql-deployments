-- ============================================================
-- BASELINE: dbo.tb_spe_pacotes_xpt
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_pacotes_xpt]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_pacotes_xpt](
	[CodigoRota] [varchar](30) NOT NULL,
	[CodigoPacote] [varchar](30) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[DataHoraEntrega] [datetime] NULL,
	[ReceiveTag] [int] NULL,
	[StationName] [varchar](30) NULL,
	[HighValue] [int] NULL,
	[ReceiverName] [int] NULL,
	[TransferDirection] [int] NULL,
	[DataAtualizacao] [datetime] NOT NULL
) ON [PRIMARY]
GO
