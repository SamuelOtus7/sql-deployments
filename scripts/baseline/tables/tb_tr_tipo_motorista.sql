-- ============================================================
-- BASELINE: dbo.tb_tr_tipo_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_tipo_motorista]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_tipo_motorista](
	[tr_nr_tipo_motorista] [int] NOT NULL,
	[tr_nm_tipo_motorista] [varchar](150) NOT NULL,
	[CreatedAt] [datetime] NOT NULL
) ON [PRIMARY]
GO
