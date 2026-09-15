-- ============================================================
-- BASELINE: dbo.tb_grupos_whatsapp
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_grupos_whatsapp]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_grupos_whatsapp](
	[tgw_cd_grupos_whatsapp] [int] IDENTITY(1,1) NOT NULL,
	[tgw_nm_grupo] [varchar](100) NOT NULL,
	[tgw_in_ativo] [bit] NULL,
	[tgw_gui_grupo] [varchar](100) NULL,
	[tgw_cd_cliente] [int] NULL,
 CONSTRAINT [pk_grupos_whatsapp] PRIMARY KEY CLUSTERED 
(
	[tgw_cd_grupos_whatsapp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
