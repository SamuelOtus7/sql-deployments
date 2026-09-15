-- ============================================================
-- BASELINE: dbo.tb_pgto_periodo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_periodo]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_periodo](
	[pgp_cd_periodo] [int] IDENTITY(1,1) NOT NULL,
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
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[pgp_dt_prevista_pagamento] [date] NULL,
	[pgp_dt_limite_alteracao_espelhos] [date] NULL,
	[pgp_dt_limite_envio_nf] [date] NULL,
	[pgp_dt_limite_lancamentos_manuais] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[pgp_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_pgto_periodo_hist])
)
GO
