-- ============================================================
-- BASELINE: dbo.stg_BaseFretePRA
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_BaseFretePRA]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_BaseFretePRA](
	[Service Center] [varchar](max) NULL,
	[Estado] [varchar](max) NULL,
	[Tipo de veículo] [varchar](max) NULL,
	[Início da Faixa] [varchar](max) NULL,
	[Fim da Faixa] [varchar](max) NULL,
	[Valor do Frete] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
