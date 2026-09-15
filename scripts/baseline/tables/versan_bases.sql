-- ============================================================
-- BASELINE: dbo.versan_bases
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[versan_bases]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[versan_bases](
	[s] [varchar](max) NULL,
	[sigla] [varchar](max) NULL,
	[nome] [varchar](max) NULL,
	[nome amigável] [varchar](max) NULL,
	[regiao] [varchar](max) NULL,
	[cidade] [varchar](max) NULL,
	[estado] [varchar](max) NULL,
	[endereco] [varchar](max) NULL,
	[latitude] [float] NULL,
	[longitude] [float] NULL,
	[xpt] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
