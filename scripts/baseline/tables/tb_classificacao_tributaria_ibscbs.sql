-- ============================================================
-- BASELINE: dbo.tb_classificacao_tributaria_ibscbs
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_classificacao_tributaria_ibscbs]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_classificacao_tributaria_ibscbs](
	[Id] [uniqueidentifier] NOT NULL,
	[Codigo] [varchar](6) NOT NULL,
	[Cst] [varchar](3) NOT NULL,
	[Descricao] [nvarchar](500) NOT NULL,
	[DescricaoReduzida] [nvarchar](200) NULL,
	[ReferenciaLegal] [nvarchar](300) NULL,
	[TipoAliquota] [varchar](30) NULL,
	[PRedIbs] [decimal](7, 4) NULL,
	[PRedCbs] [decimal](7, 4) NULL,
	[AplicavelCte] [bit] NOT NULL,
	[AplicavelNfe] [bit] NOT NULL,
	[Dth_VigenciaInicial] [datetime2](0) NOT NULL,
	[Dth_VigenciaFinal] [datetime2](0) NULL,
	[Excluido] [bit] NOT NULL,
 CONSTRAINT [PK_tb_classificacao_tributaria_ibscbs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
