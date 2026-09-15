-- ============================================================
-- BASELINE: dbo.tb_dim_faixa_km
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dim_faixa_km]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dim_faixa_km](
	[cd_faixa_km] [int] IDENTITY(1,1) NOT NULL,
	[ds_faixa_original] [varchar](20) NOT NULL,
	[km_inicio] [int] NULL,
	[km_fim] [int] NULL,
	[ds_descricao] [varchar](100) NULL,
	[dt_criacao] [datetime] NOT NULL,
	[dt_atualizacao] [datetime] NOT NULL,
	[in_ativo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[cd_faixa_km] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_dim_faixa_km_original] UNIQUE NONCLUSTERED 
(
	[ds_faixa_original] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
