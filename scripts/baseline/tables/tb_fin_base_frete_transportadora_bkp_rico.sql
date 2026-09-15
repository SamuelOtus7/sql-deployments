-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_transportadora_bkp_rico
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_transportadora_bkp_rico]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_transportadora_bkp_rico](
	[bft_cd_transportadora] [int] NOT NULL,
	[bft_cd_service_center] [varchar](100) NULL,
	[bft_estado] [varchar](2) NULL,
	[bft_cd_tipo_veiculo] [int] NOT NULL,
	[bft_vl_inicio_faixa] [int] NULL,
	[bft_vl_fim_faixa] [int] NULL,
	[bft_vl_frete] [decimal](7, 2) NULL,
	[bft_cd_codigo_cliente] [int] NULL,
	[bft_data_inicio] [date] NULL,
	[bft_data_fim] [date] NULL,
	[bft_nm_cidade] [varchar](150) NULL,
	[bft_vl_frete_pm] [decimal](7, 2) NULL,
	[bft_cd_operacao] [int] NOT NULL,
	[bft_cd_tipo_calculo] [int] NULL,
	[bft_vl_insucesso] [decimal](7, 2) NULL,
	[bft_vl_frete_dom] [decimal](7, 2) NULL,
	[bft_vl_frete_pm_dom] [decimal](7, 2) NULL
) ON [PRIMARY]
GO
