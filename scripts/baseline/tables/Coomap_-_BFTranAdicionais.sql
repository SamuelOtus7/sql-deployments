-- ============================================================
-- BASELINE: dbo.Coomap_-_BFTranAdicionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Coomap_-_BFTranAdicionais]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Coomap_-_BFTranAdicionais](
	[Service Center] [varchar](max) NULL,
	[Faixa de KM inicio] [bigint] NULL,
	[Faixa de KM Fim] [bigint] NULL,
	[Tipo de veículo] [bigint] NULL,
	[Tipo adicional domingo] [bigint] NULL,
	[Valor adicional domingo] [float] NULL,
	[Tipo adicional ciclo PM] [bigint] NULL,
	[Valor adicional ciclo] [float] NULL,
	[Tipo adicional ajudante] [float] NULL,
	[Valor adicional ajudante] [bigint] NULL,
	[Tipo adicional risco] [float] NULL,
	[Valor adicional risco] [float] NULL,
	[Valor adicional 0-60] [float] NULL,
	[Valor adicional 61-90] [float] NULL,
	[Valor adicional acima de 90] [float] NULL,
	[Tipo de adicional itens] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
