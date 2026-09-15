-- ============================================================
-- BASELINE: dbo.tb_tr_ficha_detalhes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_ficha_detalhes]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_ficha_detalhes](
	[Ficha] [nvarchar](255) NOT NULL,
	[DataFichaTermino] [datetime] NULL,
	[Termino] [datetime] NULL,
	[SituacaoCadastro] [nvarchar](255) NULL,
	[SituacaoCadastroDescricao] [nvarchar](255) NULL,
	[CodigoAprovacao] [nvarchar](255) NULL,
	[EmpresaTransportadora] [nvarchar](255) NULL,
	[EmpresaUnidadeTransporte] [nvarchar](255) NULL,
	[MotoristaNome] [nvarchar](255) NULL,
	[MotoristaCpfDni] [nvarchar](255) NULL,
	[MotoristaRg] [nvarchar](255) NULL,
	[VeiculoCavaloPlaca] [nvarchar](255) NULL,
	[VeiculoCavaloMarca] [nvarchar](255) NULL,
	[VeiculoCavaloModelo] [nvarchar](255) NULL,
	[VeiculoCavaloProprietario] [nvarchar](255) NULL,
	[VeiculoCavaloCpfCnpj] [nvarchar](255) NULL,
	[VeiculoReboquePlaca] [nvarchar](255) NULL,
	[VeiculoReboqueMarca] [nvarchar](255) NULL,
	[VeiculoReboqueModelo] [nvarchar](255) NULL,
	[VeiculoReboqueProprietario] [nvarchar](255) NULL,
	[VeiculoReboqueCpfCnpj] [nvarchar](255) NULL,
	[VencimentoDataVencimento] [datetime] NULL,
	[RecomendacaoGeral] [nvarchar](4000) NULL,
	[Recomendacao0] [nvarchar](4000) NULL,
	[Recomendacao1] [nvarchar](4000) NULL,
	[ResponsabilidadeEmpresa] [nvarchar](4000) NULL,
	[ResponsabilidadeServico] [nvarchar](4000) NULL,
	[IdTenant] [int] NULL
) ON [PRIMARY]
GO
