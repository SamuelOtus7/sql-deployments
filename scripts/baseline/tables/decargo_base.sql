-- ============================================================
-- BASELINE: dbo.decargo_base
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[decargo_base]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[decargo_base](
	[tipo_contrato] [varchar](max) NULL,
	[service_center] [varchar](max) NULL,
	[cidade] [float] NULL,
	[tipo_veiculo] [varchar](max) NULL,
	[inicio_faixa] [bigint] NULL,
	[fim_faixa] [bigint] NULL,
	[valor_frete] [bigint] NULL,
	[valor_frete_pm] [float] NULL,
	[valor_frete_fixo] [bigint] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
