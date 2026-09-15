-- ============================================================
-- BASELINE: dbo.hawk_basefretemotorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[hawk_basefretemotorista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hawk_basefretemotorista](
	[tipo de contrato] [varchar](max) NULL,
	[service center] [varchar](max) NULL,
	[cidade] [float] NULL,
	[tipo de veículo] [varchar](max) NULL,
	[início da faixa] [bigint] NULL,
	[fim da faixa] [bigint] NULL,
	[valor do frete am] [float] NULL,
	[valor do frete pm] [float] NULL,
	[valor do frete fixo] [float] NULL,
	[valor do frete sd (semi day)] [float] NULL,
	[valor fixo domingo/feriado] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
