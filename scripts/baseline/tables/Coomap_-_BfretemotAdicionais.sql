-- ============================================================
-- BASELINE: dbo.Coomap_-_BfretemotAdicionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Coomap_-_BfretemotAdicionais]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Coomap_-_BfretemotAdicionais](
	[Tipo de contrato] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Faixa de KM] [bigint] NULL,
	[Faixa de KM.1] [bigint] NULL,
	[Tipo de veículo] [bigint] NULL,
	[Tipo adicional domingo] [bigint] NULL,
	[Valor adicional domingo] [float] NULL,
	[Tipo adicional ciclo PM] [bigint] NULL,
	[Valor adicional ciclo] [bigint] NULL,
	[Tipo adicional ajudante] [bigint] NULL,
	[Valor adicional ajudante] [bigint] NULL,
	[Tipo adicional risco] [bigint] NULL,
	[Valor adicional risco] [bigint] NULL,
	[Valor adicional pool] [bigint] NULL,
	[Valor adicional 0-60] [float] NULL,
	[Valor adicional 61-90] [float] NULL,
	[Valor adicional acima de 90] [float] NULL,
	[Tipo de adicional itens] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
