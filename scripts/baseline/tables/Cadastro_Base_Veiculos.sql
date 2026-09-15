-- ============================================================
-- BASELINE: dbo.Cadastro_Base_Veiculos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Cadastro_Base_Veiculos]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cadastro_Base_Veiculos](
	[Placa] [varchar](255) NULL,
	[Ano] [varchar](255) NULL,
	[Motorista] [varchar](255) NULL,
	[Tipo] [varchar](255) NULL,
	[SVC] [varchar](255) NULL,
	[Observacao] [varchar](255) NULL
) ON [PRIMARY]
GO
