-- ============================================================
-- BASELINE: dbo.tb_stg_looker_delivery_success
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_delivery_success]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_delivery_success](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[Data] [varchar](max) NULL,
	[REGIONAL] [varchar](max) NULL,
	[SVC] [varchar](max) NULL,
	[XPT] [varchar](max) NULL,
	[MLP] [varchar](max) NULL,
	[Rotas] [bigint] NULL,
	[CANAL] [varchar](max) NULL,
	[Ciclo] [varchar](max) NULL,
	[Cluster] [varchar](max) NULL,
	[Driver] [bigint] NULL,
	[Experiencia_Driver] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[ID_VEICULO] [bigint] NULL,
	[Veiculo] [varchar](max) NULL,
	[HORA_INICIO] [varchar](max) NULL,
	[HORA_FIM] [varchar](max) NULL,
	[ORH_PLAN] [float] NULL,
	[ORH_HOURS] [float] NULL,
	[KM_PLAN] [bigint] NULL,
	[KM_REAL] [bigint] NULL,
	[STEM_OUT] [float] NULL,
	[Parada] [bigint] NULL,
	[Pacotes] [bigint] NULL,
	[Entregue] [bigint] NULL,
	[DS] [bigint] NULL,
	[AT_STATION] [bigint] NULL,
	[Total_de_Insucessos] [bigint] NULL,
	[INACCESSIBLE_ADDRESS] [bigint] NULL,
	[BUYER_REJECTED] [bigint] NULL,
	[BUYER_MOVED] [bigint] NULL,
	[BUYER_ABSENT] [bigint] NULL,
	[BUSINESS_CLOSED] [bigint] NULL,
	[BLOCKED_BY_KEYWORD] [bigint] NULL,
	[BAD_ADDRESS] [bigint] NULL,
	[NOT_ATTEMPTED] [bigint] NULL,
	[Outros_Motivos] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
