-- ============================================================
-- BASELINE: dbo.tb_tipo_veiculo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tipo_veiculo]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tipo_veiculo](
	[tv_cd_tipo_veiculo] [int] IDENTITY(1,1) NOT NULL,
	[tv_ds_tipo_veiculo] [varchar](255) NULL,
	[tv_nm_tipo_veiculo] [varchar](150) NOT NULL,
	[tv_fl_excluido] [bit] NOT NULL,
	[tv_cd_usuario_criacao] [int] NOT NULL,
	[tv_cd_usuario_modificacao] [int] NULL,
	[tv_cd_cliente] [int] NOT NULL,
	[tv_dh_criacao] [datetime2](7) NOT NULL,
	[tv_dh_atualizacao] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tv_cd_tipo_veiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
