-- ============================================================
-- BASELINE: dbo.JMT_-_BFrete_MotAdic
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[JMT_-_BFrete_MotAdic]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JMT_-_BFrete_MotAdic](
	[Tipo de contrato] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Cidade] [varchar](max) NULL,
	[Tipo de veículo] [bigint] NULL,
	[Tipo adicional domingo] [bigint] NULL,
	[Valor adicional domingo] [bigint] NULL,
	[Tipo adicional ciclo PM] [bigint] NULL,
	[Valor adicional ciclo] [bigint] NULL,
	[Tipo adicional ajudante] [bigint] NULL,
	[Valor adicional ajudante] [bigint] NULL,
	[Tipo adicional risco] [bigint] NULL,
	[Valor adicional risco] [float] NULL,
	[Valor adicional pool] [bigint] NULL,
	[Valor adicional 0-50] [bigint] NULL,
	[Valor adicional 51-80] [bigint] NULL,
	[Valor adicional 76-85] [bigint] NULL,
	[Valor adicional 86-90] [bigint] NULL,
	[Valor adicional acima de 90] [bigint] NULL,
	[Tipo de adicional itens] [varchar](max) NULL,
	[Tipo de adicional pacotes] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
