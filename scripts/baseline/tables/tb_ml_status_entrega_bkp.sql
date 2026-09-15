-- ============================================================
-- BASELINE: dbo.tb_ml_status_entrega_bkp
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_status_entrega_bkp]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_status_entrega_bkp](
	[se_cd_status] [int] IDENTITY(1,1) NOT NULL,
	[se_ds_status_entrega] [varchar](255) NOT NULL,
	[se_ds_classificacao] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
