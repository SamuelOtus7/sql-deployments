-- ============================================================
-- BASELINE: dbo.descontos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[descontos]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[descontos](
	[DATA] [varchar](50) NULL,
	[Tipo] [varchar](50) NULL,
	[VALOR] [varchar](50) NULL,
	[DESCRICAO] [varchar](200) NULL,
	[Nome_Do_Driver] [varchar](50) NULL,
	[Projeto] [varchar](50) NULL,
	[ID_Rota] [varchar](50) NULL
) ON [PRIMARY]
GO
