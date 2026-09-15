-- ============================================================
-- BASELINE: dbo.NOVOSVEICULOS
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[NOVOSVEICULOS]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NOVOSVEICULOS](
	[Placa] [nvarchar](50) NULL,
	[Tipo] [nvarchar](50) NULL,
	[Tipo_de_Frota] [nvarchar](50) NULL,
	[Ano_Veic] [nvarchar](50) NULL,
	[Renavan] [nvarchar](50) NULL
) ON [PRIMARY]
GO
