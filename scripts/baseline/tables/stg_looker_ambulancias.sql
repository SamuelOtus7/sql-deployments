-- ============================================================
-- BASELINE: dbo.stg_looker_ambulancias
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_looker_ambulancias]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_looker_ambulancias](
	[DATA] [varchar](max) NULL,
	[ID_ROTA] [bigint] NULL,
	[ID_MOTORISTA] [float] NULL,
	[SVC] [varchar](max) NULL,
	[TRANSPORTADORA] [varchar](max) NULL,
	[STATUS] [varchar](max) NULL,
	[PAGAMENTO] [varchar](max) NULL,
	[CodigoCliente] [bigint] NULL,
	[filename] [varchar](max) NULL,
	[timestamp] [datetime] NULL,
	[MOTIVO] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
