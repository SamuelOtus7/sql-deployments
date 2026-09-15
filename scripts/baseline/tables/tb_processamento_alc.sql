-- ============================================================
-- BASELINE: dbo.tb_processamento_alc
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_processamento_alc]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_processamento_alc](
	[IdRota] [int] NULL,
	[DataHora] [datetime] NULL,
	[Latitude] [decimal](18, 9) NULL,
	[Longitude] [decimal](18, 9) NULL,
	[SequenciaParada] [int] NULL
) ON [PRIMARY]
GO
