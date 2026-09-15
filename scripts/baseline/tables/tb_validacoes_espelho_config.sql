-- ============================================================
-- BASELINE: dbo.tb_validacoes_espelho_config
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacoes_espelho_config]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacoes_espelho_config](
	[veg_cd_validacao_config] [int] IDENTITY(1,1) NOT NULL,
	[veg_cd_validacao_contexto] [int] NOT NULL,
	[veg_cd_cliente] [int] NOT NULL,
	[veg_in_habilitado] [bit] NOT NULL,
	[veg_in_obrigatorio_apuracao] [bit] NOT NULL,
	[veg_in_permite_desabilitar] [bit] NOT NULL,
	[veg_dh_criacao] [datetime] NOT NULL,
	[veg_cd_usuario_criacao] [int] NOT NULL,
	[veg_dh_modificacao] [datetime] NOT NULL,
	[veg_cd_usuario_modificacao] [int] NOT NULL,
 CONSTRAINT [pk_tb_validacoes_espelho_config] PRIMARY KEY CLUSTERED 
(
	[veg_cd_validacao_config] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
