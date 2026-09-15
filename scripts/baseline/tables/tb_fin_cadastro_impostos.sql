-- ============================================================
-- BASELINE: dbo.tb_fin_cadastro_impostos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_cadastro_impostos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_cadastro_impostos](
	[cdi_cd_imposto] [int] IDENTITY(1,1) NOT NULL,
	[cdi_ds_imposto] [varchar](150) NOT NULL,
	[cdi_vl_imposto] [numeric](5, 4) NULL,
	[cdi_cd_cliente] [int] NOT NULL,
	[cdi_in_ativo] [bit] NOT NULL,
	[cdi_dh_criacao] [datetime2](0) NOT NULL,
	[cdi_cd_base] [int] NULL,
	[cdi_cd_dom_fer] [int] NULL,
 CONSTRAINT [PK_tb_fin_cadastro_impostos] PRIMARY KEY CLUSTERED 
(
	[cdi_cd_imposto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_fin_cadastro_impostos] UNIQUE NONCLUSTERED 
(
	[cdi_ds_imposto] ASC,
	[cdi_cd_cliente] ASC,
	[cdi_in_ativo] ASC,
	[cdi_cd_base] ASC,
	[cdi_cd_dom_fer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
