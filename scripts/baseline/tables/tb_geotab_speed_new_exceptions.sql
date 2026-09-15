-- ============================================================
-- BASELINE: dbo.tb_geotab_speed_new_exceptions
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_geotab_speed_new_exceptions]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_geotab_speed_new_exceptions](
	[DeviceName] [varchar](max) NULL,
	[CompanyLocation] [varchar](max) NULL,
	[ExceptionSummaryIncidentCount] [bigint] NULL,
	[ExceptionSummaryFirstIncident] [datetime] NULL,
	[ExceptionSummaryLastIncident] [datetime] NULL,
	[ExceptionDuration] [bigint] NULL,
	[ExceptionDistance] [float] NULL,
	[ProcessedAt] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
