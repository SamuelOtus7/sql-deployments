-- ============================================================
-- BASELINE: dbo.tb_dra_erros_recorrentes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_erros_recorrentes]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_erros_recorrentes](
	[cd_cod_menssagem] [int] IDENTITY(1,1) NOT NULL,
	[Mensagem] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
