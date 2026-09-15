-- ============================================================
-- BASELINE: dbo.tb_spe_pacotes_FM
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_pacotes_FM]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_pacotes_FM](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdWebhook] [bigint] NOT NULL,
	[DataCriacaoRegistro] [datetime] NOT NULL,
	[TipoJson] [varchar](50) NOT NULL,
	[Agencia] [int] NULL,
	[IdTransportadora] [bigint] NOT NULL,
	[CodigoTrace] [varchar](200) NULL,
	[CodigoRota] [bigint] NULL,
	[CodigoPacote] [varchar](50) NOT NULL,
	[StatusPacote] [varchar](50) NULL,
	[PickupPointId] [varchar](100) NULL,
	[DataHoraEvento] [datetime] NULL,
	[DataEventoUnix] [datetime] NULL,
	[DataCriacaoPacote]  AS (CONVERT([date],[DataHoraEvento])) PERSISTED,
	[UltimoRegistro] [bit] NULL,
	[Excluido] [bit] NULL,
	[DataAtualizacao] [datetime] NULL,
	[DataInclusao] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
