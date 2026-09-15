-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_motorista_cte
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_motorista_cte]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_motorista_cte](
	[fmc_cd_base_frete_motorista_cte] [int] IDENTITY(1,1) NOT NULL,
	[fmc_cd_cliente] [int] NOT NULL,
	[fmc_cd_cliente_transportadora] [int] NOT NULL,
	[fmc_cd_tipo_contrato] [int] NOT NULL,
	[fmc_data_inicio_vigencia] [date] NOT NULL,
	[fmc_data_fim_vigencia] [date] NULL,
	[fmc_vl_perc_frete] [decimal](5, 4) NOT NULL,
	[fmc_vl_perc_frete_bonus] [decimal](5, 4) NULL,
 CONSTRAINT [PK_tb_fin_base_frete_motorista_cte] PRIMARY KEY CLUSTERED 
(
	[fmc_cd_base_frete_motorista_cte] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_fin_base_frete_motorista_cte] UNIQUE NONCLUSTERED 
(
	[fmc_cd_cliente] ASC,
	[fmc_cd_cliente_transportadora] ASC,
	[fmc_cd_tipo_contrato] ASC,
	[fmc_data_inicio_vigencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
