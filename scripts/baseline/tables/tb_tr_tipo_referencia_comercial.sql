-- ============================================================
-- BASELINE: dbo.tb_tr_tipo_referencia_comercial
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_tipo_referencia_comercial]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_tipo_referencia_comercial](
	[tipo_referencia_comercial] [int] NOT NULL,
	[nome_tipo_referencia_comercial] [varchar](255) NOT NULL,
	[CreatedAt] [datetime] NOT NULL
) ON [PRIMARY]
GO
