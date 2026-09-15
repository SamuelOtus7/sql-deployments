-- ============================================================
-- BASELINE: dbo.tb_ouvidoria_respostas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ouvidoria_respostas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ouvidoria_respostas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdOuvidoria] [int] NOT NULL,
	[Mensagem] [varchar](500) NOT NULL,
	[DataHoraCriacao] [datetime] NOT NULL,
	[IsRespostaEmpresa] [bit] NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[IdSetor] [int] NULL,
	[NomeUsuario] [varchar](100) NULL,
	[IdArquivo] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
