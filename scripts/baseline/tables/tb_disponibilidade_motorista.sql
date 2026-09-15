-- ============================================================
-- BASELINE: dbo.tb_disponibilidade_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_disponibilidade_motorista]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_disponibilidade_motorista](
	[dpm_cd_disponibilidade_motorista] [int] IDENTITY(1,1) NOT NULL,
	[dpm_cd_usuario] [int] NOT NULL,
	[dpm_cd_cliente] [int] NOT NULL,
	[dpm_dh_data] [datetime] NOT NULL,
	[dpm_cd_tipoVeiculo] [int] NOT NULL,
	[dpm_ds_periodo] [varchar](20) NOT NULL,
	[dpm_in_excluido] [bit] NOT NULL,
	[dpm_cd_usuario_criacao] [int] NOT NULL,
	[dpm_dh_criacao] [datetime] NOT NULL,
	[dpm_cd_usuario_modificacao] [int] NOT NULL,
	[dpm_dh_modificacao] [datetime] NOT NULL,
	[dpm_base] [varchar](50) NOT NULL,
	[dpm_in_disponivel] [bit] NOT NULL,
	[dpm_cd_motivo] [int] NULL,
	[dpm_ds_observacao] [nvarchar](500) NULL,
 CONSTRAINT [pk_disponibilidade_motorista] PRIMARY KEY CLUSTERED 
(
	[dpm_cd_disponibilidade_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
