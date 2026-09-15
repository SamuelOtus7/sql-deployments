-- ============================================================
-- BASELINE: dbo.tb_dra_reprocessamento_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_reprocessamento_rotas]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_reprocessamento_rotas](
	[dar_cd_reprocessamento] [bigint] IDENTITY(1,1) NOT NULL,
	[dar_cd_cliente] [int] NOT NULL,
	[dar_cliente_transportadora] [varchar](30) NOT NULL,
	[dar_tipo_operacao] [varchar](10) NOT NULL,
	[dar_cd_rota] [varchar](30) NOT NULL,
	[dar_ds_status] [varchar](30) NOT NULL,
	[dar_nr_maximo_tentativas] [tinyint] NOT NULL,
	[dar_nr_execucoes] [tinyint] NOT NULL,
	[dar_dh_processamento] [datetime] NULL,
	[dar_ds_resultado_processamento] [varchar](30) NULL,
	[dar_ds_erro_message] [varchar](1000) NULL,
 CONSTRAINT [PK_tb_dra_reprocessamento_rotas] PRIMARY KEY CLUSTERED 
(
	[dar_cd_reprocessamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
