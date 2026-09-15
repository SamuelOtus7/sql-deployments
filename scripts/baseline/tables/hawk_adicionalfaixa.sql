-- ============================================================
-- BASELINE: dbo.hawk_adicionalfaixa
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[hawk_adicionalfaixa]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hawk_adicionalfaixa](
	[tipo de contrato] [varchar](max) NULL,
	[service center] [varchar](max) NULL,
	[tipo de veículo] [varchar](max) NULL,
	[cidade] [float] NULL,
	[tipo faixa 1] [varchar](max) NULL,
	[faixa inicio] [bigint] NULL,
	[faixa fim] [bigint] NULL,
	[tipo faixa 2] [float] NULL,
	[faixa inicio.1] [float] NULL,
	[faixa fim.1] [float] NULL,
	[valor bonus + dif da diária] [bigint] NULL,
	[dia] [varchar](max) NULL,
	[tipo valor] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
