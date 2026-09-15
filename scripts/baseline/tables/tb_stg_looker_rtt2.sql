-- ============================================================
-- BASELINE: dbo.tb_stg_looker_rtt2
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_rtt2]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_rtt2](
	[DataExtracao] [date] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[Pais] [varchar](max) NULL,
	[Quinzena] [varchar](max) NULL,
	[MLP] [varchar](max) NULL,
	[ROUTE_ID] [int] NULL,
	[Odometro] [float] NULL,
	[KM] [float] NULL,
	[DistanceToStation] [float] NULL,
	[KMTotal] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
