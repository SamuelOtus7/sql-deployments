-- ============================================================
-- BASELINE: dbo.tb_ml_cidades_excecao_maps
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_cidades_excecao_maps]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_cidades_excecao_maps](
	[cem_cd_cidades_excecao_maps] [int] IDENTITY(1,1) NOT NULL,
	[cem_nm_cidade] [varchar](150) NULL,
 CONSTRAINT [PK_tb_ml_cidades_excecao_maps] PRIMARY KEY CLUSTERED 
(
	[cem_cd_cidades_excecao_maps] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_ml_cidades_excecao_maps] UNIQUE NONCLUSTERED 
(
	[cem_nm_cidade] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
