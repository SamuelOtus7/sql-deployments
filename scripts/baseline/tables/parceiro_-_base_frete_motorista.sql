-- ============================================================
-- BASELINE: dbo.parceiro_-_base_frete_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[parceiro_-_base_frete_motorista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[parceiro_-_base_frete_motorista](
	[unnamed: 0] [float] NULL,
	[service center] [varchar](max) NULL,
	[cidade] [float] NULL,
	[tipo de veículo] [bigint] NULL,
	[início da faixa] [bigint] NULL,
	[fim da faixa] [bigint] NULL,
	[valor do frete] [bigint] NULL,
	[valor do frete pm] [bigint] NULL,
	[valor do frete fixo] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
