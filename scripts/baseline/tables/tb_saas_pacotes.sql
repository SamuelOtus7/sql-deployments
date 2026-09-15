-- ============================================================
-- BASELINE: dbo.tb_saas_pacotes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_saas_pacotes]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_saas_pacotes](
	[CodSaasPacote] [int] IDENTITY(1,1) NOT NULL,
	[IdEntrega] [bigint] NULL,
	[IdInternoRota] [int] NULL,
	[DataReferencia] [date] NULL,
	[StatusEntrega] [varchar](60) NULL,
	[SubStatus] [varchar](60) NULL,
	[TipoEndereco] [varchar](60) NULL,
	[Ambulancia] [int] NULL,
	[StatusGeralEntrega] [varchar](12) NULL,
	[DataHoraEntrega] [datetime] NULL,
	[QuantidadeReclamacoes] [int] NULL,
	[EnderecoParada] [varchar](100) NULL,
	[idtransportadora] [int] NULL
) ON [PRIMARY]
GO
