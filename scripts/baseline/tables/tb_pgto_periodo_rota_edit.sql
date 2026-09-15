-- ============================================================
-- BASELINE: dbo.tb_pgto_periodo_rota_edit
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_periodo_rota_edit]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_periodo_rota_edit](
	[edit_cd_edit] [int] IDENTITY(1,1) NOT NULL,
	[edit_rota] [varchar](50) NOT NULL,
	[edit_cd_periodo] [int] NOT NULL,
	[edit_cd_espelho] [int] NULL,
	[edit_Service_Center] [varchar](150) NULL,
	[edit_Tipo_Veiculo] [varchar](150) NULL,
	[edit_Faixa_KM] [varchar](50) NULL,
	[edit_Ciclo_PM] [varchar](50) NULL,
	[edit_Placa] [varchar](15) NULL,
	[edit_Quantidade_Pontos] [int] NULL,
	[edit_Quantidade_Paradas] [int] NULL,
	[edit_cd_usr_criacao] [int] NULL,
	[edit_dh_criacao] [datetime] NULL,
	[edit_Quantidade_Pacotes] [int] NULL,
	[edit_usou_app] [varchar](10) NULL,
	[edit_Observacao] [varchar](250) NULL,
	[edit_Regiao] [varchar](250) NULL,
	[edit_RiscoV2] [varchar](5) NULL,
	[edit_Ajudante] [varchar](5) NULL,
	[edit_AreaRisco] [varchar](5) NULL,
	[edit_cidade] [varchar](150) NULL,
	[edit_Total_KM] [decimal](10, 2) NULL,
	[edit_ambulancia] [int] NULL,
	[edit_ds_motivo] [varchar](1000) NULL,
	[edit_zerar_pagamento] [bit] NULL,
	[edit_quantidade_pacotes_entregues] [int] NULL,
	[edit_origem_km] [varchar](50) NULL,
 CONSTRAINT [PK_edit_cd_edit] PRIMARY KEY CLUSTERED 
(
	[edit_cd_edit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_pgto_periodo_rota_edit] UNIQUE NONCLUSTERED 
(
	[edit_rota] ASC,
	[edit_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
