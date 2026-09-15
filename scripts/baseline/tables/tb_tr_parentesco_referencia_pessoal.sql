-- ============================================================
-- BASELINE: dbo.tb_tr_parentesco_referencia_pessoal
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_parentesco_referencia_pessoal]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_parentesco_referencia_pessoal](
	[parentesco_referencia_pessoal] [int] NOT NULL,
	[nome_parentesco_referencia_pessoal] [varchar](255) NOT NULL,
	[CreatedAt] [datetime] NOT NULL
) ON [PRIMARY]
GO
