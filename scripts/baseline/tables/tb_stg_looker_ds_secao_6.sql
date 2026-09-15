-- ============================================================
-- BASELINE: dbo.tb_stg_looker_ds_secao_6
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_ds_secao_6]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_ds_secao_6](
	[Data] [datetime2](0) NULL,
	[REGIONAL_AJUST] [varchar](50) NULL,
	[SVC] [varchar](50) NULL,
	[XPT] [varchar](50) NULL,
	[MLP] [varchar](50) NULL,
	[Rotas] [bigint] NULL,
	[Perfil_Veiculo_Executado] [varchar](100) NULL,
	[Ciclo] [varchar](20) NULL,
	[Cluster] [bigint] NULL,
	[Driver] [bigint] NULL,
	[Experiencia_Driver] [varchar](50) NULL,
	[Placa] [varchar](20) NULL,
	[ID_VEICULO] [bigint] NULL,
	[Veiculo] [varchar](100) NULL,
	[HORA_INICIO] [time](0) NULL,
	[HORA_FIM] [time](0) NULL,
	[ORH_PLAN] [decimal](18, 2) NULL,
	[ORH_HOURS] [decimal](18, 2) NULL,
	[KM_PLAN] [decimal](18, 2) NULL,
	[KM_REAL] [decimal](18, 2) NULL,
	[STEM_OUT] [decimal](18, 2) NULL,
	[Parada] [bigint] NULL,
	[Pacotes] [bigint] NULL,
	[Entregue] [bigint] NULL,
	[DS] [bigint] NULL,
	[AT_STATION] [bigint] NULL,
	[Insucessos] [bigint] NULL,
	[INACCESSIBLE_ADDRESS] [bigint] NULL,
	[BUYER_REJECTED] [bigint] NULL,
	[BUYER_MOVED] [bigint] NULL,
	[BUYER_ABSENT] [bigint] NULL,
	[BUSINESS_CLOSED] [bigint] NULL,
	[BLOCKED_BY_KEYWORD] [bigint] NULL,
	[BAD_ADDRESS] [bigint] NULL,
	[NOT_ATTEMPTED] [bigint] NULL,
	[Outros_Motivos] [bigint] NULL
) ON [PRIMARY]
GO
