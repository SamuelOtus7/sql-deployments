-- ============================================================
-- BASELINE: dbo.tb_smartphone_id_usuario
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_smartphone_id_usuario]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_smartphone_id_usuario](
	[sid_cd_smartphone_id] [int] IDENTITY(1,1) NOT NULL,
	[sid_id_smartphone] [varchar](500) NOT NULL,
	[sid_cd_usuario] [int] NOT NULL,
	[sid_dh_criacao] [datetime] NOT NULL,
 CONSTRAINT [pk_tb_smartphone_id_usuario] PRIMARY KEY CLUSTERED 
(
	[sid_cd_smartphone_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
