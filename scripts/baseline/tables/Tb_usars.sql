-- ============================================================
-- BASELINE: dbo.Tb_usars
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Tb_usars]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tb_usars](
	[Nome] [nvarchar](50) NULL,
	[E_mail] [nvarchar](50) NULL,
	[Telefone] [nvarchar](50) NULL,
	[Cargo] [nvarchar](50) NULL,
	[TipoAutenticação] [nvarchar](50) NULL,
	[Restrição] [nvarchar](50) NULL
) ON [PRIMARY]
GO
