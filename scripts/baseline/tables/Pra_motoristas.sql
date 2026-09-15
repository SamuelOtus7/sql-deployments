-- ============================================================
-- BASELINE: dbo.Pra_motoristas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Pra_motoristas]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pra_motoristas](
	[PERIODO] [varchar](max) NULL,
	[OPERAÇaO] [varchar](max) NULL,
	[CLIENTE] [varchar](max) NULL,
	[UF] [varchar](max) NULL,
	[BASE] [varchar](max) NULL,
	[MOTORISTA] [varchar](max) NULL,
	[CPF TITULAR MENTORE] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
