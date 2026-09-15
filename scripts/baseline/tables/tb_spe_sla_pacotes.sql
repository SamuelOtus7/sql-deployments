-- ============================================================
-- BASELINE: dbo.tb_spe_sla_pacotes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_sla_pacotes]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_sla_pacotes](
	[CodSlaPacote] [int] IDENTITY(1,1) NOT NULL,
	[idtransportadora] [int] NULL,
	[DiaDaSemana] [varchar](15) NULL,
	[DataVencimento] [datetime] NULL,
	[DataHoraEntrega] [datetime] NULL,
	[DataInicioSLA] [datetime] NULL,
	[DiasEntrega] [int] NULL,
	[Motorista] [varchar](200) NULL,
	[TentativaEntrega] [int] NULL,
	[CodigoPacote] [varchar](50) NULL,
	[CodigoRota] [varchar](50) NULL,
	[Nomehub] [varchar](50) NULL,
	[StatusEntregaAnterior] [varchar](50) NULL,
	[StatusEntrega] [varchar](50) NULL,
	[SubStatus] [varchar](50) NULL,
	[cidadade] [varchar](60) NULL,
	[SLAIrisys] [varchar](20) NULL,
 CONSTRAINT [PK_tb_spe_sla_pacotes] PRIMARY KEY CLUSTERED 
(
	[CodSlaPacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_spe_sla_pacotes] UNIQUE NONCLUSTERED 
(
	[idtransportadora] ASC,
	[DataVencimento] ASC,
	[DataInicioSLA] ASC,
	[CodigoPacote] ASC,
	[CodigoRota] ASC,
	[TentativaEntrega] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
