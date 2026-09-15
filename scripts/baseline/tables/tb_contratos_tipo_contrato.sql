-- ============================================================
-- BASELINE: dbo.tb_contratos_tipo_contrato
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos_tipo_contrato]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos_tipo_contrato](
	[ctn_cd_contrato_tipo_contrato] [int] IDENTITY(1,1) NOT NULL,
	[ctn_cd_tipo_contrato] [int] NULL,
	[ctn_cd_contrato] [int] NULL,
	[ctn_in_ativo] [bit] NOT NULL,
	[ctn_in_excluido] [bit] NOT NULL,
 CONSTRAINT [pk_contrato_tipo_contrato] PRIMARY KEY CLUSTERED 
(
	[ctn_cd_contrato_tipo_contrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
