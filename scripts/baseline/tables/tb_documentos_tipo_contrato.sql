-- ============================================================
-- BASELINE: dbo.tb_documentos_tipo_contrato
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_documentos_tipo_contrato]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_documentos_tipo_contrato](
	[dtc_cd_documento_tipo_contrato] [int] IDENTITY(1,1) NOT NULL,
	[dtc_cd_tipo_contrato] [int] NULL,
	[dtc_cd_documento] [int] NULL,
	[dtc_in_ativo] [bit] NOT NULL,
	[dtc_in_excluido] [bit] NOT NULL,
 CONSTRAINT [pk_documento_tipo_contrato] PRIMARY KEY CLUSTERED 
(
	[dtc_cd_documento_tipo_contrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
