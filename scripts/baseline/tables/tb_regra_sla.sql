-- ============================================================
-- BASELINE: dbo.tb_regra_sla
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_regra_sla]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_regra_sla](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idtransportadora] [int] NOT NULL,
	[nomehub] [varchar](100) NOT NULL,
	[cidade] [varchar](100) NULL,
	[dias_sla] [int] NOT NULL,
	[usuario_edicao] [int] NOT NULL,
	[data_edicao] [datetime] NOT NULL,
	[regiao] [varchar](100) NULL,
	[Valor] [decimal](10, 2) NULL,
	[ValorFora] [decimal](10, 2) NULL,
	[excluido] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
