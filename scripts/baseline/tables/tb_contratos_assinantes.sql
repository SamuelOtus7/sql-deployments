-- ============================================================
-- BASELINE: dbo.tb_contratos_assinantes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos_assinantes]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos_assinantes](
	[cta_cd_contrato_assinantes] [int] IDENTITY(1,1) NOT NULL,
	[cta_cd_cliente] [int] NOT NULL,
	[cta_ds_nome] [varchar](150) NULL,
	[cta_ds_email] [varchar](150) NOT NULL,
	[cta_ds_cpf] [varchar](14) NULL,
	[cta_dt_nascimento] [date] NULL,
	[cta_link_assinatura] [varchar](500) NULL,
	[cta_link_selfie] [varchar](500) NULL,
	[cta_in_ativo] [bit] NOT NULL,
	[cta_ds_tipo_assinante] [varchar](20) NOT NULL,
	[cta_in_assinatura_obrigatoria] [bit] NOT NULL,
	[cta_cd_usuario_criacao] [int] NOT NULL,
	[cta_dh_criacao] [datetime] NOT NULL,
	[cta_cd_usuario_modificacao] [int] NOT NULL,
	[cta_dh_modificacao] [datetime] NOT NULL,
	[cta_ds_status] [varchar](40) NULL,
	[cta_cd_usuario_relacao] [int] NULL,
 CONSTRAINT [pk_contratos_assinantes] PRIMARY KEY CLUSTERED 
(
	[cta_cd_contrato_assinantes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
