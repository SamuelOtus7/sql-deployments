-- ============================================================
-- BASELINE: dbo.tb_rotas_50mais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rotas_50mais]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rotas_50mais](
	[Rota] [varchar](max) NULL,
	[TrackingNumber] [varchar](max) NULL,
	[DataPrestacaoServico] [varchar](max) NULL,
	[Hub] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
