-- ============================================================
-- BASELINE: dbo.tb_tipo_permissoes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tipo_permissoes]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tipo_permissoes](
	[tpp_cd_tipo_permissoes] [int] IDENTITY(1,1) NOT NULL,
	[tpp_cd_veiculo] [int] NOT NULL,
	[tpp_cd_placa] [varchar](50) NULL,
	[tpp_cod_cliente] [int] NULL,
	[tpp_ds_tipo] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tpp_cd_tipo_permissoes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
