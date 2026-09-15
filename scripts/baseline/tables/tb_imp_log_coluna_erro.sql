-- ============================================================
-- BASELINE: dbo.tb_imp_log_coluna_erro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_imp_log_coluna_erro]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_imp_log_coluna_erro](
	[ice_cd_coluna_erro] [bigint] IDENTITY(1,1) NOT NULL,
	[ilg_cd_log] [bigint] NOT NULL,
	[ice_ds_nome_coluna] [varchar](150) NOT NULL,
	[ice_ds_tipo_erro] [varchar](30) NOT NULL,
	[ice_ds_descricao] [varchar](400) NOT NULL,
	[ice_nu_linha_planilha] [int] NULL,
	[ice_dh_criacao] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_imp_log_coluna_erro] PRIMARY KEY CLUSTERED 
(
	[ice_cd_coluna_erro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
