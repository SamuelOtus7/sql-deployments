-- ============================================================
-- BASELINE: dbo.tb_imp_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_imp_log]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_imp_log](
	[ilg_cd_log] [bigint] IDENTITY(1,1) NOT NULL,
	[cli_cd_codigo_cliente] [int] NOT NULL,
	[imp_cd_importador] [int] NOT NULL,
	[usr_cd_usuario] [int] NOT NULL,
	[ilg_ds_nome_arquivo_original] [varchar](255) NOT NULL,
	[ilg_ds_caminho_arquivo_salvo] [varchar](500) NULL,
	[ilg_nu_tamanho_arquivo_bytes] [bigint] NULL,
	[ist_cd_status] [tinyint] NOT NULL,
	[ilg_nu_registros_inseridos] [int] NULL,
	[ilg_nu_registros_com_erro] [int] NULL,
	[ilg_ds_mensagem_resumo] [varchar](1000) NULL,
	[ilg_ds_nome_script_executado] [varchar](150) NULL,
	[ilg_dh_inicio] [datetime] NOT NULL,
	[ilg_dh_fim] [datetime] NULL,
	[ilg_nu_duracao_segundos]  AS (datediff(second,[ilg_dh_inicio],[ilg_dh_fim])) PERSISTED,
 CONSTRAINT [PK_tb_imp_log] PRIMARY KEY CLUSTERED 
(
	[ilg_cd_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
