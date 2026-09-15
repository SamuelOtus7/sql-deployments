-- ============================================================
-- BASELINE: dbo.tb_looker_treinamento_realizado
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_looker_treinamento_realizado]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_looker_treinamento_realizado](
	[tnm_cd_treinamento_realizado] [int] IDENTITY(1,1) NOT NULL,
	[tnm_cd_treinamento] [int] NOT NULL,
	[tnm_tipo_treinamento] [varchar](100) NULL,
	[tnm_id_meli] [bigint] NULL,
	[tnm_id_motorista] [bigint] NULL,
	[tnm_transportadora] [varchar](100) NULL,
	[tnm_milla] [varchar](50) NULL,
	[tnm_svc] [varchar](50) NULL,
	[tnm_placa] [varchar](11) NULL,
	[tnm_antiguidade] [varchar](10) NULL,
	[tnm_status_motorista] [varchar](50) NULL,
	[tnm_nome_curso] [varchar](255) NULL,
	[tnm_descricao] [varchar](50) NULL,
	[tnm_progresso_curso] [varchar](50) NULL,
	[tnm_semana] [varchar](10) NULL,
	[tnm_data_treinamento] [date] NULL,
	[tnm_data_ultima_rota] [date] NULL,
	[tnm_aderencia] [float] NULL,
	[tnm_codigo_cliente] [int] NULL,
	[tnm_fonte_origem] [varchar](100) NULL,
	[tnm_data_etl] [datetime] NULL,
	[tnm_facility] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[tnm_cd_treinamento_realizado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
