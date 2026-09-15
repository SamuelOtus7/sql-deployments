-- ============================================================
-- BASELINE: dbo.tb_ouvidoria
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ouvidoria]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ouvidoria](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nome] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[Matricula] [int] NULL,
	[IdTipoManifestacao] [int] NOT NULL,
	[IdSetor] [int] NOT NULL,
	[IdStatus] [int] NOT NULL,
	[Anonimo] [bit] NOT NULL,
	[DescricaoManifestacao] [varchar](500) NOT NULL,
	[DataHoraCriacao] [datetime] NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[IdCliente] [int] NOT NULL,
	[IdArquivo] [bigint] NULL,
	[Procedente] [bit] NOT NULL,
 CONSTRAINT [PK__tb_ouvid__3214EC075345E468] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
