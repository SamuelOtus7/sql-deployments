-- ============================================================
-- BASELINE: dbo.tb_lancamentos_manuais_erros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_lancamentos_manuais_erros]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_lancamentos_manuais_erros](
	[lme_id] [int] IDENTITY(1,1) NOT NULL,
	[lme_cd_lancamento_manual] [int] NOT NULL,
	[lme_nm_tipo] [varchar](80) NULL,
	[lme_nm_motorista] [varchar](80) NULL,
	[lme_cd_periodo] [int] NOT NULL,
	[lme_cd_cliente_transportadora] [int] NULL,
	[lme_cd_operacao] [int] NULL,
	[lme_ds_erro] [varchar](500) NOT NULL,
	[lme_dh_criacao] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[lme_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
