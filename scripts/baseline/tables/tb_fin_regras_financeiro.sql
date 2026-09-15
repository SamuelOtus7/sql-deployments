-- ============================================================
-- BASELINE: dbo.tb_fin_regras_financeiro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_regras_financeiro]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_regras_financeiro](
	[rlf_cd_regras_financeiro] [int] IDENTITY(1,1) NOT NULL,
	[rlf_cd_transportadora] [int] NOT NULL,
	[rlf_cd_codigo_cliente] [int] NOT NULL,
	[rlf_cd_operacao] [int] NOT NULL,
	[rlf_cd_tipo_contrato] [int] NULL,
	[rlf_cd_service_center] [varchar](50) NULL,
	[rlf_cd_tipo_veiculo] [int] NULL,
	[rlf_nm_tipo_regra] [varchar](50) NOT NULL,
	[rlf_nm_regra] [varchar](100) NOT NULL,
	[rlf_ds_criterios_regra] [varchar](max) NOT NULL,
	[rlf_nm_criterio01] [varchar](30) NULL,
	[rlf_vl_criterio01] [varchar](60) NULL,
	[rlf_nm_criterio02] [varchar](30) NULL,
	[rlf_vl_criterio02] [varchar](60) NULL,
	[rlf_nm_criterio03] [varchar](30) NULL,
	[rlf_vl_criterio03] [varchar](60) NULL,
	[rlf_nm_acao01] [varchar](30) NULL,
	[rlf_vl_acao01] [varchar](60) NULL,
	[rlf_nm_acao02] [varchar](30) NULL,
	[rlf_vl_acao02] [varchar](60) NULL,
	[rlf_nm_acao03] [varchar](30) NULL,
	[rlf_vl_acao03] [varchar](60) NULL,
	[rlf_data_inicio_vigencia] [date] NOT NULL,
	[rlf_data_fim_vigencia] [date] NULL,
	[rlf_int_ativo] [bit] NOT NULL,
	[rlf_dt_cadastro] [datetime] NOT NULL,
	[rlf_cd_cli_transportadora] [int] NULL,
	[rlf_nr_fase_execucao] [int] NOT NULL,
 CONSTRAINT [PK_tb_fin_regras_financeiro] PRIMARY KEY CLUSTERED 
(
	[rlf_cd_regras_financeiro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
