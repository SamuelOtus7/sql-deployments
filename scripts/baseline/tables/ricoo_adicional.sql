-- ============================================================
-- BASELINE: dbo.ricoo_adicional
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[ricoo_adicional]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ricoo_adicional](
	[operação] [varchar](max) NULL,
	[tipo de contrato] [varchar](max) NULL,
	[service center] [varchar](max) NULL,
	[cidade] [varchar](max) NULL,
	[tipo de veículo] [varchar](max) NULL,
	[tipo de adicional] [varchar](max) NULL,
	[adicional de balsa / pedágios] [bigint] NULL,
	[tipo adicional domingo] [bigint] NULL,
	[valor adicional domingo] [bigint] NULL,
	[tipo adicional ciclo pm] [bigint] NULL,
	[valor adicional ciclo] [bigint] NULL,
	[tipo adicional ajudante] [bigint] NULL,
	[valor adicional ajudante] [bigint] NULL,
	[tipo adicional risco] [bigint] NULL,
	[valor adicional risco] [bigint] NULL,
	[valor adicional pool] [bigint] NULL,
	[valor adicional 0-60] [bigint] NULL,
	[valor adicional 61-75] [bigint] NULL,
	[valor adicional 76-85] [bigint] NULL,
	[valor adicional 86-90] [bigint] NULL,
	[valor adicional acima de 90] [bigint] NULL,
	[tipo de adicional itens] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
