-- ============================================================
-- BASELINE: dbo.STG_VERSAN_LAST_MILE_HUB
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[STG_VERSAN_LAST_MILE_HUB]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_VERSAN_LAST_MILE_HUB](
	[Rota] [varchar](50) NULL,
	[TrackingNumber] [varchar](50) NULL,
	[DataPrestacaoServico] [varchar](50) NULL
) ON [PRIMARY]
GO
