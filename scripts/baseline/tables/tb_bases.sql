-- ============================================================
-- BASELINE: dbo.tb_bases
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_bases]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_bases](
	[bss_cd_base] [int] IDENTITY(1,1) NOT NULL,
	[bss_ds_marketplace] [nvarchar](255) NOT NULL,
	[bss_cd_idtransportadora] [int] NULL,
	[bss_ds_sigla] [nvarchar](50) NOT NULL,
	[bss_ds_nome] [nvarchar](255) NOT NULL,
	[bss_ds_nome_amigavel] [nvarchar](255) NULL,
	[bss_ds_regiao] [nvarchar](200) NULL,
	[bss_ds_cidade] [nvarchar](100) NULL,
	[bss_ds_estado] [nvarchar](50) NULL,
	[bss_ds_endereco] [nvarchar](255) NULL,
	[bss_dc_latitude] [decimal](22, 15) NOT NULL,
	[bss_dc_longitude] [decimal](22, 15) NOT NULL,
	[bss_in_xpt] [bit] NOT NULL,
	[bss_in_status] [bit] NOT NULL,
	[bss_in_excluido] [bit] NOT NULL,
	[bss_cd_usuario_criacao] [int] NOT NULL,
	[bss_dh_criacao] [datetime] NOT NULL,
	[bss_cd_usuario_modificacao] [int] NOT NULL,
	[bss_dh_modificacao] [datetime] NOT NULL,
	[bss_cod_cliente] [int] NULL,
	[bss_ds_label]  AS (case when [bss_ds_nome]=[bss_ds_sigla] then [bss_ds_sigla] else ([bss_ds_sigla]+' - ')+[bss_ds_nome] end) PERSISTED NOT NULL,
	[bss_ds_chave_report]  AS (case when [bss_ds_marketplace]='Shopee' then [bss_ds_nome] else [bss_ds_sigla] end) PERSISTED NOT NULL,
	[bss_ds_regiao_app] [varchar](255) NULL,
	[bss_ds_regiao_app_desc] [varchar](100) NULL,
	[bss_ds_regiao_app_ordenar_grupo] [int] NULL,
	[bss_ds_cpf_cnpj] [varchar](25) NULL,
	[bss_ds_nome_fantasia] [varchar](150) NULL,
	[bss_ds_razao_social] [varchar](150) NULL,
	[bss_cd_municipio_ibge] [varchar](100) NULL,
	[bss_ds_email] [varchar](100) NULL,
	[bss_ds_cep] [varchar](20) NULL,
	[bss_cd_status_integracao_target] [int] NULL,
	[bss_cd_participante_integracao_target] [int] NULL,
	[bss_cd_rota_integracao_target] [int] NULL,
	[bss_ds_cep_intermediario] [varchar](20) NULL,
	[bss_ds_endereco_intermediario] [varchar](255) NULL,
	[bss_ds_regiao_intermediario] [varchar](255) NULL,
	[bss_ds_estado_intermediario] [varchar](100) NULL,
	[bss_ds_cidade_intermediario] [varchar](150) NULL,
	[bss_cd_municipio_ibge_intermediario] [varchar](100) NULL,
	[bss_ds_latitude_intermediario] [decimal](18, 11) NULL,
	[bss_ds_longitude_intermediario] [decimal](18, 11) NULL,
	[bss_in_base_intermediaria] [bit] NULL,
	[bss_origem_base] [varchar](5) NULL,
	[bss_in_ambulancia] [int] NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[bss_espelho_xpt] [int] NULL,
	[bss_visibilidade] [bit] NULL,
	[bss_regra_sd] [tinyint] NULL,
	[bss_regra_ciclo] [int] NULL,
	[bss_cd_base_fm_vinculada] [int] NULL,
	[bss_in_fm_esta_base_origem] [bit] NULL,
 CONSTRAINT [PK__tb_bases__C0A637E2AA5886A1] PRIMARY KEY CLUSTERED 
(
	[bss_cd_base] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_trans_sigla] UNIQUE NONCLUSTERED 
(
	[bss_cd_idtransportadora] ASC,
	[bss_ds_sigla] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_bases1] UNIQUE NONCLUSTERED 
(
	[bss_cd_idtransportadora] ASC,
	[bss_ds_sigla] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_bases_hist])
)
GO
