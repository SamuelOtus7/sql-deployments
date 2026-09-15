-- ============================================================
-- BASELINE: dbo.tb_spe_pacotes_lh
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_pacotes_lh]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_pacotes_lh](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[CodigoRota] [varchar](20) NOT NULL,
	[CodigoPacote] [varchar](20) NOT NULL,
	[StationId] [int] NOT NULL,
	[ChegadaNaEstacao] [datetime2](7) NULL,
 CONSTRAINT [pk_spe_pacotes_lh] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY],
 CONSTRAINT [uk_spe_rotas_lh] UNIQUE NONCLUSTERED 
(
	[IdTransportadora] ASC,
	[CodigoRota] ASC,
	[CodigoPacote] ASC,
	[StationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_spe_pacotes_lh_Chave] UNIQUE NONCLUSTERED 
(
	[CodigoPacote] ASC,
	[CodigoRota] ASC,
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
