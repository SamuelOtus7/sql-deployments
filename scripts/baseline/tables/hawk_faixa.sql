-- ============================================================
-- BASELINE: dbo.hawk_faixa
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[hawk_faixa]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hawk_faixa](
	[tipo_contrato] [varchar](max) NULL,
	[service_center] [varchar](max) NULL,
	[cidade] [varchar](max) NULL,
	[tipo_veiculo] [varchar](max) NULL,
	[faixa_1] [float] NULL,
	[faixa_2] [float] NULL,
	[valor] [float] NULL,
	[faixa_2.1] [float] NULL,
	[faixa_2.2] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [float] NULL,
	[bfa_cd_base_frete_adicional_motorista] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
