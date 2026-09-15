-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_transportadora
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_transportadora]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_transportadora](
	[bft_cd_base_frete_transportadora] [int] IDENTITY(1,1) NOT NULL,
	[bft_cd_transportadora] [int] NOT NULL,
	[bft_cd_service_center] [varchar](100) NULL,
	[bft_estado] [varchar](2) NULL,
	[bft_cd_tipo_veiculo] [int] NOT NULL,
	[bft_vl_inicio_faixa] [int] NULL,
	[bft_vl_fim_faixa] [int] NULL,
	[bft_vl_frete] [decimal](7, 2) NULL,
	[bft_cd_codigo_cliente] [int] NULL,
	[bft_data_inicio] [date] NULL,
	[bft_data_fim] [date] NULL,
	[bft_nm_cidade] [varchar](150) NULL,
	[bft_vl_frete_pm] [decimal](7, 2) NULL,
	[bft_cd_operacao] [int] NOT NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[bft_cd_tipo_calculo] [int] NULL,
	[bft_vl_insucesso] [decimal](7, 2) NULL,
	[bft_vl_frete_dom] [decimal](7, 2) NULL,
	[bft_vl_frete_pm_dom] [decimal](7, 2) NULL,
	[bft_data_inicio_vigencia] [date] NULL,
	[bft_data_fim_vigencia] [date] NULL,
 CONSTRAINT [pk_fin_base_frete_transportadora] PRIMARY KEY CLUSTERED 
(
	[bft_cd_base_frete_transportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY],
 CONSTRAINT [UQ_tb_fin_base_frete_transportadora] UNIQUE NONCLUSTERED 
(
	[bft_cd_transportadora] ASC,
	[bft_cd_service_center] ASC,
	[bft_estado] ASC,
	[bft_cd_tipo_veiculo] ASC,
	[bft_vl_inicio_faixa] ASC,
	[bft_cd_codigo_cliente] ASC,
	[bft_data_inicio] ASC,
	[bft_nm_cidade] ASC,
	[bft_cd_operacao] ASC,
	[bft_cd_tipo_calculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_fin_base_frete_transportadora_hist])
)
GO
