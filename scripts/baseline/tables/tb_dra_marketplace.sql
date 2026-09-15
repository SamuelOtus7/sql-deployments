-- ============================================================
-- BASELINE: dbo.tb_dra_marketplace
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_marketplace]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_marketplace](
	[mkp_cd_marketplace] [tinyint] IDENTITY(1,1) NOT NULL,
	[mkp_nm_marketplace] [varchar](30) NOT NULL,
 CONSTRAINT [pk_tb_dra_marketplace] PRIMARY KEY CLUSTERED 
(
	[mkp_cd_marketplace] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_dra_marketplace_nome] UNIQUE NONCLUSTERED 
(
	[mkp_nm_marketplace] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
