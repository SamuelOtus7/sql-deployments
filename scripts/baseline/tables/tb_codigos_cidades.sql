-- ============================================================
-- BASELINE: dbo.tb_codigos_cidades
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_codigos_cidades]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_codigos_cidades](
	[cid_cd_cidade] [int] IDENTITY(1,1) NOT NULL,
	[cid_cd_estado] [bigint] NULL,
	[cid_cd_municipio] [varchar](max) NULL,
	[cid_ds_cidade] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[cid_cd_cidade] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
