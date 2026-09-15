-- ============================================================
-- BASELINE: dbo.Decargo_-_BFreteMotorista2
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Decargo_-_BFreteMotorista2]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Decargo_-_BFreteMotorista2](
	[Tipo de contrato] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Cidade] [float] NULL,
	[Tipo de veículo] [bigint] NULL,
	[Início da Faixa] [bigint] NULL,
	[Fim da Faixa] [bigint] NULL,
	[Valor do Frete] [varchar](max) NULL,
	[Valor do frete PM] [varchar](max) NULL,
	[Valor do Frete Fixo] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
