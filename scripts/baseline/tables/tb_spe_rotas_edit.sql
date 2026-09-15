-- ============================================================
-- BASELINE: dbo.tb_spe_rotas_edit
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_rotas_edit]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_rotas_edit](
	[CodigoRotaEdit] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[CodigoRota] [varchar](50) NOT NULL,
	[TipoOperacao] [varchar](2) NOT NULL,
	[NomeMotorista] [varchar](80) NOT NULL,
	[Placa] [varchar](30) NOT NULL,
	[CodigoUsuarioInsercao] [int] NOT NULL,
	[UsuarioCriacao] [int] NOT NULL,
	[DataHoraCriacao] [datetime] NOT NULL,
	[UsuarioModificacao] [int] NULL,
	[DataHoraModificacao] [datetime] NULL,
 CONSTRAINT [PK_tb_spe_rotas_edit] PRIMARY KEY CLUSTERED 
(
	[CodigoRotaEdit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_spe_rotas_edit] UNIQUE NONCLUSTERED 
(
	[IdTransportadora] ASC,
	[CodigoRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
