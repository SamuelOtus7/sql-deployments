-- ============================================================
-- BASELINE: dbo.tb_aprovacao_lancamento_manual
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_aprovacao_lancamento_manual]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_aprovacao_lancamento_manual](
	[alm_cd_aprovacao_lancamento_manual] [int] IDENTITY(1,1) NOT NULL,
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
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [pk_aprovacao_lancamento_manual] PRIMARY KEY CLUSTERED 
(
	[alm_cd_aprovacao_lancamento_manual] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_aprovacao_lancamento_manual] UNIQUE NONCLUSTERED 
(
	[alm_cd_lancamento_manual] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_aprovacao_lancamento_manual_hist])
)
GO
