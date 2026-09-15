-- ============================================================
-- BASELINE: dbo.tb_validacoes_gerais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacoes_gerais]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacoes_gerais](
	[vld_cd_validacao] [int] IDENTITY(1,1) NOT NULL,
	[vld_ds_validacao] [varchar](100) NOT NULL,
	[vld_int_ativo] [bit] NOT NULL,
	[vld_ds_sql_script] [varchar](max) NOT NULL,
	[vld_ds_observacao] [varchar](250) NOT NULL,
 CONSTRAINT [pk_vlg_validacao] PRIMARY KEY CLUSTERED 
(
	[vld_cd_validacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
