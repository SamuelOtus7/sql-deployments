-- ============================================================
-- BASELINE: dbo.tb_fin_pagamento_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_pagamento_motorista]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_pagamento_motorista](
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NULL,
	[Mes] [int] NULL,
	[Quinzena] [int] NULL,
	[Data] [date] NOT NULL,
	[serviceCenter] [varchar](50) NOT NULL,
	[CidadeReferencia] [varchar](150) NULL,
	[Placa] [varchar](11) NOT NULL,
	[TipoVeiculo] [varchar](100) NULL,
	[NomeMotorista] [varchar](100) NOT NULL,
	[IdRota] [varchar](50) NOT NULL,
	[CicloPM] [varchar](2) NOT NULL,
	[TotalPacotes] [smallint] NOT NULL,
	[QuantidadePontos] [smallint] NOT NULL,
	[Saida] [decimal](8, 2) NOT NULL,
	[ADD] [decimal](19, 2) NULL,
	[RISCO] [decimal](7, 2) NOT NULL,
	[AJUDANTE] [decimal](7, 2) NOT NULL,
	[ASCRESC] [int] NOT NULL,
	[CUSTO_TOTAL] [decimal](23, 2) NULL,
	[SaidaKmMotorista] [decimal](8, 2) NULL,
	[SaidaKm0a100] [decimal](8, 2) NULL,
	[SaidaKmPreFatura] [decimal](8, 2) NULL,
	[AdicionalInsucessos] [decimal](7, 2) NULL,
	[NumeroRota] [int] NULL,
	[TipoVeiculoCad] [varchar](50) NULL,
	[FaixaKM] [varchar](30) NULL,
	[KmColetado] [decimal](10, 2) NULL,
 CONSTRAINT [PK_tb_fin_pagamento_motorista] PRIMARY KEY CLUSTERED 
(
	[IdTransportadora] ASC,
	[IdRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
