-- ============================================================
-- BASELINE: dbo.Hawk_-_BaseFreteMotorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Hawk_-_BaseFreteMotorista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hawk_-_BaseFreteMotorista](
	[Tipo de contrato] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Cidade] [float] NULL,
	[Tipo de veículo] [float] NULL,
	[Início da Faixa] [bigint] NULL,
	[Fim da Faixa] [bigint] NULL,
	[Valor do Frete AM] [bigint] NULL,
	[Valor do frete PM] [bigint] NULL,
	[Valor do Frete Fixo] [float] NULL,
	[Valor do frete SD (semi day)] [float] NULL,
	[Valor fixo DOMINGO/FERIADO] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
