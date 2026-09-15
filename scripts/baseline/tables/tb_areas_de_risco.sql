-- ============================================================
-- BASELINE: dbo.tb_areas_de_risco
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_areas_de_risco]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_areas_de_risco](
	[SVC] [nvarchar](50) NULL,
	[CLUSTER] [nvarchar](50) NULL,
	[CEP_INICIO] [int] NULL,
	[CEP_FIM] [int] NULL,
	[CUSTO] [money] NULL,
	[RECEITA] [money] NULL,
	[STATUS] [nvarchar](50) NULL,
	[CEP_INICIO_TRATADO] [int] NULL,
	[CEP_FIM_TRATADO] [int] NULL
) ON [PRIMARY]
GO
