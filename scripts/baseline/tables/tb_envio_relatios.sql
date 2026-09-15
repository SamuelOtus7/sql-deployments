-- ============================================================
-- BASELINE: dbo.tb_envio_relatios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_envio_relatios]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_envio_relatios](
	[er_cd_envio_relatorio] [int] IDENTITY(1,1) NOT NULL,
	[er_cd_codigo_cliente] [int] NOT NULL,
	[er_dt_ultima_execucao] [datetime] NULL,
	[er_dt_proxima_execucao] [datetime] NULL,
	[er_cd_relatorio] [int] NOT NULL,
	[er_in_desativado] [bit] NULL,
	[er_ds_cron_seg] [varchar](30) NULL,
	[er_ds_cron_ter] [varchar](30) NULL,
	[er_ds_cron_qua] [varchar](30) NULL,
	[er_ds_cron_qui] [varchar](30) NULL,
	[er_ds_cron_sex] [varchar](30) NULL,
	[er_ds_cron_sab] [varchar](30) NULL,
	[er_ds_cron_dom] [varchar](30) NULL,
	[er_cd_grupo_wpp] [int] NULL,
	[er_in_excluido] [bit] NOT NULL,
	[er_dh_criacao] [datetime] NULL,
	[er_cd_usr_criacao] [int] NULL,
	[er_dh_modificacao] [datetime] NULL,
	[er_cd_usr_modificacao] [int] NULL,
	[er_ds_filtros] [nvarchar](4000) NULL,
	[er_in_configuracao_em_grupo] [bit] NOT NULL,
	[er_cd_instancia_token] [int] NULL,
	[er_ds_name_instancia_wpp] [nvarchar](255) NULL,
	[er_ds_tipo_envio] [varchar](20) NULL,
	[er_in_enviar_msg_sem_dados] [bit] NULL,
	[er_ds_tipo_envio_msg_sem_dados] [varchar](20) NULL,
	[er_ds_mensagem_sem_dados] [varchar](200) NULL,
	[er_ds_marketplace] [varchar](50) NULL,
 CONSTRAINT [PK_tb_envio_relatios] PRIMARY KEY CLUSTERED 
(
	[er_cd_envio_relatorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
