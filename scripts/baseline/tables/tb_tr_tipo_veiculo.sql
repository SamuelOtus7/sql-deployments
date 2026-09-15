-- ============================================================
-- BASELINE: dbo.tb_tr_tipo_veiculo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tr_tipo_veiculo]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tr_tipo_veiculo](
	[tipo_veiculo] [char](1) NOT NULL,
	[tipo_veiculo_nome] [varchar](255) NOT NULL,
	[CreatedAt] [datetime] NOT NULL
) ON [PRIMARY]
GO
