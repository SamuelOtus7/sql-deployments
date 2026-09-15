-- ============================================================
-- BASELINE: dbo.tb_pag_espelhos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_espelhos]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_espelhos](
	[mtn_cd_motorista_nfs] [int] IDENTITY(1,1) NOT NULL,
	[mtn_cd_motorista] [int] NULL,
	[mtn_cd_pgto_periodo] [int] NOT NULL,
	[mtn_cd_status] [int] NOT NULL,
	[mtn_vl_nfs] [decimal](10, 2) NOT NULL,
	[mtn_ds_link_nfs] [varchar](1000) NULL,
	[mtn_dt_prazo_contestacao] [datetime] NULL,
	[mtn_dh_criacao] [datetime] NOT NULL,
	[mtn_cd_usr_criacao] [int] NOT NULL,
	[mtn_dh_modificacao] [datetime] NOT NULL,
	[mtn_cd_usr_modificacao] [int] NOT NULL,
	[mtn_in_excluido] [bit] NOT NULL,
	[mtn_cod_cliente] [int] NOT NULL,
	[mtn_qt_rotas] [tinyint] NULL,
	[mtn_cd_tipo_espelho] [int] NULL,
	[mtn_cd_cliente_transportadora] [int] NULL,
	[mtn_cd_base] [int] NULL,
	[mtn_in_gerar_pdf] [bit] NULL,
	[mtn_ds_linkespelho] [varchar](250) NULL,
	[mtn_base_principal] [varchar](50) NULL,
	[mtn_nome_motorista] [varchar](200) NULL,
	[mtn_cd_status_pdf_massa] [int] NULL,
	[mtn_dt_data_criacao_pdf_massa] [datetime] NULL,
	[mtn_dh_envio_nfs] [datetime] NULL,
	[mtn_dh_envio_push_notification] [datetime] NULL,
	[mtn_vl_imposto] [decimal](10, 2) NULL,
	[mtn_vl_liquido] [decimal](10, 2) NULL,
	[mtn_ds_link_nfs_secundario] [varchar](1000) NULL,
	[mtn_dh_envio_nfs_secundario] [datetime] NULL,
	[mtn_in_zerar_espelho] [int] NULL,
	[mtn_vl_desconto] [decimal](10, 2) NOT NULL,
	[mtn_cd_operacao] [int] NOT NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[mtn_ds_Banco] [varchar](500) NULL,
	[mtn_ds_NomeTitular] [varchar](200) NULL,
	[mtn_ds_CpfTitular] [varchar](50) NULL,
	[mtn_ds_CnpjTitular] [varchar](50) NULL,
	[mtn_ds_Agencia] [varchar](50) NULL,
	[mtn_ds_Conta] [varchar](50) NULL,
	[mtn_ds_TipoConta] [varchar](100) NULL,
	[mtn_ds_TipoChavePix] [varchar](100) NULL,
	[mtn_ds_ChavePix] [varchar](100) NULL,
	[mtn_ds_CnpjEmpresa] [varchar](100) NULL,
	[mtn_ds_RazaoSocial] [varchar](200) NULL,
	[mtn_ds_NomeFantasia] [varchar](200) NULL,
	[mtn_cd_tipo_contrato] [int] NULL,
	[mtn_cd_status_validacao_automatica_nfse] [int] NULL,
	[mtn_dh_envio_nfs_terceiro] [datetime] NULL,
	[mtn_ds_link_nfs_terceiro] [varchar](500) NULL,
	[mtn_dh_envio_nfs_quarto] [datetime] NULL,
	[mtn_ds_link_nfs_quarto] [varchar](500) NULL,
	[mtn_cd_usr_espelho_pdf] [int] NULL,
	[mtn_in_processamento_em_massa] [bit] NULL,
	[mtn_driver_id] [int] NULL,
	[mtn_cpf] [varchar](18) NULL,
	[mtn_in_divisao] [bit] NULL,
	[mtn_ds_link_comprovante_pagamento] [varchar](2048) NULL,
	[mtn_dt_prevista_pagamento] [date] NULL,
	[mtn_in_prevista_manual] [bit] NOT NULL,
	[mtn_ds_mensagem_erro] [varchar](300) NULL,
	[mtn_in_numero_tentativas] [int] NOT NULL,
	[mtn_in_validacao_monitoramento] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[mtn_cd_motorista_nfs] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
GO
