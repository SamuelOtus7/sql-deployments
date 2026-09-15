-- ============================================================
-- BASELINE: dbo.decargo_basefrete
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[decargo_basefrete]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[decargo_basefrete](
	[service center] [varchar](max) NULL,
	[estado] [varchar](max) NULL,
	[tipo de veículo] [varchar](max) NULL,
	[início da faixa] [float] NULL,
	[fim da faixa] [float] NULL,
	[valor do frete] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
