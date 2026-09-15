-- ============================================================
-- BASELINE: dbo.tb_contratos_assinados
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos_assinados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos_assinados](
	[cta_cd_contrato_assinado] [int] IDENTITY(1,1) NOT NULL,
	[cta_cd_usuario] [int] NOT NULL,
	[cta_cd_contrato] [int] NOT NULL,
	[cta_cd_pdf] [bigint] NULL,
	[cta_dh_criacao] [datetime] NOT NULL,
	[cta_ds_status] [varchar](30) NOT NULL,
	[cta_ds_codigo_assinatura] [char](36) NULL,
	[cta_ds_hash_assinatura]  AS (CONVERT([varchar](128),hashbytes('SHA2_512',[cta_ds_codigo_assinatura]),(2))),
 CONSTRAINT [pk_contratos_assinados] PRIMARY KEY CLUSTERED 
(
	[cta_cd_contrato_assinado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY],
 CONSTRAINT [uk_contratos_assinados] UNIQUE NONCLUSTERED 
(
	[cta_cd_usuario] ASC,
	[cta_cd_contrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
