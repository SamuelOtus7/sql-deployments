-- ============================================================
-- BASELINE: dbo.Gestao_Pedagios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Gestao_Pedagios]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gestao_Pedagios](
	[ROTA] [bigint] NOT NULL,
	[DATA] [date] NOT NULL,
	[BASE] [varchar](255) NULL,
	[MATRICULA] [int] NULL,
	[MOTORISTA] [varchar](255) NULL,
	[DISPATCHER] [varchar](255) NULL,
	[MUNICIPIO] [varchar](255) NULL,
	[VALOR] [decimal](10, 2) NULL,
	[STATUS] [varchar](50) NULL,
	[EVIDENCIA_PEDAGIO] [varchar](500) NULL
) ON [PRIMARY]
GO
