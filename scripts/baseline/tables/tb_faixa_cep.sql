-- ============================================================
-- BASELINE: dbo.tb_faixa_cep
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_faixa_cep]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_faixa_cep](
	[idFaixaCep] [int] IDENTITY(1,1) NOT NULL,
	[CepInicio] [int] NOT NULL,
	[CepFim] [int] NOT NULL,
	[estado] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
