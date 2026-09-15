-- ============================================================
-- BASELINE: dbo.tb_pbi_mon_log_alertas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pbi_mon_log_alertas]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pbi_mon_log_alertas](
	[log_id] [bigint] IDENTITY(1,1) NOT NULL,
	[id_transportadora] [int] NOT NULL,
	[cd_status] [tinyint] NOT NULL,
	[ds_status] [nvarchar](50) NULL,
	[processo_id] [int] NOT NULL,
	[dh_evento] [datetime2](3) NOT NULL,
	[ds_mensagem_erro] [nvarchar](1000) NULL,
	[dh_inicio_atendimento] [datetime2](3) NULL,
 CONSTRAINT [PK_tb_pbi_mon_log_alertas] PRIMARY KEY CLUSTERED 
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
