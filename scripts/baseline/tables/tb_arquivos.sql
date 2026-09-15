-- ============================================================
-- BASELINE: dbo.tb_arquivos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_arquivos]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_arquivos](
	[arq_cd_arquivo] [bigint] IDENTITY(1,1) NOT NULL,
	[arq_nm_arquivo] [varchar](150) NOT NULL,
	[arq_dir_arquivo] [varchar](150) NOT NULL,
	[arq_nm_amigavel] [varchar](150) NOT NULL,
	[arq_cd_geral] [int] NULL,
	[arq_dt_criacao] [datetime] NOT NULL,
	[arq_in_ativo] [bit] NULL,
	[arq_cd_controller] [int] NOT NULL,
 CONSTRAINT [pk_arquivos] PRIMARY KEY CLUSTERED 
(
	[arq_cd_arquivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
