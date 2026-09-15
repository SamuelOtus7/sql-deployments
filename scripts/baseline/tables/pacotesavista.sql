-- ============================================================
-- BASELINE: dbo.pacotesavista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[pacotesavista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pacotesavista](
	[CodigoRota] [nvarchar](50) NOT NULL,
	[DataReferencia] [nvarchar](50) NOT NULL,
	[PacotesEntregues] [tinyint] NOT NULL,
	[TotalPacotes] [tinyint] NOT NULL
) ON [PRIMARY]
GO
