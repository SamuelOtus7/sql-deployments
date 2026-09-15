-- ============================================================
-- BASELINE: dbo.stg_FrotaFixa
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_FrotaFixa]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_FrotaFixa](
	[PLACA] [varchar](max) NULL,
	[SVC] [varchar](max) NULL,
	[TIPO VEICULO] [varchar](max) NULL,
	[FROTA FIXA] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
