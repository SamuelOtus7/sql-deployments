-- ============================================================
-- BASELINE: dbo.tb_usuarios_upload
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_usuarios_upload]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_usuarios_upload](
	[HUB] [varchar](5000) NULL,
	[NOME] [varchar](5000) NULL,
	[CPF] [varchar](5000) NULL,
	[CNPJ] [varchar](5000) NULL,
	[TELEFONE] [varchar](5000) NULL,
	[EMAIL] [varchar](5000) NULL,
	[FAVORECIDO] [varchar](5000) NULL
) ON [PRIMARY]
GO
