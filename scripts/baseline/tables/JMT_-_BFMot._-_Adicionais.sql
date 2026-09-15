-- ============================================================
-- BASELINE: dbo.JMT_-_BFMot._-_Adicionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[JMT_-_BFMot._-_Adicionais]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JMT_-_BFMot._-_Adicionais](
	[Tipo de contrato] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Cidade] [varchar](max) NULL,
	[Tipo de veículo] [bigint] NULL,
	[Valor adicional pacotes ] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
