-- ============================================================
-- BASELINE: dbo.tb_stg_looker_cadastro_veiculos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_cadastro_veiculos]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_cadastro_veiculos](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[SHP_LG_VEHICLE_ID] [bigint] NULL,
	[MLP] [varchar](50) NULL,
	[SHP_LG_VEHICLE_TYPE] [varchar](100) NULL,
	[Plate_Fleet] [varchar](50) NULL,
	[STATUS] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
