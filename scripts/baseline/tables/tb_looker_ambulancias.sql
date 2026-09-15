-- ============================================================
-- BASELINE: dbo.tb_looker_ambulancias
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_looker_ambulancias]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_looker_ambulancias](
	[amb_id] [int] IDENTITY(1,1) NOT NULL,
	[amb_data] [date] NOT NULL,
	[amb_cd_transportadora] [bigint] NOT NULL,
	[amb_nome_transportadora] [varchar](255) NOT NULL,
	[amb_id_rota] [bigint] NOT NULL,
	[amb_id_motorista] [bigint] NOT NULL,
	[amb_svc] [varchar](50) NOT NULL,
	[amb_status] [varchar](100) NOT NULL,
	[amb_pagamento] [varchar](50) NOT NULL,
	[amb_codigocliente] [int] NOT NULL,
	[amb_data_etl] [datetime] NOT NULL,
	[amb_motivo] [varchar](max) NULL,
 CONSTRAINT [PK_tb_looker_ambulancias_1] PRIMARY KEY CLUSTERED 
(
	[amb_id_rota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
