-- ============================================================
-- BASELINE: dbo.tb_log_importacao_lancamentos_manuais_resultado
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_log_importacao_lancamentos_manuais_resultado]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_log_importacao_lancamentos_manuais_resultado](
	[lir_cd_log_resultado] [int] IDENTITY(1,1) NOT NULL,
	[lir_cd_log_importacao] [int] NOT NULL,
	[lir_nu_linha] [int] NOT NULL,
	[lir_tp_status] [nvarchar](20) NOT NULL,
	[lir_ds_mensagem_erro] [nvarchar](max) NULL,
	[lir_ds_dados_linha] [nvarchar](max) NULL,
	[lir_dh_criacao] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[lir_cd_log_resultado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
