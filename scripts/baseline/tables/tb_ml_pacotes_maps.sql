-- ============================================================
-- BASELINE: dbo.tb_ml_pacotes_maps
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_pacotes_maps]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_pacotes_maps](
	[Rota] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[Latitude] [decimal](18, 9) NULL,
	[Longitude] [decimal](18, 9) NULL,
	[Sequencia] [int] NULL
) ON [PRIMARY]
GO
