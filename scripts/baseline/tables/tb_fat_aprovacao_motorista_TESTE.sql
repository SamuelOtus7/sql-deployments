-- ============================================================
-- BASELINE: dbo.tb_fat_aprovacao_motorista_TESTE
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fat_aprovacao_motorista_TESTE]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fat_aprovacao_motorista_TESTE](
	[fam_cd_aprovacao] [int] IDENTITY(1,1) NOT NULL,
	[fam_cd_cliente] [int] NOT NULL,
	[fam_dt_data] [date] NOT NULL,
	[fam_ds_rota] [int] NOT NULL,
	[fam_cd_usuario_motorista] [int] NOT NULL,
	[fam_ds_entregas] [int] NOT NULL,
	[fam_ds_km] [decimal](18, 9) NOT NULL,
	[fam_ds_valor] [decimal](18, 9) NOT NULL,
	[fam_ds_sucesso] [smallint] NOT NULL,
	[fam_ds_insucesso] [smallint] NOT NULL,
	[fam_ds_url_maps] [varchar](1000) NOT NULL,
	[fam_ds_status] [varchar](100) NOT NULL,
	[fam_cd_usuario_criacao] [int] NOT NULL,
	[fam_dh_criacao] [datetime] NOT NULL,
	[fam_cd_usuario_modificacao] [int] NOT NULL,
	[fam_dh_modificacao] [datetime] NOT NULL,
	[fam_dh_aprovacao] [datetime] NULL,
	[fam_cd_usuario_aprovacao] [int] NULL,
	[fam_in_excluido] [bit] NOT NULL
) ON [PRIMARY]
GO
