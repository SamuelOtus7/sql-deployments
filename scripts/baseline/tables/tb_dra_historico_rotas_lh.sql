-- ============================================================
-- BASELINE: dbo.tb_dra_historico_rotas_lh
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_historico_rotas_lh]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_historico_rotas_lh](
	[dhl_cd_historico_rota_lh] [bigint] IDENTITY(1,1) NOT NULL,
	[dhl_cd_cliente] [int] NOT NULL,
	[dhl_dh_coleta] [datetime2](3) NOT NULL,
	[dhl_dh_inclusao] [datetime2](3) NOT NULL,
	[dhl_dh_atualizacao] [datetime2](3) NOT NULL,
	[dhl_nr_route_id] [bigint] NOT NULL,
	[dhl_nr_rostering_id] [bigint] NULL,
	[dhl_ds_servico] [varchar](100) NULL,
	[dhl_dt_servico] [date] NULL,
	[dhl_ds_parceiro] [nvarchar](200) NULL,
	[dhl_ds_tipo_veiculo] [varchar](50) NULL,
	[dhl_nr_motorista_1] [bigint] NULL,
	[dhl_ds_nome_motorista_1] [nvarchar](200) NULL,
	[dhl_nr_motorista_2] [bigint] NULL,
	[dhl_ds_nome_motorista_2] [nvarchar](200) NULL,
	[dhl_ds_placa_trator] [varchar](20) NULL,
	[dhl_ds_placa_carga_1] [varchar](20) NULL,
	[dhl_ds_placa_carga_2] [varchar](20) NULL,
	[dhl_nr_trecho] [int] NULL,
	[dhl_ds_origem] [varchar](20) NULL,
	[dhl_dh_origem_eta] [datetime2](3) NULL,
	[dhl_dh_origem_ata] [datetime2](3) NULL,
	[dhl_ds_fonte_ata_origem] [varchar](50) NULL,
	[dhl_dh_origem_etd] [datetime2](3) NULL,
	[dhl_dh_origem_atd] [datetime2](3) NULL,
	[dhl_ds_fonte_atd_origem] [varchar](50) NULL,
	[dhl_ds_pre_checkin_origem] [nvarchar](100) NULL,
	[dhl_ds_timezone_origem] [nvarchar](100) NULL,
	[dhl_ds_destino] [varchar](20) NULL,
	[dhl_dh_destino_eta] [datetime2](3) NULL,
	[dhl_dh_destino_ata] [datetime2](3) NULL,
	[dhl_dh_destino_atd] [datetime2](3) NULL,
	[dhl_dh_destino_etd] [datetime2](3) NULL,
	[dhl_ds_fonte_ata_destino] [varchar](50) NULL,
	[dhl_dh_previsao_chegada] [datetime2](3) NULL,
	[dhl_dh_ultima_atualizacao] [datetime2](3) NULL,
	[dhl_ds_pre_checkin_destino] [nvarchar](100) NULL,
	[dhl_ds_timezone_destino] [nvarchar](100) NULL,
	[dhl_ds_tempo_transito_estimado] [varchar](20) NULL,
	[dhl_ds_tempo_transito_real] [varchar](20) NULL,
	[dhl_nr_hus] [int] NULL,
	[dhl_nr_pacotes] [int] NULL,
	[dhl_ds_occupation] [varchar](20) NULL,
	[dhl_ds_estado] [nvarchar](50) NULL,
	[dhl_ds_substatus] [nvarchar](50) NULL,
	[dhl_ds_nota] [nvarchar](500) NULL,
	[dhl_ds_motivo_cancelamento] [nvarchar](500) NULL,
	[dhl_ds_causa_raiz_incidente] [nvarchar](500) NULL,
	[dhl_ds_ots] [varchar](50) NULL,
	[dhl_ds_otd] [varchar](50) NULL,
	[dhl_ds_ota] [varchar](50) NULL,
	[dhl_ds_otr] [varchar](50) NULL,
	[dhl_ds_fonte_atd_destino] [varchar](50) NULL,
 CONSTRAINT [PK_tb_dra_historico_rotas_lh] PRIMARY KEY CLUSTERED 
(
	[dhl_cd_historico_rota_lh] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_dra_historico_rotas_lh_rota_cliente] UNIQUE NONCLUSTERED 
(
	[dhl_nr_route_id] ASC,
	[dhl_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
