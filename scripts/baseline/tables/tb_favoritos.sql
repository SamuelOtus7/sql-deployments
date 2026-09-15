-- ============================================================
-- BASELINE: dbo.tb_favoritos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_favoritos]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_favoritos](
	[fav_cd_favorito] [int] IDENTITY(1,1) NOT NULL,
	[usr_cd_usuario] [int] NOT NULL,
	[fav_dh_inclusao] [datetime] NOT NULL,
	[ctr_cd_controller] [smallint] NOT NULL,
 CONSTRAINT [PK_favoritos] PRIMARY KEY CLUSTERED 
(
	[fav_cd_favorito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
