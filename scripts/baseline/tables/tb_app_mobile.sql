-- ============================================================
-- BASELINE: dbo.tb_app_mobile
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_app_mobile]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_app_mobile](
	[amo_cd_app_mobile] [int] IDENTITY(1,1) NOT NULL,
	[amo_cd_key] [varchar](300) NULL,
	[usr_cd_usuario] [int] NOT NULL,
	[amo_ds_plataforma] [varchar](30) NOT NULL,
 CONSTRAINT [tb_app_mobile_pk] PRIMARY KEY CLUSTERED 
(
	[amo_cd_app_mobile] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
