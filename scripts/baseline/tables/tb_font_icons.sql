-- ============================================================
-- BASELINE: dbo.tb_font_icons
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_font_icons]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_font_icons](
	[fnt_cd_font_icons] [smallint] IDENTITY(1,1) NOT NULL,
	[fnt_ds_nome] [varchar](50) NOT NULL,
	[fnt_ds_categoria] [varchar](30) NOT NULL,
	[fnt_ds_origem] [varchar](30) NOT NULL,
	[fnt_ds_classe] [varchar](50) NOT NULL,
	[fnt_ds_html] [varchar](100) NOT NULL,
	[fnt_dh_criacao] [datetime] NOT NULL,
	[fnt_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_font_icons] PRIMARY KEY CLUSTERED 
(
	[fnt_cd_font_icons] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
