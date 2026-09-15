-- ============================================================
-- BASELINE: dbo.tb_spe_pacotes_v5
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_pacotes_v5]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_pacotes_v5](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CodigoRota] [varchar](30) NULL,
	[CodigoPacote] [varchar](30) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[DataHoraColeta] [datetime] NULL,
	[DataHoraEntrega] [datetime] NULL,
	[StatusEntrega] [varchar](50) NULL,
	[SubStatus] [varchar](60) NULL,
	[IdMotorista] [int] NULL,
	[RecebidoPor] [varchar](150) NULL,
	[CEP] [varchar](9) NULL,
	[Latitude] [varchar](15) NULL,
	[Longitude] [varchar](15) NULL,
	[URLImagem] [varchar](200) NULL,
	[DataAtualizacao] [datetime] NULL,
	[DataAtualizacaoDetalhe] [datetime] NULL,
	[Excluido] [bit] NOT NULL,
	[SubStatusAnterior] [varchar](60) NULL,
	[StatusPacote] [varchar](150) NULL,
	[Cidade] [varchar](200) NULL,
	[CidadeDistante] [int] NULL,
	[StatusLost] [int] NULL,
 CONSTRAINT [pk_spe_pacotes_v5] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
