-- ============================================================
-- BASELINE: dbo.tb_clientes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_clientes]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_clientes](
	[cli_cd_codigo_cliente] [int] IDENTITY(1,1) NOT NULL,
	[cli_ds_nome] [varchar](50) NOT NULL,
	[cli_ds_descricao] [varchar](max) NULL,
	[cli_ds_banco_dados] [varchar](100) NULL,
	[cli_ds_alias] [varchar](100) NULL,
	[cli_in_ativo] [bit] NOT NULL,
	[cli_in_excluido] [bit] NOT NULL,
	[cli_dh_criacao] [datetime] NOT NULL,
	[cli_cd_usr_criacao] [int] NOT NULL,
	[cli_dh_modificacao] [datetime] NOT NULL,
	[cli_cd_usr_modificacao] [int] NOT NULL,
	[cli_id_logistics] [int] NOT NULL,
	[cli_id_shopee] [int] NOT NULL,
	[cli_dt_ini_geo] [date] NULL,
	[cli_nm_shopee] [varchar](50) NULL,
	[cli_ds_chave_app] [varchar](150) NOT NULL,
	[cli_in_app_documentos] [bit] NOT NULL,
	[cli_push_sender] [varchar](100) NULL,
	[cli_push_authorization] [varchar](300) NULL,
	[cli_dt_ini_ml] [date] NULL,
	[cli_nm_versao_spe] [tinyint] NULL,
	[cli_ds_cor_primaria] [varchar](100) NULL,
	[cli_ds_cor_secundaria] [varchar](100) NULL,
	[cli_ds_logo_path] [varchar](2000) NULL,
	[cli_in_cod_arquivo_logo] [int] NULL,
	[cli_ds_logo_header_path] [varchar](2000) NULL,
	[cli_in_cod_arquivo_logo_header] [int] NULL,
	[cli_ds_sub_dominio] [varchar](30) NULL,
	[cli_cd_id_cloudflare] [varchar](255) NULL,
	[cli_ds_logo_banner_home] [varchar](2000) NULL,
	[cli_cd_logo_banner_home] [int] NULL,
	[cli_ds_cnpj] [varchar](25) NULL,
	[cli_ds_email] [varchar](200) NULL,
	[cli_ds_telefone] [varchar](20) NULL,
	[cli_ativo_financeiro] [int] NULL,
	[cli_ds_token_wp] [varchar](255) NULL,
	[cli_ds_logo_report] [varchar](2000) NULL,
	[cli_agency_shpee] [int] NULL,
	[TokenAPIMonitor] [uniqueidentifier] NULL,
	[cli_agency_shopee_2] [int] NULL,
	[cli_ds_servico_wp] [varchar](30) NULL,
	[cli_in_cte_auto_spe] [bit] NULL,
	[cli_agency_shopee_3] [int] NULL,
	[cli_agency_shopee_4] [int] NULL,
	[cli_agency_Shopee_5] [int] NULL,
	[cli_ds_logo_relatorio_wpp_path] [varchar](400) NULL,
	[cli_in_cod_arquivo_logo_relatorio_wpp] [int] NULL,
 CONSTRAINT [pk_clientes] PRIMARY KEY CLUSTERED 
(
	[cli_cd_codigo_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_cli_ds_nome] UNIQUE NONCLUSTERED 
(
	[cli_ds_nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
