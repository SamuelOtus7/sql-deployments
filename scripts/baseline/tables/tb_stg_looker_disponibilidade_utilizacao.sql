-- ============================================================
-- BASELINE: dbo.tb_stg_looker_disponibilidade_utilizacao
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_disponibilidade_utilizacao]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_disponibilidade_utilizacao](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[DT] [varchar](max) NULL,
	[MLP] [varchar](max) NULL,
	[Regional] [varchar](max) NULL,
	[HUB_final] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[CLASSE] [varchar](max) NULL,
	[STATUS] [varchar](max) NULL,
	[Qtde_Rota] [bigint] NULL,
	[Pct_Utilizacao] [varchar](max) NULL,
	[Pct_Disponibilidade] [varchar](max) NULL,
	[Frota_Total] [bigint] NULL,
	[Qtde_Manutencao] [bigint] NULL,
	[Qtde_Reserva] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
