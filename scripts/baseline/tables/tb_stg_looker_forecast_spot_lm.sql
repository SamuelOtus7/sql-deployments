-- ============================================================
-- BASELINE: dbo.tb_stg_looker_forecast_spot_lm
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_forecast_spot_lm]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_forecast_spot_lm](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[Semana] [varchar](max) NULL,
	[DATA] [varchar](max) NULL,
	[MLP] [varchar](max) NULL,
	[Milha] [varchar](max) NULL,
	[Modal] [varchar](max) NULL,
	[Regional] [varchar](max) NULL,
	[SVC_XPT] [varchar](max) NULL,
	[Forecast] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
