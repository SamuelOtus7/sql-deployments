-- ============================================================
-- BASELINE: dbo.tb_ml_motoristas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_motoristas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_motoristas](
	[IdMotorista] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[CPF] [varchar](14) NULL,
	[CNPJ] [varchar](14) NULL,
	[Nome] [varchar](60) NULL,
	[Ativo] [bit] NOT NULL,
	[Email] [varchar](60) NULL,
	[Telefone] [varchar](20) NULL,
	[DataCriacao] [datetime] NULL,
	[UltimaAtualizacao] [datetime] NULL,
	[IdSite] [varchar](30) NULL,
	[DataColeta] [datetime] NOT NULL,
	[ajudante] [bit] NULL,
 CONSTRAINT [pk_tb_ml_motoristas] PRIMARY KEY CLUSTERED 
(
	[IdMotorista] ASC,
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
