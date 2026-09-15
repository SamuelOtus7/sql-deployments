-- ============================================================
-- BASELINE: dbo.Ontime_-_BFreteTransp
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Ontime_-_BFreteTransp]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ontime_-_BFreteTransp](
	[Service Center] [varchar](max) NULL,
	[Estado] [varchar](max) NULL,
	[Tipo de veículo] [bigint] NULL,
	[Início da Faixa] [bigint] NULL,
	[Fim da Faixa] [bigint] NULL,
	[Valor do Frete] [bigint] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
