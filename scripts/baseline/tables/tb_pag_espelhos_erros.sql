-- ============================================================
-- BASELINE: dbo.tb_pag_espelhos_erros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_espelhos_erros]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_espelhos_erros](
	[pee_id] [int] IDENTITY(1,1) NOT NULL,
	[pee_cd_motorista] [int] NULL,
	[pee_nm_motorista] [varchar](500) NULL,
	[pee_base] [varchar](50) NULL,
	[pee_cd_periodo] [int] NOT NULL,
	[pee_ds_erro] [varchar](500) NOT NULL,
	[pee_dh_criacao] [datetime] NOT NULL,
	[pee_cd_cliente_transportadora] [int] NULL,
	[pee_cd_operacao] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[pee_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
