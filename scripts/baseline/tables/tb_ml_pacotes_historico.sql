-- ============================================================
-- BASELINE: dbo.tb_ml_pacotes_historico
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_pacotes_historico]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_pacotes_historico](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPacote] [bigint] NOT NULL,
	[IdRota] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[DataColeta]  AS (CONVERT([date],[DataHoraColeta])) PERSISTED,
	[DataHoraEntrega] [datetime] NOT NULL,
	[TipoPacote] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[SubStatus] [varchar](50) NULL,
	[StatusEntrega] [varchar](50) NULL,
	[TipoEndereco] [varchar](30) NULL,
	[TipoEnderecoPreferencia] [varchar](30) NULL,
	[IdRotaOrigem] [bigint] NULL,
	[IdRotaDestino] [bigint] NULL,
	[QuantidadeReclamacoes] [int] NULL,
	[ForaAreaEntrega] [bit] NULL,
	[TemVolumoso] [bit] NULL,
	[NomeEtiqueta] [varchar](30) NULL,
	[Endereco] [varchar](100) NULL,
	[IdParada] [bigint] NOT NULL,
	[SequenciaParada] [int] NULL,
	[StatusParada] [varchar](50) NOT NULL,
	[EnderecoParada] [varchar](100) NULL,
	[TipoEnderecoParada] [varchar](30) NULL,
	[LatitudeEnderecoParada] [varchar](15) NULL,
	[LongitudeEnderecoParada] [varchar](15) NULL,
	[QuantidadePontosParada] [int] NULL,
	[DataAtualizacao] [datetime] NULL,
	[Excluido] [bit] NULL,
	[Cidade] [varchar](150) NULL,
	[DataCriacao] [datetime] NULL,
	[DistanciaPacote] [decimal](10, 2) NULL,
	[CEP] [int] NULL,
	[CidadeDistante] [int] NULL,
	[Cidade_distrito] [varchar](255) NULL,
 CONSTRAINT [pk_ml_pacotes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_ml_pacote_chave] UNIQUE NONCLUSTERED 
(
	[IdPacote] ASC,
	[IdRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
