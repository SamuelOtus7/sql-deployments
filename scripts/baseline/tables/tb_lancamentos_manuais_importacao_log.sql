-- ============================================================
-- BASELINE: dbo.tb_lancamentos_manuais_importacao_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_lancamentos_manuais_importacao_log]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_lancamentos_manuais_importacao_log](
	[lmi_cd_importacao_log] [int] IDENTITY(1,1) NOT NULL,
	[lmi_cd_cliente] [int] NOT NULL,
	[lmi_cd_usuario_execucao] [int] NOT NULL,
	[lmi_dh_registro] [datetime] NOT NULL,
	[lmi_ds_nome_arquivo] [nvarchar](500) NOT NULL,
	[lmi_nu_linha] [int] NULL,
	[lmi_ds_mensagem_erro] [nvarchar](max) NOT NULL,
	[lmi_js_dados_linha] [nvarchar](max) NULL,
	[lmi_js_contexto_importacao] [nvarchar](max) NULL,
	[lmi_ds_data_planilha] [nvarchar](100) NULL,
	[lmi_ds_rota] [nvarchar](500) NULL,
	[lmi_ds_motorista] [nvarchar](500) NULL,
	[lmi_ds_codigo_usuario] [nvarchar](200) NULL,
	[lmi_ds_nome_arquivo_original] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[lmi_cd_importacao_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
