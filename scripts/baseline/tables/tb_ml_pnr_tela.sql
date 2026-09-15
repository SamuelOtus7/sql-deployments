-- ============================================================
-- BASELINE: dbo.tb_ml_pnr_tela
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_pnr_tela]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_pnr_tela](
	[id_pnr] [int] IDENTITY(1,1) NOT NULL,
	[idreclamacao] [bigint] NOT NULL,
	[idtransportadora] [int] NOT NULL,
	[motivo] [varchar](100) NOT NULL,
	[erro] [varchar](100) NOT NULL,
	[status_fechamento] [varchar](50) NOT NULL,
	[contato_cliente] [varchar](50) NOT NULL,
	[telefone] [varchar](30) NULL,
	[observacao] [varchar](max) NULL,
	[dt_criacao] [datetime2](0) NOT NULL,
	[usuario_criacao] [varchar](128) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_pnr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
