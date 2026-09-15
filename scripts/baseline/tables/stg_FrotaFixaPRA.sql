-- ============================================================
-- BASELINE: dbo.stg_FrotaFixaPRA
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_FrotaFixaPRA]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_FrotaFixaPRA](
	[PLACA] [varchar](max) NULL,
	[BASE] [varchar](max) NULL,
	[TIPO DE VEÍCULO] [varchar](max) NULL,
	[TIPO DA FROTA] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
