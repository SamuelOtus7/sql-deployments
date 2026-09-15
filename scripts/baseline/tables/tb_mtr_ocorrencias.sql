-- ============================================================
-- BASELINE: dbo.tb_mtr_ocorrencias
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_mtr_ocorrencias]    Script Date: 14/09/2026 12:12:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_mtr_ocorrencias](
	[Id] [bigint] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[CodigoOcorrencia] [bigint] NOT NULL,
	[NumeroPedido] [bigint] NOT NULL,
	[NumeroRemessa] [varchar](30) NULL,
	[DescricaoOcorrencia] [varchar](100) NULL,
	[DataHoraOcorrencia] [datetime] NULL,
	[PlacaVeiculo] [varchar](10) NULL,
	[CpfMotorista] [varchar](20) NULL,
	[CnpjCpfDestinatario] [varchar](20) NULL,
	[Iccid] [varchar](30) NULL,
	[Observacao] [varchar](100) NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Excluido] [int] NOT NULL,
 CONSTRAINT [pk_mtr_ocorrencias] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
