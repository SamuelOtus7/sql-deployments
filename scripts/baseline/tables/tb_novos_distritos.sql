-- ============================================================
-- BASELINE: dbo.tb_novos_distritos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_novos_distritos]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_novos_distritos](
	[UF] [int] NULL,
	[Nome_UF] [nvarchar](100) NULL,
	[Região_Geográfica_Intermediária] [int] NULL,
	[Nome_Região_Geográfica_Intermediária] [nvarchar](100) NULL,
	[Região_Geográfica_Imediata] [int] NULL,
	[Nome_Região_Geográfica_Imediata] [nvarchar](100) NULL,
	[Mesorregião_Geográfica] [int] NULL,
	[Nome_Mesorregião] [nvarchar](100) NULL,
	[Microrregião_Geográfica] [int] NULL,
	[Nome_Microrregião] [nvarchar](100) NULL,
	[Município] [int] NULL,
	[Código_Município_Completo] [int] NULL,
	[nome_municipio] [nvarchar](100) NULL,
	[Distrito] [int] NULL,
	[Código_de_Distrito_Completo] [int] NULL,
	[Nome_Distrito] [nvarchar](100) NULL
) ON [PRIMARY]
GO
