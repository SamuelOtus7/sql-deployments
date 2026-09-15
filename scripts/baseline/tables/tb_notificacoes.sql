-- ============================================================
-- BASELINE: dbo.tb_notificacoes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_notificacoes]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_notificacoes](
	[not_cd_notificacao] [smallint] IDENTITY(1,1) NOT NULL,
	[not_ds_titulo] [varchar](50) NOT NULL,
	[not_ds_mensagem] [varchar](255) NOT NULL,
	[not_ds_canais] [varchar](50) NULL,
	[usr_cd_usuario_criacao] [int] NOT NULL,
	[not_dh_criacao] [datetime] NOT NULL,
	[usr_cd_usuario_modificacao] [int] NOT NULL,
	[not_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_notificacao] PRIMARY KEY CLUSTERED 
(
	[not_cd_notificacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
