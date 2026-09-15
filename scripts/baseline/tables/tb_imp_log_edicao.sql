-- ============================================================
-- BASELINE: dbo.tb_imp_log_edicao
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_imp_log_edicao]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_imp_log_edicao](
	[ied_cd_edicao] [bigint] IDENTITY(1,1) NOT NULL,
	[ilg_cd_log] [bigint] NOT NULL,
	[cli_cd_codigo_cliente] [int] NOT NULL,
	[usr_cd_usuario] [int] NOT NULL,
	[ied_ds_texto_ajuste] [varchar](1000) NOT NULL,
	[ied_dh_criacao] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_imp_log_edicao] PRIMARY KEY CLUSTERED 
(
	[ied_cd_edicao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
