-- ============================================================
-- BASELINE: dbo.tb_fin_faturas_excel
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_faturas_excel]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_faturas_excel](
	[empresaempresa] [int] NULL,
	[empresafaturas] [int] NOT NULL,
	[RazaoFornecedor] [varchar](50) NULL,
	[CNPJFornecedor] [varchar](25) NULL,
	[EnderecoFornecedor] [varchar](200) NULL,
	[InscricaoEstadualFornecedor] [varchar](15) NULL,
	[MunicipioFornecedor] [varchar](200) NULL,
	[NomeCliente] [nvarchar](100) NULL,
	[EnderecoCliente] [nvarchar](255) NULL,
	[MunicipioCliente] [nvarchar](100) NULL,
	[CNPJCliente] [float] NULL,
	[InscricaoEstadualCliente] [nvarchar](50) NULL,
	[PracaPagamento] [nvarchar](100) NULL,
	[DataVencimento] [date] NULL,
	[DataEmissao] [date] NULL,
	[Fatura] [varchar](50) NOT NULL,
	[ValorFatura] [decimal](18, 2) NOT NULL,
	[Observacao] [nvarchar](max) NULL,
	[ValorExtenso] [nvarchar](max) NULL,
	[Descontos] [decimal](18, 0) NULL,
	[Correcao] [decimal](18, 0) NULL,
	[IDFATURA] [int] IDENTITY(1,1) NOT NULL,
	[LogoCliente] [varchar](2000) NULL,
	[PeriodoApurado] [varchar](10) NOT NULL,
	[CodigoServico] [varchar](9) NOT NULL,
	[DataApurada] [varchar](24) NOT NULL,
	[ProdutoServico] [varchar](18) NOT NULL,
	[IdTomador] [float] NULL,
	[TipoServico] [varchar](18) NOT NULL,
	[IdPO] [varchar](20) NOT NULL,
	[ValorBruto] [decimal](18, 2) NOT NULL,
	[ValorDesconto] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
