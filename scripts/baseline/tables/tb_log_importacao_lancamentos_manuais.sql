-- ============================================================
-- BASELINE: dbo.tb_log_importacao_lancamentos_manuais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_log_importacao_lancamentos_manuais]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_log_importacao_lancamentos_manuais](
	[lim_cd_log_importacao] [int] IDENTITY(1,1) NOT NULL,
	[lim_cd_cliente] [int] NOT NULL,
	[lim_cd_usuario_execucao] [int] NOT NULL,
	[lim_cd_lancamento_manual] [int] NULL,
	[lim_ds_nome_arquivo] [nvarchar](500) NOT NULL,
	[lim_dh_inicio_execucao] [datetime] NOT NULL,
	[lim_dh_fim_execucao] [datetime] NULL,
	[lim_ds_status_processamento] [nvarchar](50) NOT NULL,
	[lim_qt_total_registros] [int] NOT NULL,
	[lim_qt_registros_processados] [int] NOT NULL,
	[lim_qt_registros_com_erro] [int] NOT NULL,
	[lim_ds_mensagem_erro] [nvarchar](max) NULL,
	[lim_dh_criacao] [datetime] NOT NULL,
	[lim_cd_usuario_criacao] [int] NOT NULL,
	[lim_dh_modificacao] [datetime] NOT NULL,
	[lim_cd_usuario_modificacao] [int] NOT NULL,
	[lim_in_excluido] [bit] NOT NULL,
	[lim_in_ativo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[lim_cd_log_importacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
