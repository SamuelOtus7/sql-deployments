-- ============================================================
-- BASELINE: dbo.tb_spe_rotas_prefatura
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_rotas_prefatura]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_rotas_prefatura](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CodigoRota] [varchar](50) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[NomeHub] [varchar](100) NULL,
	[TipoOperacao] [varchar](50) NULL,
	[TipoVeiculo] [varchar](50) NULL,
	[CidadeReferencia] [varchar](100) NULL,
	[UFReferencia] [char](2) NULL,
	[StationOrigem] [varchar](100) NULL,
	[StationDestino] [varchar](150) NULL,
	[TotalPacotes] [int] NOT NULL,
	[KmTotal] [numeric](18, 8) NULL,
	[ValorTotalFrete] [numeric](18, 8) NULL,
	[DataHoraInicio] [datetime] NULL,
	[DataHoraFim] [datetime] NULL,
	[DataHoraUltimaEntrega] [datetime] NULL,
	[Placa] [varchar](50) NULL,
	[Resultado] [varchar](250) NULL,
	[DataAtualizacao] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_spe_rotas_prefatura] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
