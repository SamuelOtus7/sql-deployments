-- ============================================================
-- BASELINE: dbo.tb_logistics_fat_motoristas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_logistics_fat_motoristas]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_logistics_fat_motoristas](
	[data] [date] NOT NULL,
	[rota] [int] NOT NULL,
	[motorista] [varchar](150) NOT NULL,
	[entregas] [int] NOT NULL,
	[km] [decimal](18, 9) NOT NULL,
	[valor] [decimal](18, 9) NOT NULL,
	[sucesso] [smallint] NOT NULL,
	[insucesso] [smallint] NOT NULL,
	[url_maps] [varchar](1000) NOT NULL,
	[usuario_motorista] [int] NOT NULL,
	[status_aprovacao] [varchar](100) NOT NULL,
	[datahora_aprovacao] [datetime] NOT NULL,
	[usuario_aprovacao] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL
) ON [PRIMARY]
GO
