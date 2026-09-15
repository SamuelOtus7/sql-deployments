-- ============================================================
-- BASELINE: dbo.tb_comprovantes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_comprovantes]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_comprovantes](
	[cmp_cd_comprovante] [int] IDENTITY(1,1) NOT NULL,
	[cmp_nm_comprovante] [varchar](150) NULL,
	[cmp_cd_cliente] [int] NOT NULL,
	[cmp_in_ativo] [bit] NOT NULL,
	[cmp_in_excluido] [bit] NOT NULL,
	[cmp_cd_usuario_criacao] [int] NOT NULL,
	[cmp_dh_criacao] [datetime] NOT NULL,
	[cmp_cd_usuario_modificacao] [int] NOT NULL,
	[cmp_dh_modificacao] [datetime] NOT NULL,
	[cmp_in_pix_gr] [bit] NOT NULL,
 CONSTRAINT [pk_cmp_cd_comprovante] PRIMARY KEY CLUSTERED 
(
	[cmp_cd_comprovante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
