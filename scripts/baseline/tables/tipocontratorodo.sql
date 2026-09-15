-- ============================================================
-- BASELINE: dbo.tipocontratorodo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tipocontratorodo]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tipocontratorodo](
	[SVC] [nvarchar](50) NOT NULL,
	[Cidade] [nvarchar](1) NULL,
	[Tipo_Veículo] [nvarchar](50) NOT NULL,
	[Tipo_Contrato] [nvarchar](50) NOT NULL,
	[Valor_Início_faixa] [smallint] NOT NULL,
	[Valor_Fim_faixa] [int] NOT NULL,
	[Valor_Frete] [float] NOT NULL,
	[Valor_Frete_PM] [money] NOT NULL,
	[Valor_Frete_Fixo] [nvarchar](1) NULL,
	[Data_início_vigência] [date] NOT NULL,
	[Data_fim_vigência] [nvarchar](1) NULL
) ON [PRIMARY]
GO
