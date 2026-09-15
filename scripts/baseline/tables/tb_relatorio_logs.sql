-- ============================================================
-- BASELINE: dbo.tb_relatorio_logs
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_relatorio_logs]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_relatorio_logs](
	[rel_cd_relatorio_log] [int] IDENTITY(1,1) NOT NULL,
	[rel_cd_usuario] [int] NOT NULL,
	[rel_cd_relatorio] [int] NOT NULL,
	[rel_dh_acesso] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_relatorio_log] PRIMARY KEY CLUSTERED 
(
	[rel_cd_relatorio_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
