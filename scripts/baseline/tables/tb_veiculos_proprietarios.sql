-- ============================================================
-- BASELINE: dbo.tb_veiculos_proprietarios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_veiculos_proprietarios]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_veiculos_proprietarios](
	[vep_cd_veiculo] [int] NOT NULL,
	[vep_cd_motorista] [int] NOT NULL,
	[vep_cd_cliente] [int] NOT NULL,
	[vep_ds_rntrc] [varchar](20) NULL,
	[vep_ds_uf] [varchar](2) NULL,
	[vep_dh_criacao] [datetime] NOT NULL,
	[vep_cd_usuario_criacao] [int] NULL,
	[vep_dh_modificacao] [datetime] NULL,
	[vep_cd_usuario_modificacao] [int] NULL,
 CONSTRAINT [PK_tb_veiculos_proprietarios] PRIMARY KEY CLUSTERED 
(
	[vep_cd_veiculo] ASC,
	[vep_cd_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
