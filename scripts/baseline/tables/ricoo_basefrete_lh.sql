-- ============================================================
-- BASELINE: dbo.ricoo_basefrete_lh
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[ricoo_basefrete_lh]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ricoo_basefrete_lh](
	[bfm_cd_base_frete_motorista] [int] IDENTITY(1,1) NOT NULL,
	[bfm_cd_transportadora] [int] NOT NULL,
	[bfm_cd_service_center] [varchar](50) NULL,
	[bfm_nm_cidade] [varchar](150) NULL,
	[bfm_cd_tipo_veiculo] [int] NOT NULL,
	[bfm_vl_inicio_faixa] [int] NOT NULL,
	[bfm_vl_fim_faixa] [int] NOT NULL,
	[bfm_vl_frete] [decimal](7, 2) NULL,
	[bfm_vl_frete_pm] [decimal](7, 2) NULL,
	[bfm_vl_frete_fixo] [decimal](7, 2) NULL,
	[bmf_cd_tipo_contrato] [int] NULL,
	[bfm_cd_codigo_cliente] [int] NULL,
	[bfm_vl_domfer_am] [decimal](10, 2) NULL,
	[bfm_vl_domfer_pm] [decimal](10, 2) NULL,
	[bfm_data_inicio_vigencia] [date] NOT NULL,
	[bfm_data_fim_vigencia] [date] NULL,
	[bfm_nm_regiao] [varchar](150) NULL,
	[bfm_cd_operacao] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL,
	[bfm_pag_pacote] [int] NULL,
	[bfm_cd_sla] [int] NULL,
	[bfm_pag_sla] [bit] NULL,
	[bfm_nm_regra_calculo] [varchar](50) NULL,
	[bfm_vl_valor_SLA_perdido] [decimal](7, 2) NULL,
	[bfm_numero_po] [varchar](50) NULL,
	[bfm_cd_pagar_por_pacotes] [int] NULL,
	[bfm_vl_frete_sd] [decimal](5, 2) NULL
) ON [PRIMARY]
GO
