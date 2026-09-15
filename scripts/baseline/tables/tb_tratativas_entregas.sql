-- ============================================================
-- BASELINE: dbo.tb_tratativas_entregas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tratativas_entregas]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tratativas_entregas](
	[idtransportadora] [int] NOT NULL,
	[idrota] [varchar](255) NULL,
	[idpacote] [varchar](255) NULL,
	[MotivoTratativa] [varchar](max) NULL,
	[Status] [varchar](max) NULL,
	[Observacao] [varchar](max) NULL,
	[Imagem] [varchar](max) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataCriacao] [datetime] NULL,
	[DataAtualizacao] [datetime] NULL,
	[UsuarioTratativa] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
