-- ============================================================
-- BASELINE: dbo.tb_usuario_setor
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_usuario_setor]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_usuario_setor](
	[use_cd_usuario_setor] [int] IDENTITY(1,1) NOT NULL,
	[use_cd_setor] [int] NOT NULL,
	[use_cd_usuario] [int] NOT NULL,
	[use_cd_cliente] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[use_cd_usuario_setor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_usuario_setor] UNIQUE NONCLUSTERED 
(
	[use_cd_setor] ASC,
	[use_cd_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
