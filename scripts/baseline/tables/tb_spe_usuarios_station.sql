-- ============================================================
-- BASELINE: dbo.tb_spe_usuarios_station
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_usuarios_station]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_usuarios_station](
	[suh_cd_usuario_station] [int] IDENTITY(1,1) NOT NULL,
	[suh_cd_transportadora] [int] NOT NULL,
	[suh_ds_usuario] [varchar](100) NOT NULL,
	[suh_cd_station] [int] NOT NULL,
	[suh_ds_station] [varchar](250) NOT NULL,
	[suh_status] [bit] NULL,
 CONSTRAINT [pk_spe_usuarios_hub] PRIMARY KEY CLUSTERED 
(
	[suh_cd_usuario_station] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
