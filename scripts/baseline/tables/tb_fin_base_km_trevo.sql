-- ============================================================
-- BASELINE: dbo.tb_fin_base_km_trevo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_km_trevo]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_km_trevo](
	[bkt_cd_base_km_trevo] [int] IDENTITY(1,1) NOT NULL,
	[bkt_cd_transportadora] [int] NOT NULL,
	[bkt_cd_service_center] [varchar](50) NOT NULL,
	[latitude_svc] [decimal](18, 9) NULL,
	[longitude_svc] [decimal](18, 9) NULL,
	[bkt_nm_cidades] [varchar](1000) NOT NULL,
	[bkt_nm_ordem_ideal] [varchar](1000) NULL,
	[bkt_vl_km_ideal] [decimal](10, 5) NULL,
	[bkt_ds_link_google] [varchar](1000) NULL,
	[bkt_dh_processamento] [datetime] NULL,
	[bkt_in_processamento] [bit] NULL,
	[bkt_qt_cidades] [tinyint] NULL,
	[bkt_cidade_base] [varchar](100) NULL,
 CONSTRAINT [pk_fin_base_km_trevo] PRIMARY KEY CLUSTERED 
(
	[bkt_cd_base_km_trevo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
