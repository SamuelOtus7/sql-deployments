-- ============================================================
-- BASELINE: dbo.AcrescimosDescontos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[AcrescimosDescontos]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AcrescimosDescontos](
	[DATA] [varchar](max) NULL,
	[OPERAÇÃO] [varchar](max) NULL,
	[MOTORISTA] [varchar](max) NULL,
	[VEICULO] [varchar](max) NULL,
	[PLACA] [varchar](max) NULL,
	[ID] [varchar](max) NULL,
	[VALOR_DESCONTO] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
