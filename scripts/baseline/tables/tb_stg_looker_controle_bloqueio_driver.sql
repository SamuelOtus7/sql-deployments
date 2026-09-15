-- ============================================================
-- BASELINE: dbo.tb_stg_looker_controle_bloqueio_driver
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_controle_bloqueio_driver]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_controle_bloqueio_driver](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[Data] [varchar](max) NULL,
	[Semana] [bigint] NULL,
	[MLP] [varchar](max) NULL,
	[SVC] [varchar](max) NULL,
	[TIPO] [varchar](max) NULL,
	[Bloqueio] [varchar](max) NULL,
	[BLOCK_REASON_ID] [varchar](max) NULL,
	[REASON] [varchar](max) NULL,
	[DRIVER_ID] [bigint] NULL,
	[last_vehicle_plate] [varchar](max) NULL,
	[SHP_LG_ACTION_TYPE] [varchar](max) NULL,
	[SHP_LG_TYPE] [varchar](max) NULL,
	[USER_ID] [bigint] NULL,
	[total_rotas] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
