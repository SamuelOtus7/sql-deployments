-- ============================================================
-- BASELINE: dbo.tb_fin_fat_cliente
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_fat_cliente]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_fat_cliente](
	[fcl_cd_fat_cliente] [int] IDENTITY(1,1) NOT NULL,
	[fcl_cd_cliente] [int] NOT NULL,
	[fcl_cd_empresa_cliente] [int] NOT NULL,
	[fcl_nr_cnpj] [varchar](50) NOT NULL,
	[fcl_ds_endereco] [nvarchar](255) NULL,
	[fcl_ds_municipio] [nvarchar](100) NULL,
	[fcl_ds_inscricao_est] [nvarchar](50) NULL,
	[fcl_ds_praca_pagamento] [nvarchar](100) NULL,
	[fcl_nome_cliente] [nvarchar](100) NULL,
	[fcl_ds_lote] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[fcl_cd_fat_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
