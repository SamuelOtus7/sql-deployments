-- ============================================================
-- BASELINE: dbo.tb_bases_profissionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_bases_profissionais]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_bases_profissionais](
	[tbp_cd_base] [int] NOT NULL,
	[tbp_cd_profissional] [int] NOT NULL,
	[tbp_dt_criacao] [datetime] NOT NULL,
	[tbp_dt_modificacao] [datetime] NOT NULL,
	[tbp_cd_base_profissional] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_tb_bases_profissionais] PRIMARY KEY CLUSTERED 
(
	[tbp_cd_base_profissional] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
