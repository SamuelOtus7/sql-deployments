-- ============================================================
-- BASELINE: dbo.Importacao_Dados_Pralog
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Importacao_Dados_Pralog]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Importacao_Dados_Pralog](
	[Data] [varchar](255) NULL,
	[Nome] [varchar](255) NULL,
	[CPF] [varchar](255) NULL,
	[Email] [varchar](255) NULL,
	[Contato] [varchar](255) NULL,
	[Cidade] [varchar](255) NULL,
	[HUB] [varchar](255) NULL
) ON [PRIMARY]
GO
