-- ============================================================
-- BASELINE: dbo.import_prefatura_raw
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[import_prefatura_raw]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[import_prefatura_raw](
	[Tipo de contrato] [nvarchar](100) NULL,
	[Service Center] [nvarchar](100) NULL,
	[Cidade] [nvarchar](200) NULL,
	[Tipo de veículo] [nvarchar](200) NULL,
	[Inicio da Faixa] [nvarchar](100) NULL,
	[Fim da Faixa ] [nvarchar](100) NULL,
	[Valor do Frete] [nvarchar](100) NULL,
	[Valor do frete PM] [nvarchar](100) NULL,
	[Valor do Frete Fixo] [nvarchar](100) NULL
) ON [PRIMARY]
GO
