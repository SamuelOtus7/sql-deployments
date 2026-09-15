-- ============================================================
-- BASELINE: dbo.SqlServerVersions
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[SqlServerVersions]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SqlServerVersions](
	[MajorVersionNumber] [tinyint] NOT NULL,
	[MinorVersionNumber] [smallint] NOT NULL,
	[Branch] [varchar](34) NOT NULL,
	[Url] [varchar](99) NOT NULL,
	[ReleaseDate] [date] NOT NULL,
	[MainstreamSupportEndDate] [date] NOT NULL,
	[ExtendedSupportEndDate] [date] NOT NULL,
	[MajorVersionName] [varchar](19) NOT NULL,
	[MinorVersionName] [varchar](67) NOT NULL,
 CONSTRAINT [PK_SqlServerVersions] PRIMARY KEY CLUSTERED 
(
	[MajorVersionNumber] ASC,
	[MinorVersionNumber] ASC,
	[ReleaseDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
