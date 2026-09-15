-- ============================================================
-- BASELINE: dbo.tb_ml_hist_insucesso
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_hist_insucesso]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_hist_insucesso](
	[CodInsucesso] [int] IDENTITY(1,1) NOT NULL,
	[IdTransportadora] [int] NULL,
	[DataReferencia] [date] NULL,
	[DataAtualizacao] [datetime] NULL,
	[IdRota] [int] NULL,
	[IdPacote] [bigint] NULL,
	[NomeMotorista] [varchar](100) NULL,
	[ServiceCenter] [varchar](100) NULL,
	[XPT] [varchar](100) NULL,
	[NomeEtiqueta] [varchar](100) NULL,
	[StatusEntrega] [varchar](100) NULL,
	[SubStatus] [varchar](100) NULL,
	[statusrota] [varchar](100) NULL,
	[Endereco] [varchar](100) NULL,
	[EnderecoParada] [varchar](100) NULL,
	[QuantidadeReclamacoes] [int] NULL,
	[ForaAreaEntrega] [int] NULL,
	[Revertido] [bit] NULL,
	[RevertidoOutraRota] [bit] NULL,
	[IdRotaRevertida] [int] NULL,
	[DataReversao] [date] NULL,
	[HoraReversao] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CodInsucesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
