-- ============================================================
-- BASELINE: dbo.ExportReturnParceiro_Tmp
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[ExportReturnParceiro_Tmp]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExportReturnParceiro_Tmp](
	[DataReferencia] [nvarchar](50) NULL,
	[TipoLogistica] [nvarchar](100) NULL,
	[Facility] [nvarchar](50) NULL,
	[IdRota] [nvarchar](50) NULL,
	[IdMotorista] [nvarchar](50) NULL,
	[NomeMotorista] [nvarchar](200) NULL,
	[PacotesPlanejados] [nvarchar](50) NULL,
	[PacotesColetados] [nvarchar](50) NULL,
	[PacotesNaoColetados] [nvarchar](50) NULL,
	[Paradas] [nvarchar](50) NULL,
	[PacotesColetadosOnTime] [nvarchar](50) NULL,
	[PacotesColetadosEarly] [nvarchar](50) NULL,
	[PacotesColetadosLate] [nvarchar](50) NULL,
	[ParadasComNoShow] [nvarchar](50) NULL,
	[CulpabilidadeL1] [nvarchar](100) NULL,
	[CulpabilidadeL2] [nvarchar](200) NULL,
	[CulpabilidadeL3] [nvarchar](200) NULL
) ON [PRIMARY]
GO
