-- ============================================================
-- BASELINE: dbo.tb_stg_looker_ajudantes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_ajudantes]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_ajudantes](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[Data_da_Rota] [varchar](max) NULL,
	[SVC] [varchar](max) NULL,
	[Modal] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[ID_Rota] [bigint] NULL,
	[Helper_Presente] [varchar](max) NULL,
	[Helper_Obrigatorio] [bigint] NULL,
	[Helper_Ausente] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
