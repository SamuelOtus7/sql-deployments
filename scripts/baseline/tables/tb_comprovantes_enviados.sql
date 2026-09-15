-- ============================================================
-- BASELINE: dbo.tb_comprovantes_enviados
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_comprovantes_enviados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_comprovantes_enviados](
	[cme_cd_comprovante_enviado] [int] IDENTITY(1,1) NOT NULL,
	[cme_cd_comprovante] [int] NOT NULL,
	[cme_cd_usuario] [int] NOT NULL,
	[cme_cd_cliente] [int] NOT NULL,
	[cme_ds_status] [varchar](30) NOT NULL,
	[cme_ds_motivo] [varchar](150) NULL,
	[cme_cd_arquivo] [int] NULL,
	[cme_ds_arquivo_link] [varchar](max) NULL,
	[cme_in_ativo] [bit] NOT NULL,
	[cme_in_excluido] [bit] NOT NULL,
	[cme_cd_usuario_criacao] [int] NOT NULL,
	[cme_dh_criacao] [datetime] NOT NULL,
	[cme_cd_usuario_modificacao] [int] NOT NULL,
	[cme_dh_modificacao] [datetime] NOT NULL,
	[cme_in_solicita_envio_atualizado] [bit] NOT NULL,
 CONSTRAINT [pk_comprovante_enviado] PRIMARY KEY CLUSTERED 
(
	[cme_cd_comprovante_enviado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
