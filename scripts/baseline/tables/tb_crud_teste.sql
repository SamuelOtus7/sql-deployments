-- ============================================================
-- BASELINE: dbo.tb_crud_teste
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_crud_teste]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_crud_teste](
	[tst_cd_teste] [int] IDENTITY(1,1) NOT NULL,
	[tst_ds_nome] [varchar](max) NOT NULL,
	[tst_dt_data_de_criacao] [datetime] NOT NULL,
	[tst_cd_usuario] [int] NOT NULL,
	[tst_in_ativo] [bit] NOT NULL,
 CONSTRAINT [PK_tb_crud_teste] PRIMARY KEY CLUSTERED 
(
	[tst_cd_teste] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
