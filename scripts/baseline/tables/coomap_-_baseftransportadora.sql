-- ============================================================
-- BASELINE: dbo.coomap_-_baseftransportadora
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[coomap_-_baseftransportadora]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[coomap_-_baseftransportadora](
	[service center] [varchar](max) NULL,
	[estado] [varchar](max) NULL,
	[tipo de veículo] [float] NULL,
	[início da faixa] [float] NULL,
	[fim da faixa] [float] NULL,
	[valor do frete] [float] NULL,
	[valor do frete pm] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
