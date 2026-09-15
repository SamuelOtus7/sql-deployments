-- ============================================================
-- BASELINE: dbo.jmt_-_bfretetrans
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[jmt_-_bfretetrans]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[jmt_-_bfretetrans](
	[service center] [varchar](max) NULL,
	[estado] [varchar](max) NULL,
	[tipo de veículo] [bigint] NULL,
	[início da faixa] [bigint] NULL,
	[fim da faixa] [bigint] NULL,
	[valor do frete] [bigint] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
