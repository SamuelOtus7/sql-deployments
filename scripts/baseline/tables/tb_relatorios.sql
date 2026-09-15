-- ============================================================
-- BASELINE: dbo.tb_relatorios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_relatorios]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_relatorios](
	[rel_cd_relatorio] [int] IDENTITY(1,1) NOT NULL,
	[rel_ds_nome] [varchar](50) NOT NULL,
	[rel_ds_caminho] [varchar](max) NULL,
	[rel_cd_controller] [smallint] NOT NULL,
	[rel_ds_autorefresh] [varchar](max) NULL,
	[rel_in_ativo] [bit] NOT NULL,
	[rel_dh_criacao] [datetime] NOT NULL,
	[rel_cd_usr_criacao] [int] NOT NULL,
	[rel_dh_modificacao] [datetime] NOT NULL,
	[rel_cd_usr_modificacao] [int] NOT NULL,
	[rel_ds_desativado] [varchar](max) NULL,
	[rel_in_desativado] [bit] NULL,
	[rel_ds_paginacao] [varchar](50) NULL,
	[rel_in_power_bi] [bit] NULL,
	[rel_ds_diretorio] [varchar](255) NULL,
	[rel_in_visibilidade_painel_bi] [bit] NULL,
	[rel_ds_tipo_relatorio] [varchar](50) NULL,
	[rel_ds_json] [varchar](max) NULL,
	[rel_cd_cod_cliente] [int] NULL,
	[rel_ds_marketplace] [nvarchar](50) NULL,
 CONSTRAINT [pk_tb_relatorios] PRIMARY KEY CLUSTERED 
(
	[rel_cd_relatorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
