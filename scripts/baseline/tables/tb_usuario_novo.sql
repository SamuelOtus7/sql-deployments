-- ============================================================
-- BASELINE: dbo.tb_usuario_novo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_usuario_novo]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_usuario_novo](
	[nome] [varchar](500) NULL,
	[email] [varchar](500) NULL,
	[svc] [varchar](500) NULL
) ON [PRIMARY]
GO
