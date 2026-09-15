-- ============================================================
-- BASELINE: dbo.tb_ml_pnr_tela_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_pnr_tela_log]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_pnr_tela_log](
	[id_log] [bigint] IDENTITY(1,1) NOT NULL,
	[id_pnr] [int] NOT NULL,
	[idreclamacao] [bigint] NOT NULL,
	[idtransportadora] [int] NOT NULL,
	[coluna_alterada] [varchar](100) NOT NULL,
	[valor_anterior] [varchar](max) NULL,
	[valor_novo] [varchar](max) NULL,
	[data_operacao] [datetime2](0) NOT NULL,
	[usuario_operacao] [varchar](128) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
