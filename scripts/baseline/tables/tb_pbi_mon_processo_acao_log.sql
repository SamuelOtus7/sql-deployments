-- ============================================================
-- BASELINE: dbo.tb_pbi_mon_processo_acao_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pbi_mon_processo_acao_log]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pbi_mon_processo_acao_log](
	[acao_log_id] [bigint] IDENTITY(1,1) NOT NULL,
	[processo_id] [int] NOT NULL,
	[dh_execucao] [datetime2](3) NOT NULL,
	[ds_usuario] [nvarchar](100) NULL,
	[proc_acao] [varchar](128) NOT NULL,
	[ds_parametros_json] [nvarchar](max) NULL,
	[ds_comando_executado] [nvarchar](max) NULL,
	[in_sucesso] [bit] NOT NULL,
	[ds_mensagem] [nvarchar](2000) NULL,
	[nr_duracao_ms] [int] NULL,
	[nr_linhas_afetadas] [int] NULL,
 CONSTRAINT [PK_tb_pbi_mon_processo_acao_log] PRIMARY KEY CLUSTERED 
(
	[acao_log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
