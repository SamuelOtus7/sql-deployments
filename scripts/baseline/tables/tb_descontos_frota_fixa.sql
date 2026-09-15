-- ============================================================
-- BASELINE: dbo.tb_descontos_frota_fixa
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_descontos_frota_fixa]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_descontos_frota_fixa](
	[DATA] [varchar](max) NULL,
	[VALOR] [varchar](max) NULL,
	[HISTORICO] [varchar](max) NULL,
	[MOTORISTA] [varchar](max) NULL,
	[PROJETO] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
