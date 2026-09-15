-- ============================================================
-- BASELINE: dbo.tb_azure_registroGPS
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_azure_registroGPS]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_azure_registroGPS](
	[PartitionKey] [varchar](36) NOT NULL,
	[RowKey] [varchar](36) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[CodigoUsuario] [int] NOT NULL,
	[Latitude] [decimal](18, 8) NOT NULL,
	[Longitude] [decimal](18, 8) NOT NULL,
	[uuid] [varchar](100) NULL
) ON [PRIMARY]
GO
