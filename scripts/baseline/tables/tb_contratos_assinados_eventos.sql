-- ============================================================
-- BASELINE: dbo.tb_contratos_assinados_eventos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos_assinados_eventos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos_assinados_eventos](
	[cte_cd_contrato_eventos] [int] IDENTITY(1,1) NOT NULL,
	[cte_cd_usuario] [int] NOT NULL,
	[cte_cd_contrato] [int] NOT NULL,
	[cte_dh_criacao] [datetime] NOT NULL,
	[cte_ds_tipo] [varchar](15) NOT NULL,
	[cte_link_assinatura] [varchar](500) NULL,
	[cte_link_selfie] [varchar](500) NULL,
	[cte_ds_ip] [varchar](50) NULL,
	[cte_ds_nome] [varchar](150) NOT NULL,
	[cte_ds_email] [varchar](150) NOT NULL,
	[cte_ds_cpf] [varchar](14) NOT NULL,
	[cte_dt_nascimento] [date] NULL,
	[cte_ds_codigo_assinatura] [char](36) NULL,
	[cte_ds_hash_assinatura]  AS (CONVERT([varchar](128),hashbytes('SHA2_512',[cte_ds_codigo_assinatura]),(2))),
 CONSTRAINT [pk_contratos_assinados_eventos] PRIMARY KEY CLUSTERED 
(
	[cte_cd_contrato_eventos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
