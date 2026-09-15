-- ============================================================
-- BASELINE: dbo.tb_faturamento_pendente_processamento
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_faturamento_pendente_processamento]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_faturamento_pendente_processamento](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [int] NOT NULL,
	[Quinzena] [int] NOT NULL,
	[CodMarketplace] [int] NOT NULL,
	[Marketplace] [nvarchar](150) NOT NULL,
	[CodUsuarioCriacao] [int] NOT NULL,
	[NomeArquivo] [nvarchar](255) NOT NULL,
	[LinkArquivo] [nvarchar](500) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[DataCadastro] [datetime] NOT NULL,
	[DataUltimaAtualizacao] [datetime] NULL,
	[IdTransportadora] [int] NULL,
	[CodCliente] [int] NULL,
	[MarketplaceOperacao] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
