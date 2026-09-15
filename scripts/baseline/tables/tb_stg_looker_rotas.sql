-- ============================================================
-- BASELINE: dbo.tb_stg_looker_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_rotas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_rotas](
	[Data] [nvarchar](30) NULL,
	[REGIONAL] [nvarchar](20) NULL,
	[SVC] [nvarchar](10) NULL,
	[XPT] [nvarchar](20) NULL,
	[MLP] [nvarchar](10) NULL,
	[Rotas] [nvarchar](20) NULL,
	[CANAL] [nvarchar](30) NULL,
	[Ciclo] [nvarchar](10) NULL,
	[Cluster] [nvarchar](10) NULL,
	[Driver] [nvarchar](20) NULL,
	[Placa] [nvarchar](20) NULL,
	[ID_VEICULO] [nvarchar](20) NULL,
	[Veículo] [nvarchar](100) NULL,
	[HORA_INICIO] [nvarchar](20) NULL,
	[HORA_FIM] [nvarchar](30) NULL,
	[ORH_PLAN] [nvarchar](20) NULL,
	[ORH_HOURS] [nvarchar](20) NULL,
	[KM_PLAN] [nvarchar](20) NULL,
	[KM_REAL] [nvarchar](20) NULL,
	[STEM_OUT] [nvarchar](20) NULL,
	[Parada] [nvarchar](20) NULL,
	[Pacotes] [nvarchar](20) NULL,
	[Entregue] [nvarchar](20) NULL,
	[DS] [nvarchar](40) NULL,
	[AT_STATION] [nvarchar](20) NULL,
	[Total de Insucessos] [nvarchar](20) NULL,
	[INACCESSIBLE_ADDRESS] [nvarchar](20) NULL,
	[BUYER_REJECTED] [nvarchar](20) NULL,
	[BUYER_MOVED] [nvarchar](20) NULL,
	[BUYER_ABSENT] [nvarchar](20) NULL,
	[BUSINESS_CLOSED] [nvarchar](20) NULL,
	[BLOCKED_BY_KEYWORD] [nvarchar](20) NULL,
	[BAD_ADDRESS] [nvarchar](20) NULL,
	[NOT_ATTEMPTED] [nvarchar](20) NULL,
	[Outros Motivos] [nvarchar](20) NULL,
	[data_hora_coleta] [datetime] NULL,
	[idtrnasportadora] [int] NULL
) ON [PRIMARY]
GO
