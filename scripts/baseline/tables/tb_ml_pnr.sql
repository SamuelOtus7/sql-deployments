-- ============================================================
-- BASELINE: dbo.tb_ml_pnr
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_pnr]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_pnr](
	[IdTransportadora] [varchar](20) NOT NULL,
	[IdReclamacao] [int] NOT NULL,
	[Quinzena] [varchar](20) NOT NULL,
	[DataReclamacao] [date] NOT NULL,
	[Motorista] [varchar](100) NOT NULL,
	[ServiceCenter] [varchar](50) NOT NULL,
	[IdPacote] [bigint] NOT NULL,
	[Valor] [decimal](7, 2) NOT NULL,
	[Status] [varchar](100) NOT NULL,
	[DataColeta] [datetime] NOT NULL,
	[DataFechamento] [date] NULL,
 CONSTRAINT [PK_tb_ml_pnr] PRIMARY KEY CLUSTERED 
(
	[IdTransportadora] ASC,
	[IdReclamacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
