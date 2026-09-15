-- ============================================================
-- BASELINE: dbo.DimData
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[DimData]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimData](
	[SkData] [int] NOT NULL,
	[Data] [date] NOT NULL,
	[DiaMes] [tinyint] NOT NULL,
	[NumDiaSemana] [tinyint] NOT NULL,
	[DiaDaSemana] [varchar](13) NOT NULL,
	[Dezena] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[Mes] [varchar](13) NOT NULL,
	[MesAbreviado] [varchar](3) NOT NULL,
	[NumMes] [tinyint] NOT NULL,
	[MesAno] [varchar](10) NOT NULL,
	[MesAnoInt] [int] NOT NULL,
	[MesPonto] [varchar](20) NOT NULL,
	[Bimestre] [tinyint] NOT NULL,
	[Trimestre] [tinyint] NOT NULL,
	[Semestre] [tinyint] NOT NULL,
	[Ano] [smallint] NOT NULL,
	[Feriado] [bit] NOT NULL,
	[DiaUtil] [bit] NOT NULL,
	[SemanaAno] [tinyint] NOT NULL,
	[PeriodoSemana] [varchar](10) NOT NULL,
	[DataSemanaAno] [varchar](50) NULL,
 CONSTRAINT [pk_DimData] PRIMARY KEY CLUSTERED 
(
	[SkData] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
