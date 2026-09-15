-- ============================================================
-- BASELINE: dbo.tb_vitor_apagar
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_vitor_apagar]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_vitor_apagar](
	[rgp_cd_registro_gps] [int] IDENTITY(0,1) NOT NULL,
	[rgp_dh_data_hora] [datetime] NOT NULL,
	[rgp_cd_usuario] [int] NOT NULL,
	[rgp_dc_latitude] [decimal](18, 12) NULL,
	[rgp_dc_longitude] [decimal](18, 12) NOT NULL,
	[rgp_ds_uuid] [varchar](250) NULL
) ON [PRIMARY]
GO
