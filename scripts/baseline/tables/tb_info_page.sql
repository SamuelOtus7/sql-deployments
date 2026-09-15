-- ============================================================
-- BASELINE: dbo.tb_info_page
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_info_page]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_info_page](
	[inp_cd_info_pag] [int] IDENTITY(1,1) NOT NULL,
	[inp_nm_info_pag] [varchar](150) NOT NULL,
	[inp_ds_info_pag] [varchar](150) NULL,
	[inp_ds_info_route] [varchar](150) NOT NULL,
	[inp_ds_key] [varchar](max) NULL,
	[inp_ds_value] [varchar](max) NULL,
	[inp_in_ativo] [bit] NULL,
	[inp_in_excluido] [bit] NULL,
	[inp_cd_usuario_criacao] [int] NOT NULL,
	[inp_dh_criacao] [datetime] NOT NULL,
	[inp_cd_usuario_modificacao] [int] NOT NULL,
	[inp_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [inp_cd_info_pag] PRIMARY KEY CLUSTERED 
(
	[inp_cd_info_pag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
