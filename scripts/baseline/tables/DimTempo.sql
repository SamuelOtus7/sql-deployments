-- ============================================================
-- BASELINE: dbo.DimTempo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[DimTempo]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimTempo](
	[SkTempo] [smallint] NOT NULL,
	[Tempo] [time](7) NOT NULL,
	[Hora] [tinyint] NOT NULL,
	[Minuto] [tinyint] NOT NULL,
	[Turno] [varchar](10) NOT NULL
) ON [PRIMARY]
GO
