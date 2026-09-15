-- ============================================================
-- BASELINE: dbo.tb_indisponibilidade_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_indisponibilidade_motorista]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_indisponibilidade_motorista](
	[idp_cd_indisponibilidade_motorista] [int] IDENTITY(1,1) NOT NULL,
	[idp_cd_usuario] [int] NOT NULL,
	[idp_cd_cliente] [int] NOT NULL,
	[idp_dt_indisponibilidade] [date] NOT NULL,
	[idp_cd_motivo] [int] NOT NULL,
	[idp_ds_observacao] [nvarchar](max) NOT NULL,
	[idp_ds_ciclo] [varchar](10) NOT NULL,
	[idp_ds_base] [varchar](50) NOT NULL,
	[idp_ds_veiculo] [varchar](100) NOT NULL,
	[idp_dh_registro] [datetime] NOT NULL,
	[idp_in_cancelado] [bit] NOT NULL,
	[idp_cd_usuario_criacao] [int] NOT NULL,
	[idp_dh_criacao] [datetime] NOT NULL,
	[idp_cd_usuario_modificacao] [int] NULL,
	[idp_dh_modificacao] [datetime] NULL,
 CONSTRAINT [PK_tb_indisponibilidade_motorista] PRIMARY KEY CLUSTERED 
(
	[idp_cd_indisponibilidade_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
