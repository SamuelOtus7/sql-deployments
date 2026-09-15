-- ============================================================
-- BASELINE: dbo.tb_lancamentos_bkp
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_lancamentos_bkp]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_lancamentos_bkp](
	[valid] [bigint] NULL,
	[mtn_cd_motorista] [int] NULL,
	[mtn_driver_id] [int] NULL,
	[mtn_nome_motorista] [varchar](100) NULL,
	[mtn_cd_pgto_periodo] [int] NULL,
	[mtn_cd_status] [int] NOT NULL,
	[mtn_vl_nfs] [decimal](38, 2) NULL,
	[mtn_ds_link_nfs] [varchar](1000) NULL,
	[mtn_dt_prazo_contestacao] [datetime] NULL,
	[mtn_dh_criacao] [datetime] NULL,
	[mtn_cd_usr_criacao] [int] NULL,
	[mtn_dh_modificacao] [datetime] NULL,
	[mtn_cd_usr_modificacao] [int] NULL,
	[mtn_in_excluido] [bit] NULL,
	[mtn_cod_cliente] [int] NULL,
	[mtn_qt_rotas] [int] NULL,
	[mtn_cd_tipo_espelho] [int] NOT NULL,
	[mtn_cd_cliente_transportadora] [int] NULL,
	[mtn_cd_base] [int] NULL,
	[mtn_base_principal] [varchar](150) NULL,
	[mtn_cd_tipo_contrato] [int] NULL
) ON [PRIMARY]
GO
