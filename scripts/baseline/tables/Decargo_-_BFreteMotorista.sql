-- ============================================================
-- BASELINE: dbo.Decargo_-_BFreteMotorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Decargo_-_BFreteMotorista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Decargo_-_BFreteMotorista](
	[Tipo de contrato] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Cidade] [varchar](max) NULL,
	[Tipo de veículo] [bigint] NULL,
	[Início da Faixa] [bigint] NULL,
	[Fim da Faixa] [bigint] NULL,
	[Valor do Frete] [bigint] NULL,
	[Valor do frete PM] [varchar](max) NULL,
	[Valor do Frete Fixo] [bigint] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [varchar](max) NULL,
	[cd_operacao] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
