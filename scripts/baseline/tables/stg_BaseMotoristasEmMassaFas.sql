-- ============================================================
-- BASELINE: dbo.stg_BaseMotoristasEmMassaFas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_BaseMotoristasEmMassaFas]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_BaseMotoristasEmMassaFas](
	[BASE] [varchar](max) NULL,
	[CPF] [varchar](max) NULL,
	[NOME DO MOTORISTA ] [varchar](max) NULL,
	[PLACA] [varchar](max) NULL,
	[RENAVAM ] [varchar](max) NULL,
	[PERFIL] [varchar](max) NULL,
	[TELEFONE] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
