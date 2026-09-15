-- ============================================================
-- BASELINE: dbo.stg_rotas_lh_csv_raw
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_rotas_lh_csv_raw]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_rotas_lh_csv_raw](
	[raw_id] [int] IDENTITY(1,1) NOT NULL,
	[c_route_id] [nvarchar](50) NULL,
	[c_rostering_id] [nvarchar](50) NULL,
	[c_servico] [nvarchar](120) NULL,
	[c_data_servico] [nvarchar](30) NULL,
	[c_motorista] [nvarchar](200) NULL,
	[c_tipo_veiculo] [nvarchar](60) NULL,
	[c_id_motorista_1] [nvarchar](50) NULL,
	[c_nome_motorista_1] [nvarchar](120) NULL,
	[c_id_motorista_2] [nvarchar](50) NULL,
	[c_nome_motorista_2] [nvarchar](120) NULL,
	[c_veiculo_trator] [nvarchar](50) NULL,
	[c_veiculo_carga_1] [nvarchar](50) NULL,
	[c_veiculo_carga_2] [nvarchar](50) NULL,
	[c_trecho] [nvarchar](20) NULL,
	[c_origem] [nvarchar](60) NULL,
	[c_origem_eta] [nvarchar](30) NULL,
	[c_origem_ata] [nvarchar](30) NULL,
	[c_fonte_ata_origem] [nvarchar](60) NULL,
	[c_origem_etd] [nvarchar](30) NULL,
	[c_origem_atd] [nvarchar](30) NULL,
	[c_fonte_atd_origem] [nvarchar](60) NULL,
	[c_pre_checkin_origem] [nvarchar](30) NULL,
	[c_timezone_origem] [nvarchar](80) NULL,
	[c_destino] [nvarchar](60) NULL,
	[c_destino_eta] [nvarchar](30) NULL,
	[c_destino_ata] [nvarchar](30) NULL,
	[c_destino_atd] [nvarchar](30) NULL,
	[c_destino_etd] [nvarchar](30) NULL,
	[c_fonte_ata_destino] [nvarchar](60) NULL,
	[c_previsao_chegada] [nvarchar](30) NULL,
	[c_ultima_atualizacion] [nvarchar](30) NULL,
	[c_pre_checkin_destino] [nvarchar](30) NULL,
	[c_timezone_destino] [nvarchar](80) NULL,
	[c_tempo_trans_estimado] [nvarchar](20) NULL,
	[c_tempo_trans_real] [nvarchar](20) NULL,
	[c_hus] [nvarchar](20) NULL,
	[c_pacotes] [nvarchar](20) NULL,
	[c_occupation] [nvarchar](20) NULL,
	[c_estado] [nvarchar](30) NULL,
	[c_substatus] [nvarchar](30) NULL,
	[c_nota] [nvarchar](500) NULL,
	[c_motivo_cancelamento] [nvarchar](200) NULL,
	[c_causa_raiz_incidente] [nvarchar](200) NULL,
	[c_ots] [nvarchar](60) NULL,
	[c_otd] [nvarchar](60) NULL,
	[c_ota] [nvarchar](60) NULL,
	[c_otr] [nvarchar](60) NULL,
	[c_destino_fonte_atd] [nvarchar](60) NULL,
 CONSTRAINT [PK_stg_rotas_lh_csv_raw] PRIMARY KEY CLUSTERED 
(
	[raw_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
