-- ============================================================
-- BASELINE: dbo.stg_looker_treinamentos_pendentes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_looker_treinamentos_pendentes]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_looker_treinamentos_pendentes](
	[MELI_ID] [bigint] NULL,
	[DRIVER_ID] [bigint] NULL,
	[CARRIER] [varchar](max) NULL,
	[MILLA] [varchar](max) NULL,
	[SVC] [varchar](max) NULL,
	[FACILITY] [varchar](max) NULL,
	[PLACA] [varchar](max) NULL,
	[ANTIGUEDAD] [varchar](max) NULL,
	[DRIVER_STATUS] [varchar](max) NULL,
	[COURSE_NAME] [varchar](max) NULL,
	[DECRIPTION] [varchar](max) NULL,
	[COURSE_PROGRESS] [varchar](max) NULL,
	[SEMANA] [float] NULL,
	[DATA DO TREINAMENTO] [float] NULL,
	[ULTIMA ROTA] [varchar](max) NULL,
	[Aderência] [varchar](max) NULL,
	[CodigoCliente] [bigint] NULL,
	[filename] [varchar](max) NULL,
	[timestamp] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
