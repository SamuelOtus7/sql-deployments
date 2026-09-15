-- ============================================================
-- BASELINE: dbo.newveic
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[newveic]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[newveic](
	[Placa] [nvarchar](50) NULL,
	[Tipo] [nvarchar](50) NULL,
	[Tipo_de_Frota] [nvarchar](50) NULL,
	[Ano_Veic] [smallint] NULL,
	[Renavan] [nvarchar](50) NULL
) ON [PRIMARY]
GO
