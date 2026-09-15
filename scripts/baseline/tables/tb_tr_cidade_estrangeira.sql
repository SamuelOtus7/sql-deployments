-- ============================================================
-- BASELINE: dbo.tb_tr_cidade_estrangeira
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_cidade_estrangeira]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_cidade_estrangeira](
	[cidade_estrangeira] [int] NOT NULL,
	[cidade_estrangeira_nome] [varchar](255) NOT NULL,
	[estado_estrangeiro] [int] NOT NULL,
	[estado_estrangeiro_nome] [varchar](255) NOT NULL,
	[CreatedAt] [datetime] NOT NULL
) ON [PRIMARY]
GO
