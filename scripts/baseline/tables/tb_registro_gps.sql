-- ============================================================
-- BASELINE: dbo.tb_registro_gps
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_registro_gps]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_registro_gps](
	[rgp_cd_registro_gps] [int] IDENTITY(0,1) NOT NULL,
	[rgp_dh_data_hora] [datetime] NOT NULL,
	[rgp_cd_usuario] [int] NOT NULL,
	[rgp_dc_latitude] [decimal](18, 12) NULL,
	[rgp_dc_longitude] [decimal](18, 12) NOT NULL,
	[rgp_ds_uuid] [varchar](250) NULL,
	[rgp_in_coordenada_fantasma] [bit] NOT NULL,
 CONSTRAINT [pk_registro_gps] PRIMARY KEY CLUSTERED 
(
	[rgp_cd_registro_gps] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
