-- ============================================================
-- BASELINE: dbo.tb_imp_log_execucao_script
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_imp_log_execucao_script]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_imp_log_execucao_script](
	[ies_cd_execucao_script] [bigint] IDENTITY(1,1) NOT NULL,
	[ilg_cd_log] [bigint] NOT NULL,
	[ies_ds_nome_script] [varchar](150) NOT NULL,
	[ies_ds_argumentos_json] [nvarchar](max) NULL,
	[ies_dh_inicio] [datetime] NOT NULL,
	[ies_dh_fim] [datetime] NULL,
	[ies_nu_codigo_retorno] [int] NULL,
	[ies_in_sucesso] [bit] NULL,
	[ies_ds_mensagem_erro] [nvarchar](max) NULL,
	[ies_ds_saida_log] [nvarchar](max) NULL,
 CONSTRAINT [PK_tb_imp_log_execucao_script] PRIMARY KEY CLUSTERED 
(
	[ies_cd_execucao_script] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
