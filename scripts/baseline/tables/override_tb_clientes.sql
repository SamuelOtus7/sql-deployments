-- ============================================================
-- BASELINE: dbo.override_tb_clientes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[override_tb_clientes]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[override_tb_clientes](
	[cli_cd_codigo_cliente] [int] IDENTITY(1,1) NOT NULL,
	[cli_ds_nome] [nvarchar](max) NULL,
	[cli_ds_descricao] [nvarchar](max) NULL,
	[cli_ds_banco_dados] [nvarchar](max) NULL,
	[cli_ds_alias] [nvarchar](max) NULL,
	[cli_in_ativo] [bit] NOT NULL,
	[cli_in_excluido] [bit] NOT NULL,
	[cli_dh_criacao] [datetime] NOT NULL,
	[cli_cd_usr_criacao] [int] NOT NULL,
	[cli_dh_modificacao] [datetime] NOT NULL,
	[cli_cd_usr_modificacao] [int] NOT NULL,
	[cli_id_logistics] [int] NOT NULL,
	[cli_id_shopee] [int] NOT NULL,
	[cli_dt_ini_geo] [datetime] NULL,
	[cli_nm_shopee] [nvarchar](max) NULL,
	[cli_ds_chave_app] [nvarchar](max) NULL,
	[cli_in_app_documentos] [bit] NOT NULL,
	[cli_push_sender] [nvarchar](max) NULL,
	[cli_push_authorization] [nvarchar](max) NULL,
	[cli_dt_ini_ml] [datetime] NULL,
	[cli_nm_versao_spe] [tinyint] NULL,
	[cli_ds_cor_primaria] [nvarchar](max) NULL,
	[cli_ds_cor_secundaria] [nvarchar](max) NULL,
	[cli_ds_logo_path] [nvarchar](max) NULL,
	[cli_in_cod_arquivo_logo] [int] NULL,
	[cli_ds_logo_header_path] [nvarchar](max) NULL,
	[cli_in_cod_arquivo_logo_header] [int] NULL,
	[cli_ds_sub_dominio] [nvarchar](max) NULL,
	[cli_cd_id_cloudflare] [nvarchar](max) NULL,
	[cli_ds_logo_banner_home] [nvarchar](max) NULL,
	[cli_cd_logo_banner_home] [int] NULL,
	[cli_ds_cnpj] [nvarchar](max) NULL,
	[cli_ds_email] [nvarchar](max) NULL,
	[cli_ds_telefone] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.override_tb_clientes] PRIMARY KEY CLUSTERED 
(
	[cli_cd_codigo_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
