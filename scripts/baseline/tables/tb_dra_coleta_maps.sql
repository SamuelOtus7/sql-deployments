-- ============================================================
-- BASELINE: dbo.tb_dra_coleta_maps
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_coleta_maps]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_coleta_maps](
	[dam_cd_coleta] [bigint] IDENTITY(1,1) NOT NULL,
	[dam_cd_transportadora] [varchar](20) NOT NULL,
	[dam_cd_rota] [varchar](30) NOT NULL,
	[dam_ds_url] [varchar](1000) NOT NULL,
	[dam_ds_km] [varchar](10) NOT NULL,
	[dam_vl_km] [decimal](10, 5) NULL,
	[dam_dh_coleta] [datetime] NOT NULL,
	[dam_dh_escrita] [datetime] NOT NULL,
	[dam_dh_processamento] [datetime] NULL,
	[dam_in_processado] [bit] NOT NULL,
	[dam_dh_referencia] [date] NULL,
	[dam_nm_origem] [varchar](30) NULL,
	[dam_cd_marketplace] [int] NULL,
	[dam_ip_servidor_coleta] [varchar](30) NULL,
 CONSTRAINT [pk_dra_coleta_maps] PRIMARY KEY CLUSTERED 
(
	[dam_cd_coleta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
