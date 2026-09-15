-- ============================================================
-- BASELINE: dbo.Decargo_-_BFreteAdicionaisMot
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Decargo_-_BFreteAdicionaisMot]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Decargo_-_BFreteAdicionaisMot](
	[Tipo de contrato] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Cidade] [varchar](max) NULL,
	[Tipo de veículo] [bigint] NULL,
	[Tipo adicional domingo] [bigint] NULL,
	[Valor adicional domingo/feriados nacionais] [bigint] NULL,
	[Tipo adicional ciclo PM] [float] NULL,
	[Valor adicional ciclo] [float] NULL,
	[Tipo adicional ajudante] [float] NULL,
	[Valor adicional ajudante] [float] NULL,
	[Tipo adicional risco] [float] NULL,
	[Valor adicional risco] [float] NULL,
	[Valor adicional pool] [float] NULL,
	[Valor adicional 0-60] [float] NULL,
	[Valor adicional 61-90] [float] NULL,
	[Valor adicional 90-999] [float] NULL,
	[Valor adicional 86-90] [float] NULL,
	[Valor adicional acima de 90] [float] NULL,
	[Tipo de adicional itens] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [varchar](max) NULL,
	[cd_operacao] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
