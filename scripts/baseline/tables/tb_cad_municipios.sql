-- ============================================================
-- BASELINE: dbo.tb_cad_municipios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_cad_municipios]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_cad_municipios](
	[cmu_cd_municipio] [smallint] IDENTITY(1,1) NOT NULL,
	[cmu_cd_uf_ibge] [int] NOT NULL,
	[cmu_ds_nome_uf] [varchar](30) NOT NULL,
	[cmu_ds_sigla_uf] [char](2) NOT NULL,
	[cmu_cd_municipio_ibge] [int] NOT NULL,
	[cmu_ds_nome_municipio] [varchar](150) NOT NULL,
 CONSTRAINT [pk_cad_municipios] PRIMARY KEY CLUSTERED 
(
	[cmu_cd_municipio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
