-- ============================================================
-- BASELINE: dbo.tb_log_aprovacao_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_log_aprovacao_motorista]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_log_aprovacao_motorista](
	[lam_cd_log_aprovacao_motorista] [int] IDENTITY(1,1) NOT NULL,
	[lam_cd_cliente] [int] NOT NULL,
	[lam_cd_usuario] [int] NOT NULL,
	[lam_dh_aprovacao] [datetime] NOT NULL,
	[lam_nm_motorista] [nvarchar](500) NOT NULL,
	[lam_in_sucesso] [bit] NOT NULL,
	[lam_ds_motivo] [nvarchar](max) NULL,
	[lam_ds_tipo] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[lam_cd_log_aprovacao_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
