-- ============================================================
-- BASELINE: dbo.tb_pac_sinistros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pac_sinistros]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pac_sinistros](
	[pac_cd_sinistro] [int] IDENTITY(1,1) NOT NULL,
	[pac_cd_sin_sinistro] [int] NOT NULL,
	[pac_ds_codigo_pacote] [varchar](200) NOT NULL,
	[pac_cd_usr_criacao] [int] NOT NULL,
	[pac_dh_modificacao] [datetime] NOT NULL,
	[pac_cd_usr_modificacao] [int] NOT NULL,
	[pac_in_ativo] [bit] NOT NULL,
	[pac_in_excluido] [bit] NOT NULL,
	[pac_dh_criacao] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[pac_cd_sinistro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
