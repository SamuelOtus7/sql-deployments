-- ============================================================
-- BASELINE: dbo.tb_pag_integracao_bancos_bkup_2026
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_integracao_bancos_bkup_2026]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_integracao_bancos_bkup_2026](
	[pib_cd_integracao] [bigint] IDENTITY(1,1) NOT NULL,
	[pib_cd_espelho] [int] NOT NULL,
	[pib_cd_cliente] [int] NOT NULL,
	[pib_dt_pagamento] [date] NOT NULL,
	[pib_cd_tipo_transferencia] [int] NOT NULL,
	[pib_cd_conta] [varchar](20) NULL,
	[pib_cd_digito_conta] [varchar](2) NULL,
	[pib_ds_tipo_conta] [varchar](20) NULL,
	[pib_cd_banco] [varchar](10) NULL,
	[pib_cd_agencia] [varchar](20) NULL,
	[pib_cd_digito_agencia] [varchar](2) NULL,
	[pib_nm_beneficiado] [varchar](150) NOT NULL,
	[pib_cd_documento] [varchar](15) NOT NULL,
	[pib_vl_pagamento] [decimal](18, 2) NOT NULL,
	[pib_ds_mensagem] [varchar](255) NOT NULL,
	[pib_cd_status_irisys] [int] NOT NULL,
	[pib_cd_status_terceiro] [int] NULL,
	[pib_ds_tipo_integracao] [int] NOT NULL,
	[pib_ds_erro] [varchar](255) NULL,
	[pib_ds_chave_integracao] [varchar](50) NULL,
	[pib_dh_inclusao] [datetime] NOT NULL,
	[pib_dh_processamento] [datetime] NULL,
	[pib_nr_tentativas] [smallint] NULL,
	[pib_ui_id] [uniqueidentifier] NULL,
	[pib_ds_base] [varchar](30) NULL
) ON [PRIMARY]
GO
