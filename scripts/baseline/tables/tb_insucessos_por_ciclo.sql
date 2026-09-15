-- ============================================================
-- BASELINE: dbo.tb_insucessos_por_ciclo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_insucessos_por_ciclo]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_insucessos_por_ciclo](
	[idtransportadora] [int] NOT NULL,
	[servicecenter] [varchar](100) NOT NULL,
	[OrigemSaida] [varchar](100) NOT NULL,
	[ciclo] [varchar](2) NOT NULL,
	[CompradorAusente] [int] NULL,
	[NegocioFechado] [int] NULL,
	[EnderecoRuim] [int] NULL,
	[CompradorRejeitado] [int] NULL,
	[ErroDeRota] [int] NULL,
	[BloqueadoPorPalavraChave] [int] NULL,
	[Bloqueado] [int] NULL,
	[Perdido] [int] NULL,
	[EnderecoNaoVisitado] [int] NULL,
	[EnderecoInacessivel] [int] NULL,
	[Cancelado] [int] NULL,
	[CompradorMudou] [int] NULL,
	[Outros] [int] NULL,
	[insucesso] [int] NULL,
	[DataReferencia] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idtransportadora] ASC,
	[servicecenter] ASC,
	[OrigemSaida] ASC,
	[ciclo] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
