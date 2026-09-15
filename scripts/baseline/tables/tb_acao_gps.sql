-- ============================================================
-- BASELINE: dbo.tb_acao_gps
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_acao_gps]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_acao_gps](
	[agp_cd_acao_gps] [int] IDENTITY(0,1) NOT NULL,
	[agp_dh_data_hora] [datetime] NOT NULL,
	[agp_cd_usuario] [int] NOT NULL,
	[agp_ds_acao] [char](1) NULL,
	[agp_dc_km] [decimal](10, 2) NULL,
	[agp_dh_duracao] [datetime] NULL,
	[agp_dc_latitude] [decimal](18, 12) NULL,
	[agp_dc_longitude] [decimal](18, 12) NOT NULL,
	[agp_ds_version_app] [varchar](20) NULL,
	[agp_ds_uuid] [varchar](255) NULL,
	[Timestamp] [datetime] NULL,
 CONSTRAINT [pk_acao_gps] PRIMARY KEY CLUSTERED 
(
	[agp_cd_acao_gps] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
