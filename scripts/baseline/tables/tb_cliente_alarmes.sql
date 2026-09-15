-- ============================================================
-- BASELINE: dbo.tb_cliente_alarmes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_cliente_alarmes]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_cliente_alarmes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[id_alarme] [int] NOT NULL,
	[tenant] [int] NULL
) ON [PRIMARY]
GO
