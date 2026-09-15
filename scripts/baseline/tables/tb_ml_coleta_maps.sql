-- ============================================================
-- BASELINE: dbo.tb_ml_coleta_maps
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_coleta_maps]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_coleta_maps](
	[cmm_cd_coleta] [bigint] IDENTITY(1,1) NOT NULL,
	[cmm_cd_transportadora] [varchar](20) NOT NULL,
	[cmm_cd_rota] [varchar](20) NOT NULL,
	[cmm_ds_url] [varchar](1000) NOT NULL,
	[cmm_ds_km] [varchar](10) NOT NULL,
	[cmm_vl_km] [decimal](10, 5) NULL,
	[cmm_dh_coleta] [datetime] NOT NULL,
	[cmm_dh_escrita] [datetime] NOT NULL,
	[cmm_dh_processamento] [datetime] NULL,
	[cmm_in_processado] [bit] NOT NULL,
	[cmm_dh_referencia] [date] NULL,
	[cmm_nm_origem] [varchar](30) NULL,
	[cmm_cd_marketplace] [int] NULL,
 CONSTRAINT [pk_ml_coleta_maps] PRIMARY KEY CLUSTERED 
(
	[cmm_cd_coleta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
