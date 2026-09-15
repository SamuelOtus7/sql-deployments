-- ============================================================
-- BASELINE: dbo.tb_ouvidoria_setores
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ouvidoria_setores]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ouvidoria_setores](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NomeSetor] [varchar](100) NOT NULL,
	[IdCliente] [int] NOT NULL,
	[DataHoraCriacao] [datetime] NOT NULL,
	[IdUsuarioCriacao] [int] NOT NULL,
	[DataHoraModificacao] [datetime] NOT NULL,
	[IdUsuarioModificacao] [int] NOT NULL,
	[Ativo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
