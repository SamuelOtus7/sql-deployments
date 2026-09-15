-- ============================================================
-- BASELINE: dbo.tb_fin_faturas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_faturas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_faturas](
	[fat_cd_fatura] [int] IDENTITY(1,1) NOT NULL,
	[fat_cd_cliente] [int] NOT NULL,
	[fat_cd_empresa] [int] NOT NULL,
	[fat_cd_fat_cliente] [int] NOT NULL,
	[fat_dt_vencimento] [date] NOT NULL,
	[fat_dt_emissao] [date] NOT NULL,
	[fat_nr_fatura] [varchar](50) NOT NULL,
	[fat_vl_fatura] [decimal](18, 2) NOT NULL,
	[fat_ds_observacao] [nvarchar](max) NULL,
	[fat_usr_criacao] [varchar](50) NOT NULL,
	[fat_dh_criacao] [datetime] NULL,
	[fat_ds_valor_extenso] [nvarchar](max) NULL,
	[Correcao] [decimal](18, 0) NULL,
	[Descontos] [decimal](18, 0) NULL,
	[fat_ds_link_blob_storage] [varchar](255) NULL,
	[fat_cd_servico] [varchar](30) NULL,
	[fat_nr_cnpj] [varchar](50) NULL,
	[fat_ds_endereco] [varchar](510) NULL,
PRIMARY KEY CLUSTERED 
(
	[fat_cd_fatura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
