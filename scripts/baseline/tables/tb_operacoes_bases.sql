-- ============================================================
-- BASELINE: dbo.tb_operacoes_bases
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_operacoes_bases]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_operacoes_bases](
	[opb_cd_operacoes_base] [int] IDENTITY(1,1) NOT NULL,
	[opb_cd_base] [int] NOT NULL,
	[opb_cd_operacao] [int] NOT NULL,
	[opb_in_status] [bit] NOT NULL,
	[opb_in_excluido] [bit] NOT NULL,
	[opb_cd_usuario_criacao] [int] NOT NULL,
	[opb_dh_criacao] [datetime] NOT NULL,
	[opb_cd_usuario_modificacao] [int] NOT NULL,
	[opb_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_operacoes_bases] PRIMARY KEY CLUSTERED 
(
	[opb_cd_operacoes_base] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_operacoes_bases] UNIQUE NONCLUSTERED 
(
	[opb_cd_base] ASC,
	[opb_cd_operacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
