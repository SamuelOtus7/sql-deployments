-- ============================================================
-- BASELINE: dbo.tb_setor
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_setor]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_setor](
	[set_cd_setor] [int] IDENTITY(1,1) NOT NULL,
	[set_nm_setor] [varchar](150) NOT NULL,
	[set_ds_setor] [varchar](250) NULL,
	[set_in_ativo] [bit] NOT NULL,
	[set_cd_cliente] [int] NOT NULL,
	[set_cd_usuario_criacao] [int] NOT NULL,
	[set_cd_usuario_modificacao] [int] NOT NULL,
	[set_dh_criacao] [datetime] NOT NULL,
	[set_dh_modificacao] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[set_cd_setor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_setor_cliente_nome] UNIQUE NONCLUSTERED 
(
	[set_cd_cliente] ASC,
	[set_nm_setor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
