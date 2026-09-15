-- ============================================================
-- BASELINE: dbo.tb_pgto_vinculo_lancamento_manual
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_vinculo_lancamento_manual]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_vinculo_lancamento_manual](
	[pvl_cd_vinculo_lancamento_manual] [int] IDENTITY(1,1) NOT NULL,
	[pvl_cd_lancamento_manual] [int] NULL,
	[pvl_cd_pgto_periodo] [int] NULL,
	[pvl_cd_motorista] [int] NULL,
	[pvl_cd_cliente] [int] NULL,
	[pvl_cd_rota] [varchar](50) NULL,
	[pvl_tipo_lancamento_manual] [varchar](150) NULL,
	[pvl_vl_valor] [decimal](18, 2) NULL,
	[pvl_ds_lancamento] [varchar](150) NOT NULL,
	[pvl_cd_usu_criacao] [int] NOT NULL,
	[pvl_dh_criacao] [datetime] NOT NULL,
	[pvl_cd_usu_alteracao] [int] NOT NULL,
	[pvl_dh_alteracao] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[pvl_cd_vinculo_lancamento_manual] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
