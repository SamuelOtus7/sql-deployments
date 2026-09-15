-- ============================================================
-- BASELINE: dbo.tb_mtr_pedidos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_mtr_pedidos]    Script Date: 14/09/2026 12:12:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_mtr_pedidos](
	[IdTransportadora] [int] NOT NULL,
	[NumeroPedido] [bigint] NOT NULL,
	[NumeroRemessa] [varchar](30) NULL,
	[CnpjCpfDestinatario] [bigint] NULL,
	[NomeDestinatario] [varchar](60) NULL,
	[Telefone] [varchar](20) NULL,
	[Endereco] [varchar](100) NULL,
	[NumeroEndereco] [varchar](10) NULL,
	[Bairro] [varchar](60) NULL,
	[Cidade] [varchar](60) NULL,
	[Estado] [char](2) NULL,
	[Complemento] [varchar](60) NULL,
	[ObservacaoEndereco] [varchar](100) NULL,
	[CEP] [varchar](8) NULL,
	[QuantidadeVolumes] [int] NULL,
	[DataPrevistaEntregaFim] [datetime] NULL,
	[NomeFilial] [varchar](60) NULL,
	[TipoEntrega] [varchar](60) NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Excluido] [int] NOT NULL,
 CONSTRAINT [PK_tb_mtr_pedidos] PRIMARY KEY CLUSTERED 
(
	[IdTransportadora] ASC,
	[NumeroPedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
