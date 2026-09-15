-- ============================================================
-- BASELINE: dbo.tb_stg_looker_entrega_fantasma_mp
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_entrega_fantasma_mp]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_entrega_fantasma_mp](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[FLAG] [varchar](max) NULL,
	[Data] [varchar](max) NULL,
	[MLP] [varchar](max) NULL,
	[Regional] [varchar](max) NULL,
	[Macro_Regional] [varchar](max) NULL,
	[Facility] [varchar](max) NULL,
	[Shipment] [bigint] NULL,
	[PRODUCT] [varchar](max) NULL,
	[Veiculo] [varchar](max) NULL,
	[Rotas] [bigint] NULL,
	[Driver_Status] [varchar](max) NULL,
	[Driver] [bigint] NULL,
	[Placa] [varchar](max) NULL,
	[CEP] [varchar](max) NULL,
	[CUST_ID] [bigint] NULL,
	[DISTANCIA] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
