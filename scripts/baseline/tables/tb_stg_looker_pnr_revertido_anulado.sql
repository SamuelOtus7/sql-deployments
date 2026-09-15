-- ============================================================
-- BASELINE: dbo.tb_stg_looker_pnr_revertido_anulado
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_pnr_revertido_anulado]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_pnr_revertido_anulado](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[RESOLUTION_DATE] [varchar](max) NULL,
	[SHP_SHIPMENT_ID] [bigint] NULL,
	[SHP_ROUTE_ID] [bigint] NULL,
	[SHP_LG_FACILITY_ID] [varchar](max) NULL,
	[NODE_ID] [varchar](max) NULL,
	[QTDE_CASOS] [bigint] NULL,
	[QTDE_PNR_ANULADO_CCO] [bigint] NULL,
	[QTDE_PNR_FATURADO_AUTOMATICAMENTE] [bigint] NULL,
	[QTDE_PNR_REVERTIDO] [bigint] NULL,
	[Pct_Revertido] [varchar](max) NULL,
	[Pct_Anulado] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
