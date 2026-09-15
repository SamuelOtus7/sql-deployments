-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_motorista_stg
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_motorista_stg]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_motorista_stg](
	[bfm_cd_transportadora] [int] NOT NULL,
	[bfm_cd_service_center] [varchar](50) NULL,
	[bfm_nm_cidade] [varchar](150) NULL,
	[bfm_cd_tipo_veiculo] [varchar](150) NOT NULL,
	[bfm_vl_inicio_faixa] [int] NULL,
	[bfm_vl_fim_faixa] [int] NULL,
	[bfm_vl_frete] [decimal](7, 2) NULL,
	[bfm_vl_frete_pm] [decimal](7, 2) NULL,
	[bfm_vl_frete_fixo] [decimal](7, 2) NULL,
	[bmf_cd_tipo_contrato] [int] NULL,
	[bfm_vl_domfer_am] [decimal](10, 2) NULL,
	[bfm_vl_domfer_pm] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
