-- ============================================================
-- BASELINE: dbo.tb_geotab_stg
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_geotab_stg]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_geotab_stg](
	[.Device.DeviceName] [varchar](max) NULL,
	[.Device.DeviceId] [varchar](max) NULL,
	[.Device.DeviceComment] [varchar](max) NULL,
	[.Device.DeviceGroup] [varchar](max) NULL,
	[.Device.DeviceGroup|Company Group] [varchar](max) NULL,
	[.Driver.DriverGroup|Company Group] [varchar](max) NULL,
	[.ExceptionRule.ExceptionRuleName] [varchar](max) NULL,
	[ExceptionSummaryFirstIncident] [datetime] NULL,
	[ExceptionSummaryLastIncident] [datetime] NULL,
	[ExceptionDuration] [bigint] NULL,
	[ExceptionDistance] [float] NULL,
	[ExceptionSummaryIncidentCount] [bigint] NULL,
	[filename] [varchar](max) NULL,
	[source] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
