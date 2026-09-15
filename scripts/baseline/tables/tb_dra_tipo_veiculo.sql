-- ============================================================
-- BASELINE: dbo.tb_dra_tipo_veiculo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_tipo_veiculo]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_tipo_veiculo](
	[tvl_cd_tipo_veiculo] [int] IDENTITY(1,1) NOT NULL,
	[tvl_nm_tipo_veiculo] [varchar](50) NOT NULL,
	[tvl_cd_classificacao_veiculo] [int] NULL,
 CONSTRAINT [pk_tb_dra_tipo_veiculo] PRIMARY KEY CLUSTERED 
(
	[tvl_cd_tipo_veiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_dra_tipo_veiculo] UNIQUE NONCLUSTERED 
(
	[tvl_nm_tipo_veiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
