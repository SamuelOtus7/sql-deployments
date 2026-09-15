-- ============================================================
-- BASELINE: dbo.tb_spe_pacotes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_pacotes]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_pacotes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdRota] [varchar](30) NULL,
	[IdPacote] [int] NULL,
	[CodigoPacote] [varchar](30) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[IdStation] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[DataHoraColeta] [datetime] NULL,
	[DataHoraEntrega] [datetime] NULL,
	[StatusEntrega] [varchar](50) NULL,
	[SubStatus] [varchar](60) NULL,
	[IdMotorista] [int] NULL,
	[RecebidoPor] [varchar](60) NULL,
	[Latitude] [varchar](15) NULL,
	[Longitude] [varchar](15) NULL,
	[URLImagem] [varchar](200) NULL,
	[DataAtualizacao] [datetime] NULL,
 CONSTRAINT [PK_spe_pacotes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_spe_pacotes] UNIQUE NONCLUSTERED 
(
	[CodigoPacote] ASC,
	[IdRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
