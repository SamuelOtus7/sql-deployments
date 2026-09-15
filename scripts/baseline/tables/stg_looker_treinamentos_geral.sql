-- ============================================================
-- BASELINE: dbo.stg_looker_treinamentos_geral
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_looker_treinamentos_geral]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_looker_treinamentos_geral](
	[MELI_ID] [bigint] NULL,
	[DRIVER_ID] [bigint] NULL,
	[CARRIER] [varchar](max) NULL,
	[MILLA] [varchar](max) NULL,
	[SVC] [varchar](max) NULL,
	[PLACA] [varchar](max) NULL,
	[ANTIGUEDAD] [varchar](max) NULL,
	[DRIVER_STATUS] [varchar](max) NULL,
	[COURSE_NAME] [varchar](max) NULL,
	[DECRIPTION] [varchar](max) NULL,
	[COURSE_PROGRESS] [varchar](max) NULL,
	[SEMANA] [varchar](max) NULL,
	[DATA DO TREINAMENTO] [varchar](max) NULL,
	[ULTIMA ROTA] [varchar](max) NULL,
	[Aderência] [varchar](max) NULL,
	[CodigoCliente] [bigint] NULL,
	[filename] [varchar](max) NULL,
	[timestamp] [datetime] NULL,
	[pk_composta] [varchar](max) NULL,
	[FACILITY] [varchar](max) NULL,
	[cd_transportadora] [int] NULL,
	[nome_transportadora] [varchar](max) NULL,
	[nome_motorista] [varchar](60) NULL,
	[CONTAS_ATIVAS_MELI] [int] NULL,
	[MLP] [varchar](max) NULL,
	[REGIONAIS] [varchar](10) NULL,
	[PRIMEIRA_ROTA] [varchar](50) NULL,
	[NOTA] [decimal](5, 2) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
