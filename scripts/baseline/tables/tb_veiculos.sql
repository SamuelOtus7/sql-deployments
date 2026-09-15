-- ============================================================
-- BASELINE: dbo.tb_veiculos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_veiculos]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_veiculos](
	[vei_cd_veiculo] [int] IDENTITY(1,1) NOT NULL,
	[vei_cd_cliente] [int] NOT NULL,
	[vei_ds_placa] [varchar](15) NOT NULL,
	[vei_ds_base] [varchar](50) NOT NULL,
	[vei_ds_tipo] [varchar](50) NULL,
	[vei_cd_documento] [bigint] NULL,
	[vei_ds_path_documento] [varchar](500) NULL,
	[vei_cd_logistics] [int] NULL,
	[vei_ds_tipo_logistics] [varchar](50) NULL,
	[vei_cd_shopee] [int] NULL,
	[vei_ds_tipo_shopee] [varchar](50) NULL,
	[vei_in_ativo] [bit] NOT NULL,
	[vei_in_excluido] [bit] NOT NULL,
	[vei_cd_usuario_criacao] [int] NOT NULL,
	[vei_dh_criacao] [datetime] NOT NULL,
	[vei_cd_usuario_modificacao] [int] NOT NULL,
	[vei_dh_modificacao] [datetime] NOT NULL,
	[vei_in_frota_fixa] [bit] NULL,
	[vei_in_tipo_frota] [int] NULL,
	[vei_ds_uf_veiculo] [varchar](2) NULL,
	[vei_ds_tipo_rodado] [varchar](2) NULL,
	[vei_ds_tipo_carroceria] [varchar](2) NULL,
	[vei_ds_capacidade] [varchar](50) NULL,
	[vei_ds_renavam] [varchar](20) NULL,
	[vei_ds_seguradora] [varchar](255) NULL,
	[vei_ds_nome_proprietario] [varchar](255) NULL,
	[vei_ds_rntrc_proprietario] [varchar](20) NULL,
	[vei_ds_uf_proprietario] [varchar](2) NULL,
	[vei_ds_cpf_cnpj_proprietario] [varchar](18) NULL,
	[vei_cd_valor_aluguel] [decimal](10, 2) NULL,
	[vei_ds_modelo_cobranca] [nvarchar](50) NULL,
	[vei_ds_data_inicio_aluguel] [datetime] NULL,
	[vei_ds_data_fim_aluguel] [datetime] NULL,
	[vei_cd_ano] [int] NULL,
	[vei_cd_status] [int] NULL,
	[vei_cd_vl_aluguel] [int] NULL,
	[vei_ds_nome_motorista] [varchar](255) NULL,
	[vei_alugar_veiculo] [bit] NULL,
	[vei_vl_pagamento_fixo_excluir] [decimal](10, 2) NULL,
	[vei_ds_crlv] [varchar](255) NULL,
	[vei_ds_vencimento_veiculo] [datetime] NULL,
	[vei_fl_status_aluguel] [bit] NULL,
	[vei_vl_pgto_mot] [decimal](10, 2) NULL,
	[vei_valor_fixo] [decimal](10, 2) NULL,
	[vei_desconto_flex_frota] [bit] NULL,
	[vei_ds_marca_veiculo] [varchar](255) NULL,
	[vei_ds_modelo_veiculo] [varchar](255) NULL,
	[vei_zerar_espelho] [bit] NULL,
	[vei_nr_exercicio_crlv] [int] NULL,
	[vei_dt_validade_gr_placa] [datetime] NULL,
	[vei_ds_situacao_gr_placa] [varchar](10) NULL,
	[vei_ds_base_espelho] [varchar](50) NULL,
	[vei_ds_base_espelho_calculo] [varchar](50) NULL,
	[vei_ds_veiculo_espelho_calculo] [varchar](50) NULL,
	[vei_ds_chassi] [nvarchar](50) NULL,
	[vei_ds_cor] [nvarchar](50) NULL,
	[vei_ds_combustivel] [nvarchar](50) NULL,
	[vei_nr_eixos] [int] NULL,
	[vei_cd_veiculo_vinculado] [int] NULL,
 CONSTRAINT [pk_tb_veiculos] PRIMARY KEY CLUSTERED 
(
	[vei_cd_veiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_veiculos_vei_ds_placa_excluido_modify] UNIQUE NONCLUSTERED 
(
	[vei_ds_placa] ASC,
	[vei_cd_cliente] ASC,
	[vei_in_excluido] ASC,
	[vei_dh_modificacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
