-- ============================================================
-- BASELINE: dbo.tb_dra_classificacao_veiculo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_classificacao_veiculo]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_classificacao_veiculo](
	[cvl_cd_classificacao_veiculo] [int] IDENTITY(1,1) NOT NULL,
	[cvl_nm_classificacao_veiculo] [varchar](30) NOT NULL,
 CONSTRAINT [pk_tb_dra_classificacao_veiculo] PRIMARY KEY CLUSTERED 
(
	[cvl_cd_classificacao_veiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_dra_classificacao_veiculo] UNIQUE NONCLUSTERED 
(
	[cvl_nm_classificacao_veiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
