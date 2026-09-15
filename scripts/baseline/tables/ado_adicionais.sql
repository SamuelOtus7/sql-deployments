-- ============================================================
-- BASELINE: dbo.ado_adicionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[ado_adicionais]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ado_adicionais](
	[tipo de contrato] [varchar](max) NULL,
	[service center] [varchar](max) NULL,
	[cidade] [float] NULL,
	[tipo_veiculo] [varchar](max) NULL,
	[tipo adicional domingo] [varchar](max) NULL,
	[valor adicional domingo] [bigint] NULL,
	[tipo adicional ciclo pm] [varchar](max) NULL,
	[valor adicional ciclo] [bigint] NULL,
	[tipo adicional ajudante] [varchar](max) NULL,
	[valor adicional ajudante] [bigint] NULL,
	[tipo adicional risco] [varchar](max) NULL,
	[valor adicional risco] [bigint] NULL,
	[valor adicional pool] [bigint] NULL,
	[valor adicional 0-60] [float] NULL,
	[valor adicional 61-75] [float] NULL,
	[valor adicional 76-85] [float] NULL,
	[valor adicional 86-90] [float] NULL,
	[valor adicional acima de 90] [float] NULL,
	[tipo de adicional itens] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
