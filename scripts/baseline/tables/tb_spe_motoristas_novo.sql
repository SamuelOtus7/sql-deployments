-- ============================================================
-- BASELINE: dbo.tb_spe_motoristas_novo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_motoristas_novo]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_motoristas_novo](
	[IdMotorista] [int] NOT NULL,
	[IdTransportadora] [int] NULL,
	[IdStation] [int] NULL,
	[Nome] [varchar](80) NOT NULL,
	[TipoVeiculo] [varchar](60) NULL,
	[Placa] [varchar](7) NULL,
	[Transportadora] [varchar](60) NULL,
	[NomeMotorista] [varchar](60) NULL,
 CONSTRAINT [PK_tb_spe_motoristas_novo] PRIMARY KEY CLUSTERED 
(
	[IdMotorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
