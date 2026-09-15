-- ============================================================
-- BASELINE: dbo.decargo_veiculos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[decargo_veiculos]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[decargo_veiculos](
	[placa] [varchar](max) NULL,
	[base] [varchar](max) NULL,
	[tipo principal] [varchar](max) NULL,
	[tipo frota] [varchar](max) NULL,
	[valor fixo] [bigint] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
