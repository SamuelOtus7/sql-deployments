-- ============================================================
-- BASELINE: dbo.tb_spe_station
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_station]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_station](
	[IdStation] [int] NOT NULL,
	[IdTransportadora] [int] NULL,
	[CodigoStation] [varchar](25) NULL,
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
	[NomeAmigavel] [varchar](100) NULL,
 CONSTRAINT [PK_tb_spe_station] PRIMARY KEY CLUSTERED 
(
	[IdStation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_spe_station_transportadora_station_nome] UNIQUE NONCLUSTERED 
(
	[IdTransportadora] ASC,
	[IdStation] ASC,
	[NomeStation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
