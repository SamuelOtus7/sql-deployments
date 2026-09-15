-- ============================================================
-- BASELINE: dbo.tb_lista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_lista]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_lista](
	[lst_cd_lista] [int] IDENTITY(1,1) NOT NULL,
	[lst_nm_lista] [varchar](100) NOT NULL,
	[lst_ds_chave] [int] NOT NULL,
	[lst_ds_valor] [varchar](250) NOT NULL,
	[lst_ds_label] [varchar](250) NULL,
	[lst_cd_cliente] [int] NULL,
	[lst_nr_ordem] [int] NULL,
	[lst_cd_fechado] [bit] NULL,
 CONSTRAINT [pk_lista] PRIMARY KEY CLUSTERED 
(
	[lst_cd_lista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_lst_nm_lista] UNIQUE NONCLUSTERED 
(
	[lst_nm_lista] ASC,
	[lst_ds_chave] ASC,
	[lst_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
