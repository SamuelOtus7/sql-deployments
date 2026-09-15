-- ============================================================
-- BASELINE: dbo.tb_trg_CIOTHistorico
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_trg_CIOTHistorico]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_trg_CIOTHistorico](
	[IdHistoricoCiot] [int] IDENTITY(1,1) NOT NULL,
	[Metodo] [varchar](255) NOT NULL,
	[IdTenant] [int] NOT NULL,
	[StatusTransportador] [int] NULL,
	[StatusMotorista] [int] NULL,
	[StatusParticipante] [int] NULL,
	[StatusCiot] [int] NULL,
	[IdTransportador] [int] NULL,
	[IdMotorista] [int] NULL,
	[IdParticipante] [int] NULL,
	[IdCiot] [int] NULL,
	[Request] [varchar](max) NULL,
	[Response] [varchar](max) NULL,
	[Erro] [varchar](max) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NULL,
	[Retentativa] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdHistoricoCiot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
