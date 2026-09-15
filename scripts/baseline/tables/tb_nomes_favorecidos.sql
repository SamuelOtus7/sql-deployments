-- ============================================================
-- BASELINE: dbo.tb_nomes_favorecidos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_nomes_favorecidos]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_nomes_favorecidos](
	[nome] [varchar](max) NOT NULL,
	[email] [varchar](max) NOT NULL,
	[telefone] [varchar](max) NOT NULL,
	[base] [varchar](max) NOT NULL,
	[doc] [varchar](max) NOT NULL,
	[idmot] [varchar](max) NOT NULL,
	[idresp] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
