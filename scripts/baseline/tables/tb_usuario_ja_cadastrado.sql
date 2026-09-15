-- ============================================================
-- BASELINE: dbo.tb_usuario_ja_cadastrado
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_usuario_ja_cadastrado]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_usuario_ja_cadastrado](
	[cli_cd_codigo_cliente] [int] NULL,
	[usr_nm_usuario] [varchar](50) NOT NULL,
	[usr_ds_email] [varchar](100) NOT NULL,
	[nome] [varchar](5000) NULL,
	[email] [varchar](5000) NULL,
	[Ocorrido] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
