-- ============================================================
-- BASELINE: dbo.tb_pag_espelhos_nomeigual_codigodiferente
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_espelhos_nomeigual_codigodiferente]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_espelhos_nomeigual_codigodiferente](
	[mtn_cd_motorista_nfs] [int] IDENTITY(1,1) NOT NULL,
	[mtn_cd_motorista] [int] NULL,
	[mtn_cd_pgto_periodo] [int] NOT NULL,
	[mtn_cd_status] [int] NOT NULL,
	[mtn_vl_nfs] [decimal](10, 2) NOT NULL,
	[mtn_ds_link_nfs] [varchar](1000) NULL,
	[mtn_dt_prazo_contestacao] [datetime] NULL,
	[mtn_dh_criacao] [datetime] NOT NULL,
	[mtn_cd_usr_criacao] [int] NOT NULL,
	[mtn_dh_modificacao] [datetime] NOT NULL,
	[mtn_cd_usr_modificacao] [int] NOT NULL,
	[mtn_in_excluido] [bit] NOT NULL,
	[mtn_cod_cliente] [int] NOT NULL,
	[mtn_qt_rotas] [tinyint] NOT NULL,
	[mtn_cd_tipo_espelho] [int] NULL,
	[mtn_cd_cliente_transportadora] [int] NULL,
	[mtn_cd_base] [int] NULL,
	[mtn_in_gerar_pdf] [bit] NULL,
	[mtn_ds_linkespelho] [varchar](250) NULL,
	[mtn_base_principal] [varchar](50) NULL,
	[mtn_nome_motorista] [varchar](200) NULL,
	[mtn_cd_status_pdf_massa] [int] NULL,
	[mtn_dt_data_criacao_pdf_massa] [datetime] NULL,
	[mtn_dh_envio_nfs] [datetime] NULL,
	[mtn_dh_envio_push_notification] [datetime] NULL,
	[mtn_vl_imposto] [decimal](10, 2) NULL,
	[mtn_vl_liquido] [decimal](10, 2) NULL,
	[mtn_ds_link_nfs_secundario] [varchar](1000) NULL,
	[mtn_dh_envio_nfs_secundario] [datetime] NULL,
	[mtn_in_zerar_espelho] [int] NULL,
	[mtn_vl_desconto] [decimal](10, 2) NOT NULL,
	[mtn_cd_operacao] [int] NOT NULL
) ON [PRIMARY]
GO
