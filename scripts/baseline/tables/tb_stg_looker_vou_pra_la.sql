-- ============================================================
-- BASELINE: dbo.tb_stg_looker_vou_pra_la
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_vou_pra_la]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_vou_pra_la](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[Periodo] [varchar](20) NULL,
	[MLP] [varchar](50) NULL,
	[REGIONAL] [varchar](20) NULL,
	[Facility] [varchar](20) NULL,
	[XPT] [varchar](20) NULL,
	[Driver] [bigint] NULL,
	[Placa] [varchar](50) NULL,
	[ID_ROTA_SHP] [bigint] NULL,
	[Volume_Despachado] [bigint] NULL,
	[Volume_Entregue] [bigint] NULL,
	[Volume_com_VPA] [bigint] NULL,
	[Volume_Despachado_Comercial] [bigint] NULL,
	[Volume_Entregues_Comercial] [bigint] NULL,
	[Volume_Comercial_VPA] [bigint] NULL,
	[Volume_Residencial_VPA] [bigint] NULL,
	[Volume_Reversa_VPA] [bigint] NULL,
	[Vou_pra_la_Pacotes] [varchar](50) NULL,
	[Vou_pra_la_Comerciais] [varchar](50) NULL,
	[Vou_pra_la_Residenciais] [varchar](50) NULL,
	[Vou_pra_la_Reversa] [varchar](50) NULL,
	[DS] [varchar](50) NULL,
	[DS_VPA] [varchar](50) NULL,
	[DS_s_VPA] [varchar](50) NULL,
	[DS_Comerciais] [varchar](50) NULL,
	[DS_VPA_Comerciais] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
