-- ============================================================
-- BASELINE: dbo.tb_pag_espelhos_nfse
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_espelhos_nfse]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_espelhos_nfse](
	[enf_cd_espelho_nfse] [int] IDENTITY(1,1) NOT NULL,
	[enf_cd_espelho] [int] NOT NULL,
	[enf_ds_link_xml] [varchar](max) NULL,
	[enf_ds_chave_nfse] [varchar](150) NULL,
	[enf_ds_cnpj_emitente] [varchar](14) NULL,
	[enf_dh_emissao] [datetime] NULL,
	[enf_cnpj_tomador] [varchar](14) NULL,
	[enf_ds_situacao] [varchar](30) NULL,
	[enf_vl_nota] [decimal](18, 8) NULL,
	[enf_dh_processamento] [datetime] NOT NULL,
	[enf_ds_resultado] [varchar](250) NOT NULL,
	[enf_qt_tentativas] [smallint] NOT NULL,
	[enf_cd_servico] [varchar](30) NULL,
	[enf_cd_municipio_toma] [varchar](500) NULL,
	[enf_cep_toma] [varchar](10) NULL,
	[end_im_toma] [varchar](50) NULL,
	[enf_ds_observacao] [varchar](2000) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[enf_ds_toma_bairro] [varchar](250) NULL,
	[enf_ds_toma_logradouro] [varchar](250) NULL,
	[enf_ds_toma_numero] [varchar](20) NULL,
	[enf_ds_emit_municipio] [varchar](250) NULL,
	[enf_ds_emit_CEP] [varchar](10) NULL,
	[enf_ds_emit_bairro] [varchar](250) NULL,
	[enf_ds_emit_logradouro] [varchar](250) NULL,
	[enf_ds_emit_numero] [varchar](20) NULL,
	[enf_nr_nfse] [int] NULL,
	[enf_status_integracao] [int] NULL,
 CONSTRAINT [pk_pag_espelhos_nfse] PRIMARY KEY CLUSTERED 
(
	[enf_cd_espelho_nfse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_pag_espelhos_nfse] UNIQUE NONCLUSTERED 
(
	[enf_cd_espelho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_pag_espelhos_nfse_hist])
)
GO
