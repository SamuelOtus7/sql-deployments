-- ============================================================
-- BASELINE: dbo.tb_insert_veiculo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_insert_veiculo]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_insert_veiculo](
	[vei_cd_veiculo] [int] IDENTITY(1,1) NOT NULL,
	[vei_cd_cliente] [int] NOT NULL,
	[vei_ds_placa] [varchar](10) NOT NULL,
	[vei_ds_base] [varchar](50) NOT NULL,
	[vei_ds_tipo] [varchar](50) NOT NULL,
	[vei_in_ativo] [bit] NOT NULL,
	[vei_in_excluido] [bit] NOT NULL,
	[vei_cd_usuario_criacao] [int] NOT NULL,
	[vei_dh_criacao] [datetime] NOT NULL,
	[vei_cd_usuario_modificacao] [int] NOT NULL,
	[vei_dh_modificacao] [datetime] NOT NULL
) ON [PRIMARY]
GO
