-- ============================================================
-- BASELINE: dbo.ROTAS_SILOS_TRANSMANA_ABRIL
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[ROTAS_SILOS_TRANSMANA_ABRIL]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ROTAS_SILOS_TRANSMANA_ABRIL](
	[DATE] [date] NOT NULL,
	[ROUTE_ID] [int] NOT NULL,
	[DRIVER_ID] [int] NOT NULL,
	[DRIVER_NAME] [nvarchar](50) NOT NULL,
	[VEHICLE] [nvarchar](50) NOT NULL,
	[PLATE] [nvarchar](50) NOT NULL,
	[SERVICE_CENTER] [nvarchar](50) NOT NULL,
	[CYCLE] [nvarchar](50) NOT NULL,
	[DISPATCHED_SHIPMENTS] [int] NOT NULL,
	[SHIPMENTS_DELIVERED] [int] NOT NULL,
	[DELIVERY_SUCCESS] [float] NOT NULL,
	[NO_VISITED] [float] NOT NULL,
	[ORH] [float] NOT NULL,
	[SPORH] [float] NOT NULL,
	[DPPH] [float] NOT NULL,
	[PNR_CONTRADICTORIO] [float] NOT NULL
) ON [PRIMARY]
GO
