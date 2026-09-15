-- ============================================================
-- BASELINE: dbo.tb_fin_regras_lancamentos_avulso
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_regras_lancamentos_avulso]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_regras_lancamentos_avulso](
	[rla_cd_regras_lancamentos_avulso] [int] IDENTITY(1,1) NOT NULL,
	[rla_cd_transportadora] [int] NOT NULL,
	[rla_cd_codigo_cliente] [int] NOT NULL,
	[rla_cd_operacao] [int] NOT NULL,
	[rla_cd_tipo_contrato] [int] NULL,
	[rla_cd_service_center] [varchar](50) NULL,
	[rla_cd_tipo_veiculo] [int] NULL,
	[rla_nm_regra] [varchar](150) NOT NULL,
	[rla_ds_criterios_regra] [varchar](150) NOT NULL,
	[rla_nm_criterio01] [varchar](30) NULL,
	[rla_vl_criterio01] [varchar](60) NULL,
	[rla_nm_criterio02] [varchar](30) NULL,
	[rla_vl_criterio02] [varchar](60) NULL,
	[rla_nm_criterio03] [varchar](30) NULL,
	[rla_vl_criterio03] [varchar](60) NULL,
	[rla_ds_lancamento] [varchar](150) NOT NULL,
	[rla_vl_lancamento] [decimal](7, 2) NOT NULL,
	[rla_data_inicio_vigencia] [date] NOT NULL,
	[rla_data_fim_vigencia] [date] NULL,
	[rla_int_ativo] [bit] NOT NULL,
	[rla_dt_cadastro] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_fin_regras_lancamentos_avulso] PRIMARY KEY CLUSTERED 
(
	[rla_cd_regras_lancamentos_avulso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_fin_regras_lancamentos_avulso] UNIQUE NONCLUSTERED 
(
	[rla_cd_transportadora] ASC,
	[rla_cd_codigo_cliente] ASC,
	[rla_cd_operacao] ASC,
	[rla_cd_tipo_contrato] ASC,
	[rla_cd_service_center] ASC,
	[rla_cd_tipo_veiculo] ASC,
	[rla_nm_regra] ASC,
	[rla_data_inicio_vigencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
