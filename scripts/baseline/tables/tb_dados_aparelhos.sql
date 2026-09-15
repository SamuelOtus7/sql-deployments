-- ============================================================
-- BASELINE: dbo.tb_dados_aparelhos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dados_aparelhos]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dados_aparelhos](
	[PartitionKey] [varchar](36) NOT NULL,
	[RowKey] [varchar](36) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[CodigoUsuario] [int] NOT NULL,
	[cordova] [varchar](250) NULL,
	[isiOSAppOnMac] [varchar](250) NULL,
	[isVirtual] [varchar](250) NULL,
	[manufacturer] [varchar](250) NULL,
	[model] [varchar](250) NULL,
	[platform] [varchar](250) NULL,
	[sdkVersion] [varchar](250) NULL,
	[serial] [varchar](250) NULL,
	[uuid] [varchar](250) NULL,
	[version] [varchar](250) NULL,
	[versionApp] [varchar](10) NULL
) ON [PRIMARY]
GO
