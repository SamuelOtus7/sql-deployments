-- ============================================================
-- BASELINE: dbo.tb_notification
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_notification]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_notification](
	[not_cd_notification] [int] IDENTITY(1,1) NOT NULL,
	[not_cd_smartphone] [int] NOT NULL,
	[not_ds_titulo] [varchar](100) NULL,
	[not_ds_mensagem] [varchar](max) NULL,
	[not_link_imagem] [varchar](max) NULL,
	[not_url_redirect] [varchar](max) NULL,
	[not_dh_notification] [datetime] NOT NULL,
	[not_dh_leitura] [datetime] NULL,
 CONSTRAINT [pk_tb_notification] PRIMARY KEY CLUSTERED 
(
	[not_cd_notification] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
