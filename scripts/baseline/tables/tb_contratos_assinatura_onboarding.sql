-- ============================================================
-- BASELINE: dbo.tb_contratos_assinatura_onboarding
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos_assinatura_onboarding]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos_assinatura_onboarding](
	[cao_cd_assinatura_onboarding] [int] IDENTITY(1,1) NOT NULL,
	[cao_ds_nome] [nvarchar](500) NOT NULL,
	[cao_ds_cpf] [nvarchar](14) NOT NULL,
	[cao_cd_contrato] [int] NOT NULL,
	[cao_cd_cliente] [int] NULL,
	[cao_link_assinatura] [nvarchar](max) NULL,
	[cao_link_selfie] [nvarchar](max) NULL,
	[cao_ds_status] [nvarchar](20) NOT NULL,
	[cao_ds_link_onboarding] [nvarchar](max) NULL,
	[cao_dh_criacao] [datetime] NOT NULL,
	[cao_dh_finalizacao] [datetime] NULL,
	[cao_link_contrato] [nvarchar](max) NULL,
	[cao_ds_webhook] [nvarchar](max) NULL,
	[cao_ds_ip] [nvarchar](150) NULL,
	[cao_cd_arquivo_assinatura] [bigint] NULL,
	[cao_cd_tipo_contrato] [int] NULL,
	[cao_cd_arquivo_selfie] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[cao_cd_assinatura_onboarding] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
