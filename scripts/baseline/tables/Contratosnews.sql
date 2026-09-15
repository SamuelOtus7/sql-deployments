-- ============================================================
-- BASELINE: dbo.Contratosnews
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Contratosnews]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Contratosnews](
	[Motorista] [nvarchar](50) NOT NULL,
	[Total] [money] NOT NULL,
	[Favorecido] [nvarchar](50) NULL,
	[Projeto] [nvarchar](50) NOT NULL,
	[Deparmento_Fun_o] [nvarchar](50) NOT NULL,
	[usuarioresponsavel] [nvarchar](255) NULL
) ON [PRIMARY]
GO
