-- ============================================================
-- BASELINE: dbo.tb_tr_modelo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_modelo]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_modelo](
	[modelo] [int] NOT NULL,
	[modelo_nome] [varchar](255) NOT NULL,
	[marca] [int] NOT NULL,
	[modelo_veiculo_brasileiro] [char](1) NOT NULL,
	[modelo_veiculo_estrangeiro] [char](1) NOT NULL,
	[CreatedAt] [datetime] NOT NULL
) ON [PRIMARY]
GO
