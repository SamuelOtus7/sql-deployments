-- ============================================================
-- BASELINE: dbo.tb_rcto_periodo_rota
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rcto_periodo_rota]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rcto_periodo_rota](
	[rcp_cd_recebimento_rota] [int] IDENTITY(1,1) NOT NULL,
	[rcp_cd_periodo] [int] NULL,
	[rcp_cd_rota] [int] NULL,
	[rcp_cd_faixa_km] [int] NULL,
	[rcp_ds_placa] [varchar](50) NULL,
	[rcp_ds_tipo_veiculo] [varchar](50) NULL,
	[rcp_ds_ciclo] [varchar](50) NULL,
	[rcp_qt_pacotes] [int] NULL,
	[rcp_qt_pontos] [int] NULL,
	[rcp_qt_paradas] [int] NULL,
	[rcp_in_area_risco] [bit] NULL,
	[rcp_in_ajudante] [bit] NULL,
	[rcp_in_dom_fer] [bit] NULL,
	[rcp_vl_base] [decimal](10, 2) NULL,
	[rcp_vl_paradas] [decimal](10, 2) NULL,
	[rcp_vl_risco] [decimal](10, 2) NULL,
	[rcp_vl_ajudante] [decimal](10, 2) NULL,
	[rcp_vl_dom_fer] [decimal](10, 2) NULL,
	[rcp_vl_lancamentos] [decimal](10, 2) NULL,
	[rcp_vl_total_km_real] [decimal](10, 2) NULL,
	[rcp_vl_total_km_minimo] [decimal](10, 2) NULL,
	[rcp_vl_total_km_prefatura] [decimal](10, 2) NULL,
	[rcp_vl_total] [decimal](10, 2) NULL,
	[rcp_dh_criacao] [datetime] NOT NULL,
	[rcp_cd_usr_criacao] [int] NOT NULL,
	[rcp_dh_modificacao] [datetime] NOT NULL,
	[rcp_cd_usr_modificacao] [int] NOT NULL,
	[rcp_in_ativo] [bit] NOT NULL,
	[rcp_in_excluido] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rcp_cd_recebimento_rota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
