-- ============================================================
-- BASELINE: dbo.tb_dra_cidades_geo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_cidades_geo]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_cidades_geo](
	[dcg_cd_cidade_gei] [bigint] IDENTITY(1,1) NOT NULL,
	[dcg_nr_latitude] [decimal](18, 9) NOT NULL,
	[dcg_nr_longitude] [decimal](18, 9) NOT NULL,
	[dcg_ds_cidade] [varchar](150) NULL,
	[dcg_nr_cep] [int] NULL,
	[dcg_ds_estado] [varchar](30) NULL,
	[dcg_distrito] [nvarchar](100) NULL,
	[dcg_ds_cidade_distrito] [varchar](255) NULL,
	[dcg_cidade_distante] [int] NULL,
	[dcg_dh_inclusao] [datetime] NULL,
	[dcg_dh_processamento] [datetime] NULL,
	[dcg_ds_origem] [varchar](30) NULL,
	[dcg_ds_bairro] [varchar](100) NULL,
	[dcg_ds_hamlet] [varchar](100) NULL,
	[dcg_ds_suburbio] [varchar](100) NULL,
	[dcg_ds_village] [varchar](100) NULL,
	[dcg_ds_town] [varchar](100) NULL,
	[dcg_ds_erro] [varchar](255) NULL,
 CONSTRAINT [pk_dra_cidades_geo] PRIMARY KEY CLUSTERED 
(
	[dcg_cd_cidade_gei] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_dra_cidades_geo] UNIQUE NONCLUSTERED 
(
	[dcg_nr_latitude] ASC,
	[dcg_nr_longitude] ASC,
	[dcg_cidade_distante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
