-- ============================================================
-- BASELINE: dbo.tb_transferencias_checklists_justificativas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_transferencias_checklists_justificativas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_transferencias_checklists_justificativas](
	[tcj_cd_justificativa] [int] IDENTITY(1,1) NOT NULL,
	[tcj_cd_transferencia_checklist] [int] NOT NULL,
	[tcj_ds_justificativa] [text] NULL,
	[tcj_cd_usuario_criacao] [int] NOT NULL,
	[tcj_dh_criacao] [datetime] NOT NULL,
	[tcj_cd_usuario_modificacao] [int] NOT NULL,
	[tcj_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_tb_transferencias_checklists_justificativas] PRIMARY KEY CLUSTERED 
(
	[tcj_cd_justificativa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
