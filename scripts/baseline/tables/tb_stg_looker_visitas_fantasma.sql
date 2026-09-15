-- ============================================================
-- BASELINE: dbo.tb_stg_looker_visitas_fantasma
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_visitas_fantasma]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_visitas_fantasma](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[DATE] [varchar](max) NULL,
	[Hora_Expedicao] [varchar](max) NULL,
	[MLP] [varchar](max) NULL,
	[ROUTE_ID] [bigint] NULL,
	[DRIVER_ID] [bigint] NULL,
	[SHIPMENT_ID] [bigint] NULL,
	[SVC] [varchar](max) NULL,
	[Cluster] [varchar](max) NULL,
	[PROJETOS] [varchar](max) NULL,
	[XPT] [varchar](max) NULL,
	[PLACAS] [varchar](max) NULL,
	[VEICULOS] [varchar](max) NULL,
	[FALHAS] [bigint] NULL,
	[VISITAS_FANTASMAS] [bigint] NULL,
	[Pct_Visita_Fantasma] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
