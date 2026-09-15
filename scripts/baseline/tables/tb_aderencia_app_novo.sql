-- ============================================================
-- BASELINE: dbo.tb_aderencia_app_novo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_aderencia_app_novo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_aderencia_app_novo](
	[DataReferencia] [date] NOT NULL,
	[NomeMotorista] [varchar](100) NOT NULL,
	[ServiceCenter] [varchar](50) NOT NULL,
	[Base] [varchar](50) NULL,
	[KmColetado] [decimal](10, 5) NOT NULL,
	[LinkMapa] [varchar](1000) NOT NULL,
	[TenantId] [int] NOT NULL,
	[Apontamentos] [int] NOT NULL,
	[StatusApontamento] [int] NOT NULL,
	[PossuiUsuario] [varchar](3) NOT NULL,
	[UltimoAcesso] [datetime] NULL,
	[UltimaRota] [date] NULL,
	[TotalRotas] [int] NULL,
	[UsouApp] [int] NULL,
	[NaoUsouApp] [int] NULL,
	[ListaFiltro] [int] NULL
) ON [PRIMARY]
GO
