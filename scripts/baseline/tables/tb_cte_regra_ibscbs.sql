-- ============================================================
-- BASELINE: dbo.tb_cte_regra_ibscbs
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_cte_regra_ibscbs]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_cte_regra_ibscbs](
	[Id] [uniqueidentifier] NOT NULL,
	[TenantId] [int] NULL,
	[Cfop] [varchar](6) NULL,
	[CstIcms] [int] NULL,
	[RegimeTributario] [int] NULL,
	[TipoServico] [int] NULL,
	[CstIbscbs] [varchar](3) NOT NULL,
	[CClassTrib] [varchar](6) NOT NULL,
	[Prioridade] [int] NOT NULL,
	[Dth_VigenciaInicial] [datetime2](0) NOT NULL,
	[Dth_VigenciaFinal] [datetime2](0) NULL,
	[Excluido] [bit] NOT NULL,
 CONSTRAINT [PK_tb_cte_regra_ibscbs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
