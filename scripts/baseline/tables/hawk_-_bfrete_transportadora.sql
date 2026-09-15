-- ============================================================
-- BASELINE: dbo.hawk_-_bfrete_transportadora
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[hawk_-_bfrete_transportadora]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hawk_-_bfrete_transportadora](
	[service center] [varchar](max) NULL,
	[estado] [float] NULL,
	[tipo de veículo] [float] NULL,
	[início da faixa] [bigint] NULL,
	[fim da faixa] [bigint] NULL,
	[valor do frete am] [bigint] NULL,
	[valor do frete pm] [float] NULL,
	[valor domingo/feriado am] [float] NULL,
	[valor domingo/feriado pm] [float] NULL,
	[obs] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
