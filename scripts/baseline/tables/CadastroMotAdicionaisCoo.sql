-- ============================================================
-- BASELINE: dbo.CadastroMotAdicionaisCoo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[CadastroMotAdicionaisCoo]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CadastroMotAdicionaisCoo](
	[Tipo_de_contrato] [nvarchar](50) NOT NULL,
	[Service_Center] [nvarchar](50) NOT NULL,
	[Faixa_de_KM] [varchar](50) NOT NULL,
	[Fim_Faixa_de_KM] [varchar](50) NOT NULL,
	[Tipo_de_veículo] [varchar](50) NOT NULL,
	[Tipo_adicional_domingo] [nvarchar](50) NOT NULL,
	[Valor_adicional_domingo] [varchar](50) NOT NULL,
	[Tipo_adicional_ciclo_PM] [varchar](50) NOT NULL,
	[Valor_adicional_ciclo] [varchar](50) NOT NULL,
	[Tipo_adicional_ajudante] [varchar](50) NOT NULL,
	[Valor_adicional_ajudante] [varchar](50) NOT NULL,
	[Tipo_adicional_risco] [varchar](50) NOT NULL,
	[Valor_adicional_risco] [varchar](50) NOT NULL,
	[Valor_adicional_pool] [varchar](50) NOT NULL,
	[Valor_adicional_0_60] [varchar](50) NOT NULL,
	[Valor_adicional_61_90] [varchar](50) NOT NULL,
	[Valor_adicional_acima_de_90] [varchar](50) NOT NULL,
	[Tipo_de_adicional_itens] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO
