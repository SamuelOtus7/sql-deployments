-- ============================================================
-- BASELINE: dbo.tb_pacote_insert
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pacote_insert]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pacote_insert](
	[Id] [int] NOT NULL,
	[IdPacote] [bigint] NOT NULL,
	[IdRota] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[DataColeta] [date] NULL,
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
	[DataCriacao] [datetime] NULL
) ON [PRIMARY]
GO
