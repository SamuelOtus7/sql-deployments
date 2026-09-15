-- ============================================================
-- BASELINE: dbo.tb_fin_definie_cidade_distrito
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_definie_cidade_distrito]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_definie_cidade_distrito](
	[fcd_cod] [int] IDENTITY(1,1) NOT NULL,
	[fcd_cd_Base] [int] NOT NULL,
	[fcd_cd_contrato] [int] NOT NULL,
	[fcd_cd_cidade] [int] NOT NULL,
	[fcd_cd_distrito] [int] NOT NULL,
	[fcd_cd_estado] [int] NOT NULL,
	[fcd_cd_cliente] [int] NULL,
	[fcd_cd_regiao] [int] NULL,
	[fcd_in_excluido] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[fcd_cod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
