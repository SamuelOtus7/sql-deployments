-- ============================================================
-- BASELINE: dbo.tb_spe_stationsv2
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_stationsv2]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_stationsv2](
	[IdStation] [int] NOT NULL,
	[IdTransportadora] [int] NULL,
	[CodigoStation] [nvarchar](50) NULL,
	[NomeStation] [varchar](60) NOT NULL,
	[IdCidade] [int] NULL,
	[IdCidadeReferencia] [int] NULL,
	[Cidade] [varchar](60) NULL,
	[Cep] [varchar](8) NULL,
	[Latitude] [varchar](15) NULL,
	[Longitude] [varchar](15) NULL,
	[Endereco] [varchar](100) NULL,
	[NomeContato] [varchar](60) NULL,
	[EmailContato] [varchar](60) NULL,
	[TelefoneContato] [varchar](15) NULL,
	[PropriaFrota] [bit] NULL,
	[Estado] [varchar](30) NULL,
	[NomeAmigavel] [varchar](100) NULL
) ON [PRIMARY]
GO
