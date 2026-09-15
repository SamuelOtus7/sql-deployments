-- ============================================================
-- BASELINE: dbo.tb_tr_cidades
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_cidades]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_cidades](
	[cidade] [int] NOT NULL,
	[estado] [int] NOT NULL,
	[cidade_nome] [varchar](255) NOT NULL,
	[estado_sigla] [varchar](2) NOT NULL,
	[CreatedAt] [datetime] NOT NULL
) ON [PRIMARY]
GO
