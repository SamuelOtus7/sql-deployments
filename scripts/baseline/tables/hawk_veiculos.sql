-- ============================================================
-- BASELINE: dbo.hawk_veiculos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[hawk_veiculos]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hawk_veiculos](
	[placa] [varchar](max) NULL,
	[frota] [varchar](max) NULL,
	[base] [varchar](max) NULL,
	[modelo] [varchar](max) NULL,
	[renavam] [varchar](max) NULL,
	[ano fabricação] [float] NULL,
	[ano modelo] [float] NULL,
	[marca] [varchar](max) NULL,
	[chassi] [varchar](max) NULL,
	[cor] [varchar](max) NULL,
	[estado] [varchar](max) NULL,
	[combustível] [varchar](max) NULL,
	[modal] [varchar](max) NULL,
	[obs] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
