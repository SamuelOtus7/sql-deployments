-- ============================================================
-- BASELINE: dbo.tb_tipos_lancamentos_manuais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tipos_lancamentos_manuais]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tipos_lancamentos_manuais](
	[plm_cd_tipo_lancamento_manual] [int] IDENTITY(1,1) NOT NULL,
	[plm_nm_tipo] [varchar](150) NOT NULL,
	[plm_cd_transportadora] [int] NOT NULL,
	[plm_ds_marketplace] [varchar](150) NULL,
	[plm_ds_descricao] [varchar](100) NULL,
	[plm_in_ativo] [bit] NOT NULL,
	[plm_cd_usuario_criacao] [int] NOT NULL,
	[plm_dh_criacao] [datetime] NOT NULL,
	[plm_cd_usuario_modificacao] [int] NOT NULL,
	[plm_dh_modificacao] [datetime] NOT NULL,
	[plm_cd_cliente_transportadora] [int] NULL,
	[plm_cd_cliente] [int] NULL,
	[plm_input_data_referencia] [bit] NULL,
	[plm_input_risco_ajudante] [bit] NULL,
	[plm_input_periodo] [bit] NULL,
	[plm_input_pacotes] [bit] NULL,
	[plm_input_pontos] [bit] NULL,
	[plm_input_motorista_apoio] [bit] NULL,
	[plm_input_valor_apoio] [bit] NULL,
	[plm_input_valor_descontos] [bit] NULL,
	[plm_input_data_nao_utilizado] [bit] NULL,
	[plm_input_tipo_veiculo] [bit] NULL,
	[plm_input_valor_adicional] [bit] NULL,
	[plm_input_valor_rota] [bit] NULL,
	[plm_input_motorista_secundario] [bit] NULL,
	[plm_input_motorista_obrigatorio] [bit] NULL,
	[plm_input_placa] [bit] NULL,
	[plm_input_data_referencia_obrigatorio] [bit] NULL,
	[plm_input_risco_ajudante_obrigatorio] [bit] NULL,
	[plm_input_periodo_obrigatorio] [bit] NULL,
	[plm_input_pacotes_obrigatorio] [bit] NULL,
	[plm_input_pontos_obrigatorio] [bit] NULL,
	[plm_input_motorista_apoio_obrigatorio] [bit] NULL,
	[plm_input_valor_apoio_obrigatorio] [bit] NULL,
	[plm_input_valor_descontos_obrigatorio] [bit] NULL,
	[plm_input_data_nao_utilizado_obrigatorio] [bit] NULL,
	[plm_input_tipo_veiculo_obrigatorio] [bit] NULL,
	[plm_input_valor_adicional_obrigatorio] [bit] NULL,
	[plm_input_valor_rota_obrigatorio] [bit] NULL,
	[plm_input_motorista_secundario_obrigatorio] [bit] NULL,
	[plm_input_placa_obrigatorio] [bit] NULL,
	[plm_input_id_rota_obrigatorio] [bit] NULL,
	[plm_input_id_rota] [bit] NULL,
	[plm_in_calculo_desconto] [bit] NOT NULL,
	[plm_in_edit] [bit] NULL,
	[plm_vl_desconto] [decimal](10, 2) NULL,
	[plm_input_paradas] [bit] NULL,
	[plm_input_paradas_obrigatorio] [bit] NULL,
 CONSTRAINT [pk_tipo_lancamento_manual] PRIMARY KEY CLUSTERED 
(
	[plm_cd_tipo_lancamento_manual] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
