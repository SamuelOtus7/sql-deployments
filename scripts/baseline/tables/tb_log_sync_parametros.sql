-- ============================================================
-- BASELINE: dbo.tb_log_sync_parametros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_log_sync_parametros]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_log_sync_parametros](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cliente_origem] [int] NULL,
	[cliente_destino] [int] NULL,
	[prm_ds_chave] [varchar](150) NULL,
	[prm_nm_parametro] [varchar](150) NULL,
	[data_execucao] [datetime] NULL,
	[usuario_execucao] [varchar](100) NULL,
	[modo_preview] [bit] NULL,
	[inserido] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
