-- ============================================================
-- BASELINE: dbo.tb_ama_anexo_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ama_anexo_motorista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ama_anexo_motorista](
	[ama_cd_anexo_motorista] [int] IDENTITY(1,1) NOT NULL,
	[ama_cd_motorista] [int] NOT NULL,
	[ama_ds_nome] [varchar](255) NOT NULL,
	[ama_cd_tipo_anexo] [int] NOT NULL,
	[ama_cd_data_anexo] [datetime] NOT NULL,
	[ama_ds_observacao] [varchar](4000) NULL,
	[ama_cd_codigo_upload] [bigint] NOT NULL,
	[ama_in_ativo] [bit] NOT NULL,
	[ama_in_excluido] [bit] NOT NULL,
	[ama_dh_criacao] [datetime] NOT NULL,
	[ama_cd_usr_criacao] [int] NOT NULL,
	[ama_dh_modificacao] [datetime] NOT NULL,
	[ama_cd_usr_modificacao] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ama_cd_anexo_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
