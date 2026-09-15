-- ============================================================
-- BASELINE: dbo.tb_empresas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_empresas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_empresas](
	[emp_cd_codigo_empresa] [int] IDENTITY(1,1) NOT NULL,
	[emp_ds_cnpj] [varchar](25) NOT NULL,
	[emp_ds_nome] [varchar](300) NOT NULL,
	[emp_ds_fantasia] [varchar](300) NULL,
	[emp_ds_ie] [varchar](15) NULL,
	[emp_ds_iest] [varchar](20) NULL,
	[emp_ds_regime_trib] [varchar](300) NULL,
	[emp_ds_end_cep] [varchar](25) NULL,
	[emp_ds_end_logradouro] [varchar](200) NULL,
	[emp_ds_end_numero] [nvarchar](20) NOT NULL,
	[emp_ds_end_compl] [varchar](60) NULL,
	[emp_ds_end_bairro] [varchar](200) NULL,
	[emp_ds_end_cidade] [varchar](200) NULL,
	[emp_cd_end_cod_cidade] [int] NULL,
	[emp_ds_end_uf] [varchar](2) NULL,
	[emp_ds_usr_api_shopee] [varchar](200) NULL,
	[emp_ds_senha_api_shopee] [varchar](200) NULL,
	[emp_cd_amb_sefaz] [int] NULL,
	[emp_cd_cert_digital] [int] NULL,
	[emp_ds_cert_digital] [nvarchar](2000) NULL,
	[emp_ds_senha_cert_digital] [varchar](200) NULL,
	[emp_cd_usr_criacao] [int] NOT NULL,
	[emp_dh_criacao] [datetime] NOT NULL,
	[emp_cd_usr_modificacao] [int] NOT NULL,
	[emp_dh_modificacao] [datetime] NOT NULL,
	[emp_in_ativo] [bit] NOT NULL,
	[emp_in_excluido] [bit] NOT NULL,
	[emp_cd_codigo_cliente] [int] NOT NULL,
	[emp_cd_modo_operacao] [int] NULL,
	[emp_ds_usr_api_meli] [varchar](200) NULL,
	[emp_ds_senha_api_meli] [varchar](200) NULL,
	[emp_nr_rntrc] [int] NULL,
	[emp_in_emissao_cte] [bit] NULL,
	[emp_integracao_nfse] [bit] NULL,
	[emp_ds_chave_pix] [varchar](250) NULL,
	[emp_ds_usr_api_averbacao_cte] [varchar](50) NULL,
	[emp_ds_senha_api_averbacao_cte] [varchar](50) NULL,
	[emp_cd_atm_api_averbacao_cte] [varchar](20) NULL,
	[emp_in_matriz] [bit] NOT NULL,
 CONSTRAINT [pk_empresas] PRIMARY KEY CLUSTERED 
(
	[emp_cd_codigo_empresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
