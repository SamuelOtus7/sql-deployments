-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_motorista_bravox
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_motorista_bravox]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_motorista_bravox](
	[bfm_cd_frete_motorista_bravox] [int] IDENTITY(1,1) NOT NULL,
	[bfm_cd_transportadora] [int] NOT NULL,
	[bfm_cd_service_center] [varchar](50) NULL,
	[bfm_nm_cidade] [varchar](2) NULL,
	[bfm_cd_tipo_veiculo] [int] NOT NULL,
	[bfm_vl_inicio_faixa] [int] NULL,
	[bfm_vl_fim_faixa] [int] NULL,
	[bfm_vl_frete] [decimal](7, 2) NULL,
	[bfm_vl_frete_pm] [decimal](7, 2) NULL,
	[bfm_cd_prazo] [varchar](150) NULL,
	[bfm_vl_frete_fixo] [int] NULL,
	[bmf_cd_tipo_contrato] [int] NULL,
	[bfm_tipo_motorista] [varchar](15) NULL,
 CONSTRAINT [UQ_base_frete_motorista_bravox] UNIQUE NONCLUSTERED 
(
	[bfm_cd_transportadora] ASC,
	[bfm_cd_service_center] ASC,
	[bfm_nm_cidade] ASC,
	[bfm_cd_tipo_veiculo] ASC,
	[bfm_vl_inicio_faixa] ASC,
	[bfm_vl_fim_faixa] ASC,
	[bfm_tipo_motorista] ASC,
	[bfm_cd_prazo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
