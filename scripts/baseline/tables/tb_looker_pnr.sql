-- ============================================================
-- BASELINE: dbo.tb_looker_pnr
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_looker_pnr]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_looker_pnr](
	[DataExtracao] [date] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[DATA] [varchar](max) NULL,
	[SVC] [varchar](max) NULL,
	[REP_ID] [varchar](max) NULL,
	[CASO] [bigint] NULL,
	[STATUS] [varchar](max) NULL,
	[CLA_CLAIM_ID] [bigint] NULL,
	[CLA_STATUS_ID] [varchar](max) NULL,
	[BPP] [varchar](max) NULL,
	[DRIVER] [bigint] NULL,
	[MLP] [varchar](max) NULL,
	[ROUTE_ID] [bigint] NULL,
	[SHIPMENT] [bigint] NULL,
	[VEICULO_ID] [bigint] NULL,
	[CASE_STATUS] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
