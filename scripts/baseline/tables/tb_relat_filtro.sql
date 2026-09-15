-- ============================================================
-- BASELINE: dbo.tb_relat_filtro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_relat_filtro]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_relat_filtro](
	[RLS] [nvarchar](50) NOT NULL,
	[E_mail] [nvarchar](50) NOT NULL,
	[Relatório] [nvarchar](100) NOT NULL,
	[Tabela] [nvarchar](50) NOT NULL,
	[Campo] [nvarchar](50) NOT NULL,
	[Valor] [smallint] NULL
) ON [PRIMARY]
GO
