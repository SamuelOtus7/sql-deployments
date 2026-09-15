-- ============================================================
-- BASELINE: dbo.Tb_sin_sinistros_excel
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Tb_sin_sinistros_excel]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tb_sin_sinistros_excel](
	[PROCESSO] [varchar](255) NULL,
	[CLIENTE] [varchar](255) NULL,
	[ANO] [varchar](255) NULL,
	[DATA] [varchar](255) NULL,
	[CODIGO] [varchar](255) NULL,
	[MOTORISTA] [varchar](255) NULL,
	[SVC] [varchar](255) NULL,
	[ROTA] [varchar](255) NULL,
	[PREJUÍZO] [varchar](255) NULL,
	[QTDE] [varchar](255) NULL,
	[PLACA] [varchar](10) NULL,
	[VEICULO] [varchar](255) NULL,
	[BAIRRO] [varchar](255) NULL,
	[CIDADE] [varchar](255) NULL,
	[BO] [varchar](255) NULL,
	[LINK_BO] [varchar](255) NULL,
	[E_MAIL] [varchar](255) NULL,
	[OBSERVAÇÃO] [varchar](255) NULL,
	[Unnamed_18] [varchar](255) NULL,
	[Unnamed_19] [varchar](255) NULL,
	[Unnamed_20] [varchar](255) NULL,
	[Unnamed_21] [varchar](255) NULL,
	[Unnamed_22] [varchar](255) NULL,
	[Unnamed_23] [varchar](255) NULL
) ON [PRIMARY]
GO
