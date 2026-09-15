-- ============================================================
-- BASELINE: dbo.tb_integracao_flex_eventos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_integracao_flex_eventos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_integracao_flex_eventos](
	[iev_cd_codigo_evento] [int] IDENTITY(1,1) NOT NULL,
	[iev_cd_codigo_cliente] [int] NOT NULL,
	[iev_ds_placa] [varchar](255) NOT NULL,
	[iev_cd_motorista_cpf] [varchar](20) NOT NULL,
	[iev_cd_numero_cartao] [varchar](255) NOT NULL,
	[iev_ds_nome_motorista] [varchar](255) NULL,
	[iev_ds_rede_posto] [varchar](255) NULL,
	[iev_nm_qtde_litros] [decimal](10, 2) NULL,
	[iev_nm_valor_unitario] [decimal](10, 2) NULL,
	[iev_nm_valor_abastecido] [decimal](10, 2) NULL,
	[iev_nm_hodometro_anterior] [int] NULL,
	[iev_nm_hodometro_atual] [int] NULL,
	[iev_dh_data_hora_evento] [datetime] NULL,
	[iev_dh_data_hora_consulta] [datetime] NULL,
	[iev_dh_data_hora_evento_utc] [datetime2](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[iev_cd_codigo_evento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
