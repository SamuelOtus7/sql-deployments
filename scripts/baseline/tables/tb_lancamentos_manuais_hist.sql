-- ============================================================
-- BASELINE: dbo.tb_lancamentos_manuais_hist
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_lancamentos_manuais_hist]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_lancamentos_manuais_hist](
	[tlm_cd_lancamento_manual] [int] NOT NULL,
	[tlm_cd_rota] [varchar](50) NULL,
	[tlm_cd_service_center] [varchar](150) NULL,
	[tlm_cd_motorista] [varchar](100) NULL,
	[tlm_cd_tipo] [varchar](30) NULL,
	[tlm_cd_periodo] [varchar](8) NULL,
	[tlm_cd_risco_ajudante] [varchar](10) NULL,
	[tlm_cd_quantidade_pacotes] [int] NULL,
	[tlm_cd_pontos] [int] NULL,
	[tlm_ds_observacao] [varchar](600) NULL,
	[tlm_cd_cliente] [int] NULL,
	[tlm_in_ativo] [bit] NOT NULL,
	[tlm_in_excluido] [bit] NOT NULL,
	[tlm_cd_usuario_criacao] [int] NOT NULL,
	[tlm_dh_criacao] [datetime] NOT NULL,
	[tlm_cd_usuario_modificacao] [int] NOT NULL,
	[tlm_dh_modificacao] [datetime] NOT NULL,
	[tlm_cd_transportadora] [int] NULL,
	[tlm_in_marketplace] [varchar](10) NULL,
	[tlm_ds_motorista_apoio] [varchar](100) NULL,
	[tlm_tipo_valor_apoio] [varchar](30) NULL,
	[tlm_vl_valor_apoio] [decimal](8, 2) NULL,
	[tlm_cd_tipo_veiculo_nao_utilizado] [int] NULL,
	[tlm_dh_nao_utilizado] [date] NULL,
	[tlm_dh_referencia] [datetime] NULL,
	[tlm_cd_arquivo] [bigint] NULL,
	[tlm_cd_cliente_transportadora] [int] NULL,
	[tlm_vl_valor_rota] [decimal](18, 2) NULL,
	[tlm_vl_valor_adicional] [decimal](18, 2) NULL,
	[tlm_ds_motorista_secundario] [varchar](255) NULL,
	[tlm_vl_valor_descontos] [decimal](18, 2) NULL,
	[tlm_ds_matricula] [varchar](100) NULL,
	[tlm_ds_placa] [nvarchar](255) NULL,
	[tlm_cd_mot] [int] NOT NULL,
	[tlm_cd_mot_apoio] [int] NULL,
	[tlm_tp_credito_debito] [nvarchar](20) NULL,
	[tlm_cd_operacao] [int] NOT NULL,
	[tlm_ds_valor_referencia] [varchar](50) NULL,
	[tlm_ds_id_pacote] [nvarchar](100) NULL,
	[tlm_ds_rota_ds] [nvarchar](100) NULL,
	[tlm_ds_ids_pacote] [nvarchar](max) NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
