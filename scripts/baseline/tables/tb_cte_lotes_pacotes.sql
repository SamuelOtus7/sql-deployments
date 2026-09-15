-- ============================================================
-- BASELINE: dbo.tb_cte_lotes_pacotes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_cte_lotes_pacotes]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_cte_lotes_pacotes](
	[clp_cd_lote_pacote] [int] IDENTITY(1,1) NOT NULL,
	[clp_cd_cte_lote] [int] NOT NULL,
	[clp_cd_cliente] [int] NOT NULL,
	[clp_cd_status] [int] NULL,
	[clp_ds_codigo_pacote] [varchar](50) NULL,
	[clp_ds_error] [varchar](1000) NULL,
	[clp_vl_valor] [decimal](18, 2) NULL,
	[clp_ds_chave_cte] [varchar](5000) NULL,
	[clp_ds_url_cte] [varchar](5000) NULL,
	[clp_ds_url_xml] [varchar](max) NULL,
	[clp_cd_usr_criacao] [int] NOT NULL,
	[clp_dh_criacao] [datetime] NOT NULL,
	[clp_cd_usr_modificacao] [int] NOT NULL,
	[clp_dh_modificacao] [datetime] NOT NULL,
	[clp_in_ativo] [bit] NOT NULL,
	[clp_in_excluido] [bit] NOT NULL,
	[clp_cd_cte_item] [uniqueidentifier] NULL,
 CONSTRAINT [pk_cte_lotes_pacotes] PRIMARY KEY CLUSTERED 
(
	[clp_cd_lote_pacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
