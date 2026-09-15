-- ============================================================
-- BASELINE: dbo.tb_imp_importador_coluna
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_imp_importador_coluna]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_imp_importador_coluna](
	[imc_cd_coluna] [int] IDENTITY(1,1) NOT NULL,
	[imp_cd_importador] [int] NOT NULL,
	[imc_ds_nome_coluna] [varchar](150) NOT NULL,
	[imc_ds_coluna_destino] [varchar](150) NOT NULL,
	[imc_nu_ordem] [int] NOT NULL,
	[imc_in_obrigatoria] [bit] NOT NULL,
	[imc_in_permite_nulo] [bit] NOT NULL,
	[imc_ds_tipo_dado] [varchar](30) NOT NULL,
	[imc_nu_tamanho_maximo] [int] NULL,
	[imc_ds_mascara_formato] [varchar](100) NULL,
	[imc_ds_observacao] [varchar](300) NULL,
 CONSTRAINT [PK_tb_imp_importador_coluna] PRIMARY KEY CLUSTERED 
(
	[imc_cd_coluna] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_imp_importador_coluna_nome] UNIQUE NONCLUSTERED 
(
	[imp_cd_importador] ASC,
	[imc_ds_nome_coluna] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
