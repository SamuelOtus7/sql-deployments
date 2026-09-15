-- ============================================================
-- BASELINE: dbo.tb_monitoramento_bloqueios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_monitoramento_bloqueios]    Script Date: 14/09/2026 12:12:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_monitoramento_bloqueios](
	[cod_monitoramento] [int] IDENTITY(1,1) NOT NULL,
	[session_id] [smallint] NOT NULL,
	[wait_resource] [nvarchar](256) NOT NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[host_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[status] [nvarchar](30) NOT NULL,
	[command] [nvarchar](32) NOT NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_time] [int] NOT NULL,
	[blocking_session_id] [smallint] NULL,
	[executing_query] [nvarchar](max) NULL,
	[query_plan] [xml] NULL,
	[DataAtualizacao] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
