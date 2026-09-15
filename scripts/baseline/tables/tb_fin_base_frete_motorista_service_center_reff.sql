-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_motorista_service_center_reff
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_motorista_service_center_reff]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_motorista_service_center_reff](
	[bfm_cd_transportadora] [int] NOT NULL,
	[bfm_cd_service_center] [varchar](50) NULL
) ON [PRIMARY]
GO
