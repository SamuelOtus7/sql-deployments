-- ============================================================
-- BASELINE: dbo.tb_spe_status_pacote
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_status_pacote]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_status_pacote](
	[stp_cd_status] [int] IDENTITY(1,1) NOT NULL,
	[stp_json_codigo] [int] NULL,
	[stp_descricao] [varchar](150) NULL
) ON [PRIMARY]
GO
