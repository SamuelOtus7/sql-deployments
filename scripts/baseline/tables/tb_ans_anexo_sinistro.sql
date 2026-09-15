-- ============================================================
-- BASELINE: dbo.tb_ans_anexo_sinistro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ans_anexo_sinistro]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ans_anexo_sinistro](
	[ans_cd_anexo_sinistro] [int] IDENTITY(1,1) NOT NULL,
	[ans_cd_sin_sinistro] [int] NOT NULL,
	[ans_cd_tipo_anexo] [int] NOT NULL,
	[ans_cd_data_anexo] [datetime] NOT NULL,
	[ans_ds_observacao] [varchar](4000) NULL,
	[ans_cd_usr_criacao] [int] NOT NULL,
	[ans_dh_modificacao] [datetime] NOT NULL,
	[ans_cd_usr_modificacao] [int] NOT NULL,
	[ans_in_ativo] [bit] NOT NULL,
	[ans_in_excluido] [bit] NOT NULL,
	[ans_dh_criacao] [datetime] NOT NULL,
	[ans_cd_codigo_upload] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ans_cd_anexo_sinistro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
