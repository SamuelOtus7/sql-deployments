-- ============================================================
-- BASELINE: dbo.tb_sessao_usuario
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_sessao_usuario]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_sessao_usuario](
	[ssu_cd_sessao] [int] IDENTITY(1,1) NOT NULL,
	[usr_cd_usuario] [int] NOT NULL,
	[ssu_tp_login] [tinyint] NOT NULL,
	[ssu_ds_sessao_id] [varchar](64) NOT NULL,
	[ssu_ds_device_uuid] [varchar](128) NULL,
	[ssu_ds_device_info] [varchar](256) NULL,
	[ssu_ds_app_version] [varchar](32) NULL,
	[ssu_dh_login] [datetime] NOT NULL,
	[ssu_dh_ultima_atividade] [datetime] NOT NULL,
	[ssu_dh_expiracao] [datetime] NOT NULL,
	[ssu_dh_revogada] [datetime] NULL,
	[ssu_ds_motivo_revogacao] [varchar](64) NULL,
	[ssu_ds_created_by_ip] [varchar](45) NULL,
 CONSTRAINT [PK_sessao_usuario] PRIMARY KEY CLUSTERED 
(
	[ssu_cd_sessao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
