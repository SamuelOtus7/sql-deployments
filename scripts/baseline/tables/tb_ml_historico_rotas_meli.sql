-- ============================================================
-- BASELINE: dbo.tb_ml_historico_rotas_meli
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_historico_rotas_meli]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_historico_rotas_meli](
	[coddmeli] [int] IDENTITY(1,1) NOT NULL,
	[idtransportadora] [int] NOT NULL,
	[date_data] [date] NOT NULL,
	[route_id] [bigint] NOT NULL,
	[service_center] [varchar](10) NOT NULL,
	[cycle] [varchar](5) NULL,
	[dispatched_shipments] [int] NULL,
	[shipments_delivered] [int] NULL,
	[delivery_success] [float] NULL,
	[no_visited] [float] NULL,
	[orh] [float] NULL,
	[sporh] [float] NULL,
	[dpph] [float] NULL,
	[pnr_contradictorio] [float] NULL
) ON [PRIMARY]
GO
