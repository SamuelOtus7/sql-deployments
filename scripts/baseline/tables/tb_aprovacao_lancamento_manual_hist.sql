-- ============================================================
-- BASELINE: dbo.tb_aprovacao_lancamento_manual_hist
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_aprovacao_lancamento_manual_hist]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_aprovacao_lancamento_manual_hist](
	[alm_cd_aprovacao_lancamento_manual] [int] NOT NULL,
	[alm_cd_lancamento_manual] [int] NOT NULL,
	[alm_ds_status] [varchar](30) NULL,
	[alm_ds_motivo] [varchar](150) NULL,
	[alm_cd_usuario_aprovacao] [int] NULL,
	[alm_dh_aprovacao] [datetime] NULL,
	[alm_cd_cliente] [int] NULL,
	[alm_in_ativo] [bit] NOT NULL,
	[alm_in_excluido] [bit] NOT NULL,
	[alm_cd_usuario_criacao] [int] NOT NULL,
	[alm_dh_criacao] [datetime] NOT NULL,
	[alm_cd_usuario_modificacao] [int] NULL,
	[alm_dh_modificacao] [datetime] NULL,
	[alm_cd_chave_reprovacao] [int] NULL,
	[alm_ds_observacao_reprovacao] [varchar](500) NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
