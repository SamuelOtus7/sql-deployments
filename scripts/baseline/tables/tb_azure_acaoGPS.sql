-- ============================================================
-- BASELINE: dbo.tb_azure_acaoGPS
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_azure_acaoGPS]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_azure_acaoGPS](
	[PartitionKey] [varchar](max) NULL,
	[RowKey] [varchar](max) NULL,
	[Timestamp] [datetime] NULL,
	[DataHoraColeta] [datetime] NULL,
	[CodigoUsuario] [int] NULL,
	[Latitude] [decimal](18, 8) NULL,
	[Longitude] [decimal](18, 8) NULL,
	[Duracao] [decimal](18, 8) NULL,
	[Km] [decimal](18, 8) NULL,
	[versionApp] [varchar](20) NULL,
	[uuid] [varchar](255) NULL,
	[acao] [char](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
