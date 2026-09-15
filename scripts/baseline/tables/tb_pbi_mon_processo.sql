-- ============================================================
-- BASELINE: dbo.tb_pbi_mon_processo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pbi_mon_processo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pbi_mon_processo](
	[processo_id] [int] IDENTITY(1,1) NOT NULL,
	[processo_codigo] [varchar](50) NOT NULL,
	[processo_nome] [nvarchar](200) NOT NULL,
	[tabela_destino] [varchar](128) NOT NULL,
	[plataforma] [varchar](20) NOT NULL,
	[job_nome] [nvarchar](200) NULL,
	[proc_orquestrador] [varchar](128) NULL,
	[proc_carga] [varchar](128) NULL,
	[origem_banco] [varchar](128) NULL,
	[origem_tabela] [varchar](128) NULL,
	[origem_filtro] [nvarchar](500) NULL,
	[origem_col_data] [varchar](128) NULL,
	[origem_col_transportadora] [varchar](128) NULL,
	[origem_col_freshness] [varchar](128) NULL,
	[origem_col_processado] [varchar](128) NULL,
	[tipo_regra] [varchar](20) NOT NULL,
	[in_origem_irisys_json] [bit] NOT NULL,
	[destino_col_data] [varchar](128) NULL,
	[destino_col_transportadora] [varchar](128) NULL,
	[destino_col_freshness] [varchar](128) NULL,
	[destino_col_etl] [varchar](128) NULL,
	[nr_lag_dias_negocio] [tinyint] NOT NULL,
	[hr_validacao] [time](0) NULL,
	[id_cliente_campo] [varchar](30) NOT NULL,
	[sla_minutos] [smallint] NOT NULL,
	[parametro_habilita] [nvarchar](100) NOT NULL,
	[in_ativo] [bit] NOT NULL,
	[dh_inclusao] [datetime2](3) NOT NULL,
	[ds_acao_origem] [nvarchar](500) NULL,
	[ds_acao_fila] [nvarchar](500) NULL,
	[ds_acao_destino] [nvarchar](500) NULL,
	[ds_acao_job] [nvarchar](500) NULL,
	[sla_label] [nvarchar](30) NOT NULL,
	[destino_regra] [varchar](20) NOT NULL,
	[nr_tolerancia_fila] [int] NOT NULL,
	[ds_acao_origem_sem_dados] [nvarchar](500) NULL,
	[ds_acao_origem_parada] [nvarchar](500) NULL,
	[ds_acao_destino_sem_carga] [nvarchar](500) NULL,
	[ds_acao_destino_desatualizado] [nvarchar](500) NULL,
	[ds_acao_destino_data_antiga] [nvarchar](500) NULL,
	[ds_acao_destino_nulos] [nvarchar](500) NULL,
	[ds_acao_job_erro] [nvarchar](500) NULL,
	[ds_acao_job_travado] [nvarchar](500) NULL,
	[in_origem_obrigatoria] [bit] NOT NULL,
	[proc_acao] [varchar](128) NULL,
	[proc_acao_params] [nvarchar](max) NULL,
	[in_acao_habilitada] [bit] NOT NULL,
	[ds_acao_botao] [nvarchar](100) NULL,
 CONSTRAINT [PK_tb_pbi_mon_processo] PRIMARY KEY CLUSTERED 
(
	[processo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_pbi_mon_processo_codigo] UNIQUE NONCLUSTERED 
(
	[processo_codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
