-- ============================================================
-- BASELINE: dbo.tb_spe_pacotes_v4
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_pacotes_v4]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_pacotes_v4](
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
	[RecebidoPor] [varchar](60) NULL,
	[CEP] [varchar](9) NULL,
	[Latitude] [varchar](15) NULL,
	[Longitude] [varchar](15) NULL,
	[URLImagem] [varchar](200) NULL,
	[DataAtualizacao] [datetime] NULL,
	[DataAtualizacaoDetalhe] [datetime] NULL,
	[Excluido] [bit] NOT NULL,
	[SubStatusAnterior] [varchar](60) NULL,
	[StatusPacote] [varchar](150) NULL,
 CONSTRAINT [PK_spe_pacotes_v4] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_spe_pacotes_v4] UNIQUE NONCLUSTERED 
(
	[CodigoPacote] ASC,
	[CodigoRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
