-- ============================================================
-- BASELINE: dbo.tb_dra_bases
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_bases]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_bases](
	[dab_cd_base] [int] IDENTITY(1,1) NOT NULL,
	[dab_cd_transportadora] [int] NOT NULL,
	[dab_cd_service_center] [varchar](50) NOT NULL,
	[dab_nm_base] [varchar](30) NOT NULL,
	[dab_nm_cidade] [varchar](30) NOT NULL,
	[dab_nm_estado] [char](2) NULL,
 CONSTRAINT [pk_tb_dra_bases] PRIMARY KEY CLUSTERED 
(
	[dab_cd_base] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
