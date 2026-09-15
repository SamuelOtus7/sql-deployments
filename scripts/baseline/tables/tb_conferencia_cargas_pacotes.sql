-- ============================================================
-- BASELINE: dbo.tb_conferencia_cargas_pacotes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_conferencia_cargas_pacotes]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_conferencia_cargas_pacotes](
	[cfp_cd_conferencia_cargas_pacotes] [int] IDENTITY(1,1) NOT NULL,
	[cfp_cd_conferencia_cargas] [int] NOT NULL,
	[cfp_ds_pacote] [varchar](20) NOT NULL,
	[cfp_cd_status_pacote] [int] NOT NULL,
	[cfp_cd_tipo_pacote] [int] NOT NULL,
	[cfp_cd_cliente] [int] NOT NULL,
	[cfp_dh_created_at] [datetime] NULL,
	[cfp_dh_conferencia] [datetime] NULL,
	[cfp_cd_usuario_conferencia] [int] NULL,
	[cfp_nr_gaiola] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[cfp_cd_conferencia_cargas_pacotes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
