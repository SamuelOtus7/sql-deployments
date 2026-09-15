-- ============================================================
-- BASELINE: dbo.parceiro_-_btransadicionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[parceiro_-_btransadicionais]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[parceiro_-_btransadicionais](
	[service center] [varchar](max) NULL,
	[estado] [varchar](max) NULL,
	[tipo de veículo] [bigint] NULL,
	[tipo adicional domingo] [bigint] NULL,
	[valor adicional domingo] [bigint] NULL,
	[tipo adicional ciclo pm] [bigint] NULL,
	[valor adicional ciclo] [float] NULL,
	[tipo adicional ajudante] [float] NULL,
	[valor adicional ajudante] [float] NULL,
	[tipo adicional risco] [float] NULL,
	[valor adicional risco] [float] NULL,
	[valor adicional 0-60] [float] NULL,
	[valor adicional 61-90] [float] NULL,
	[valor adicional acima de 90] [float] NULL,
	[tipo de adicional itens] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
