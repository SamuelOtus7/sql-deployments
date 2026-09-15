-- ============================================================
-- BASELINE: dbo.stg_BasesLocalizacaoPRA
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_BasesLocalizacaoPRA]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_BasesLocalizacaoPRA](
	[SITE] [varchar](max) NULL,
	[ID] [varchar](max) NULL,
	[TIPO DE SITE] [varchar](max) NULL,
	[CNPJ] [varchar](max) NULL,
	[HÍBRIDO] [varchar](max) NULL,
	[STATUS] [varchar](max) NULL,
	[CRIAÇÃO] [varchar](max) NULL,
	[REGIONAL] [varchar](max) NULL,
	[MAPS] [varchar](max) NULL,
	[ENDEREÇO] [varchar](max) NULL,
	[BAIRRO] [varchar](max) NULL,
	[CIDADE] [varchar](max) NULL,
	[ESTADO] [varchar](max) NULL,
	[CEP] [varchar](max) NULL,
	[LATITUDE] [varchar](max) NULL,
	[LONGITUDE] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
