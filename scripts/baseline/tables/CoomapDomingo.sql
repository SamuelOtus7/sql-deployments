-- ============================================================
-- BASELINE: dbo.CoomapDomingo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[CoomapDomingo]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoomapDomingo](
	[ServiceCenter] [nvarchar](50) NOT NULL,
	[Faixa_inicio] [smallint] NOT NULL,
	[Faixa_Fim] [int] NOT NULL,
	[Tipo_veiculo] [nvarchar](50) NOT NULL,
	[Valor_adicional_domingo] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
