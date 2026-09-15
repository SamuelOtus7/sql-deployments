-- ============================================================
-- BASELINE: dbo.tb_visibilidade_controller
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_visibilidade_controller]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_visibilidade_controller](
	[vct_cd_visibilidade_controller] [smallint] IDENTITY(1,1) NOT NULL,
	[vct_nm_visibilidade_controller] [varchar](30) NOT NULL,
	[vct_ds_visibilidade_controller] [varchar](150) NOT NULL,
	[vct_in_ativo] [bit] NOT NULL,
	[vct_dh_criacao] [datetime] NOT NULL,
	[vct_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_visibilidade_controller] PRIMARY KEY CLUSTERED 
(
	[vct_cd_visibilidade_controller] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
