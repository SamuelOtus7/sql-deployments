-- ============================================================
-- BASELINE: dbo.ricoo_base_lh
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[ricoo_base_lh]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ricoo_base_lh](
	[operação] [varchar](max) NULL,
	[tipo de contrato] [varchar](max) NULL,
	[service center] [varchar](max) NULL,
	[cidade] [varchar](max) NULL,
	[estado] [varchar](max) NULL,
	[tipo de veículo] [varchar](max) NULL,
	[início da faixa] [bigint] NULL,
	[fim da faixa] [bigint] NULL,
	[valor do frete] [float] NULL,
	[valor do frete pm] [float] NULL,
	[valor do frete fixo] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
