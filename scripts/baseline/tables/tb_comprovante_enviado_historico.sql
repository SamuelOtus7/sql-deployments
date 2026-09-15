-- ============================================================
-- BASELINE: dbo.tb_comprovante_enviado_historico
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_comprovante_enviado_historico]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_comprovante_enviado_historico](
	[ceh_cd_comprovante_enviado_historico] [int] IDENTITY(1,1) NOT NULL,
	[ceh_cd_comprovante_enviado] [int] NOT NULL,
	[ceh_cd_arquivo] [int] NOT NULL,
	[ceh_ds_arquivo_link] [nvarchar](max) NOT NULL,
	[ceh_dh_envio] [datetime] NOT NULL,
	[ceh_cd_usuario_envio] [int] NOT NULL,
	[ceh_cd_cliente] [int] NOT NULL,
 CONSTRAINT [PK_tb_comprovante_enviado_historico] PRIMARY KEY CLUSTERED 
(
	[ceh_cd_comprovante_enviado_historico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
