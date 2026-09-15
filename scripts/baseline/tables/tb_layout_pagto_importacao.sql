-- ============================================================
-- BASELINE: dbo.tb_layout_pagto_importacao
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_layout_pagto_importacao]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_layout_pagto_importacao](
	[Data] [date] NOT NULL,
	[Motorista] [nvarchar](255) NOT NULL,
	[Valor_Variavel] [decimal](10, 2) NULL,
	[Valor_Fixo] [decimal](10, 2) NULL,
	[KM_Excedente] [decimal](10, 2) NULL,
	[Ajudante] [int] NULL,
	[KM_Rodados] [decimal](10, 2) NULL,
	[Valor_Total] [decimal](10, 2) NULL,
	[Status] [nvarchar](50) NULL,
	[ID_Rota] [nvarchar](50) NOT NULL,
	[Placa] [nvarchar](20) NOT NULL,
	[Falha_de_entrega] [int] NULL,
	[SPR] [int] NULL,
	[Veiculo] [nvarchar](100) NOT NULL,
	[SVC] [nvarchar](50) NULL,
	[Service_Center] [nvarchar](50) NULL,
	[Facility] [nvarchar](50) NULL,
	[Ciclo] [nvarchar](10) NULL,
	[Pontos] [int] NULL,
	[Paradas] [int] NULL
) ON [PRIMARY]
GO
