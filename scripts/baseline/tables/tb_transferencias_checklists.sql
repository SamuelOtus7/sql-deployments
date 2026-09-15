-- ============================================================
-- BASELINE: dbo.tb_transferencias_checklists
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_transferencias_checklists]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_transferencias_checklists](
	[tch_cd_checklist] [int] IDENTITY(1,1) NOT NULL,
	[tch_cd_transferencia] [int] NOT NULL,
	[tch_cd_tipo] [int] NOT NULL,
	[tch_nm_km] [int] NULL,
	[tch_nm_ano_veiculo] [int] NULL,
	[tch_ds_telefone] [varchar](20) NULL,
	[tch_ds_email] [varchar](100) NULL,
	[tch_ds_observacoes] [text] NULL,
	[tch_cd_status] [int] NULL,
	[tch_cd_usuario_criacao] [int] NOT NULL,
	[tch_dh_criacao] [datetime] NOT NULL,
	[tch_cd_usuario_modificacao] [int] NOT NULL,
	[tch_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_tb_transferencias_checklists] PRIMARY KEY CLUSTERED 
(
	[tch_cd_checklist] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
