-- ============================================================
-- BASELINE: dbo.tb_tr_lista_fichas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_lista_fichas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_lista_fichas](
	[ficha] [int] NOT NULL,
	[situacao] [varchar](255) NOT NULL,
	[criado] [datetime] NOT NULL,
	[termino] [datetime] NOT NULL,
	[idTenant] [int] NULL
) ON [PRIMARY]
GO
