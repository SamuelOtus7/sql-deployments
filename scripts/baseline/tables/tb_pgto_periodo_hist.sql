-- ============================================================
-- BASELINE: dbo.tb_pgto_periodo_hist
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_periodo_hist]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_periodo_hist](
	[pgp_cd_periodo] [int] NOT NULL,
	[pgp_nm_periodo] [varchar](50) NOT NULL,
	[pgp_dt_inicio] [date] NOT NULL,
	[pgp_dt_fim] [date] NULL,
	[pgp_cd_status] [int] NOT NULL,
	[pgp_dh_criacao] [datetime] NOT NULL,
	[pgp_cd_usr_criacao] [int] NOT NULL,
	[pgp_dh_modificacao] [datetime] NOT NULL,
	[pgp_cd_usr_modificacao] [int] NOT NULL,
	[pgp_cd_cliente] [int] NULL,
	[pgp_in_ativo] [bit] NOT NULL,
	[pgp_in_excluido] [bit] NOT NULL,
	[pgp_cd_tipo_contratos] [varchar](200) NULL,
	[pgp_cd_cliente_transportadora] [int] NULL,
	[pgp_dt_pagamento] [date] NULL,
	[pgp_dt_limite_reanalise] [date] NULL,
	[pgp_tipo_operacao] [int] NULL,
	[pgp_cd_base] [int] NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL,
	[pgp_dt_prevista_pagamento] [date] NULL,
	[pgp_dt_limite_alteracao_espelhos] [date] NULL,
	[pgp_dt_limite_envio_nf] [date] NULL,
	[pgp_dt_limite_lancamentos_manuais] [date] NULL
) ON [PRIMARY]
GO
