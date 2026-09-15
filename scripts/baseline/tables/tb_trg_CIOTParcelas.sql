-- ============================================================
-- BASELINE: dbo.tb_trg_CIOTParcelas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_trg_CIOTParcelas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_trg_CIOTParcelas](
	[CodOperacaoTransporteParcela] [int] IDENTITY(1,1) NOT NULL,
	[IdCiot] [int] NULL,
	[IdOperacaoTransporte] [int] NULL,
	[DescricaoParcela] [varchar](100) NULL,
	[Valor] [decimal](10, 2) NULL,
	[NumeroParcela] [int] NULL,
	[DataVencimento] [datetime] NULL,
	[TipoDaParcela] [int] NULL,
	[FormaPagamento] [int] NULL,
	[CartaoPagamento] [varchar](50) NULL,
	[CodigoBanco] [varchar](10) NULL,
	[AgenciaDeposito] [varchar](20) NULL,
	[ContaDeposito] [varchar](20) NULL,
	[DigitoContaDeposito] [varchar](5) NULL,
	[ProcessarAutomaticamente] [bit] NULL,
	[FlagContaPoupanca] [bit] NULL,
	[VariacaoContaPoupanca] [varchar](50) NULL,
	[ItemFinanceiroParcela] [int] NULL,
	[IdOperacaoTransporteParcela] [int] NULL,
	[Mensagem] [varchar](200) NULL,
 CONSTRAINT [PK_tb_trg_C__A9BEA28E1FD652F3] PRIMARY KEY CLUSTERED 
(
	[CodOperacaoTransporteParcela] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
