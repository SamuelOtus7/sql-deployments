-- ============================================================
-- BASELINE: dbo.tb_comprovantes_tipo_contrato
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_comprovantes_tipo_contrato]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_comprovantes_tipo_contrato](
	[ctc_cd_comprovante_tipo_contrato] [int] IDENTITY(1,1) NOT NULL,
	[ctc_cd_tipo_contrato] [int] NULL,
	[ctc_cd_comprovante] [int] NULL,
	[ctc_in_ativo] [bit] NOT NULL,
	[ctc_in_excluido] [bit] NOT NULL,
 CONSTRAINT [pk_comprovante_tipo_contrato] PRIMARY KEY CLUSTERED 
(
	[ctc_cd_comprovante_tipo_contrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
