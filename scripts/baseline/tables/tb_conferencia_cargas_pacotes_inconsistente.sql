-- ============================================================
-- BASELINE: dbo.tb_conferencia_cargas_pacotes_inconsistente
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_conferencia_cargas_pacotes_inconsistente]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_conferencia_cargas_pacotes_inconsistente](
	[cne_cd_conferencia_cargas_pacotes_inconsistente] [int] IDENTITY(1,1) NOT NULL,
	[cne_cd_cliente] [int] NOT NULL,
	[cne_cd_pacote] [varchar](50) NOT NULL,
	[cne_cd_rota] [varchar](20) NOT NULL,
	[cne_dh_conferencia] [datetime] NOT NULL,
	[cne_cd_usuario_inclusao] [int] NOT NULL,
	[cne_nr_rota_origem] [varchar](20) NULL,
	[cne_cd_status_pacote] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[cne_cd_conferencia_cargas_pacotes_inconsistente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
