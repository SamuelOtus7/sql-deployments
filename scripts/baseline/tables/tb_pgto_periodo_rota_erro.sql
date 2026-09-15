-- ============================================================
-- BASELINE: dbo.tb_pgto_periodo_rota_erro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_periodo_rota_erro]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_periodo_rota_erro](
	[pre_id] [int] IDENTITY(1,1) NOT NULL,
	[pre_cd_rota] [varchar](50) NOT NULL,
	[pre_base] [varchar](50) NULL,
	[pre_cd_periodo] [int] NOT NULL,
	[pre_ds_erro] [varchar](500) NOT NULL,
	[pre_dh_criacao] [datetime] NOT NULL,
	[pre_cd_cliente_transportadora] [int] NULL,
	[pre_cd_operacao] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[pre_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
