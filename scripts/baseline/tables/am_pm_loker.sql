-- ============================================================
-- BASELINE: dbo.am_pm_loker
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[am_pm_loker]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[am_pm_loker](
	[DataRef] [varchar](max) NULL,
	[Rotas] [varchar](max) NULL,
	[Ciclo] [varchar](max) NULL,
	[HoraInicio] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
