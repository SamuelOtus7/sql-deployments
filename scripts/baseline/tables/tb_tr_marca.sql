-- ============================================================
-- BASELINE: dbo.tb_tr_marca
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_marca]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_marca](
	[marca] [int] NOT NULL,
	[marca_nome] [varchar](255) NOT NULL,
	[marca_veiculo_brasileiro] [varchar](255) NULL,
	[marca_veiculo_estrangeiro] [varchar](255) NULL,
	[CreatedAt] [datetime] NOT NULL
) ON [PRIMARY]
GO
