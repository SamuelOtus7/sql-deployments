-- ============================================================
-- BASELINE: dbo.tb_validacoes_gerais_config
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacoes_gerais_config]    Script Date: 14/09/2026 12:12:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacoes_gerais_config](
	[vlc_id_validacao] [int] IDENTITY(1,1) NOT NULL,
	[vlc_cd_validacao] [int] NOT NULL,
	[vlc_cd_cliente] [int] NOT NULL,
	[vlc_int_ativo] [bit] NOT NULL,
 CONSTRAINT [pk_validacao_config] PRIMARY KEY CLUSTERED 
(
	[vlc_id_validacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
