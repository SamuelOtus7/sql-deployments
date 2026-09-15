-- ============================================================
-- BASELINE: dbo.tb_pbi_mon_alertas_fato
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pbi_mon_alertas_fato]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pbi_mon_alertas_fato](
	[alerta_fato_id] [bigint] IDENTITY(1,1) NOT NULL,
	[dt_referencia] [date] NOT NULL,
	[dh_atualizacao] [datetime2](3) NOT NULL,
	[cli_cd_codigo_cliente] [int] NOT NULL,
	[id_transportadora] [int] NOT NULL,
	[processo_id] [int] NOT NULL,
	[in_cliente_ativo] [bit] NOT NULL,
	[in_cliente_excluido] [bit] NOT NULL,
	[in_dashboard_alarmes_habilitado] [bit] NOT NULL,
	[in_processo_habilitado] [bit] NOT NULL,
	[in_elegivel_monitoramento] [bit] NOT NULL,
	[nm_transportadora] [varchar](50) NOT NULL,
	[plataforma] [varchar](20) NOT NULL,
	[processo_codigo] [varchar](50) NOT NULL,
	[processo_nome] [nvarchar](200) NOT NULL,
	[tabela_destino] [varchar](128) NOT NULL,
	[tipo_regra] [varchar](20) NOT NULL,
	[sla_minutos] [smallint] NOT NULL,
	[sla_label] [nvarchar](30) NOT NULL,
	[nr_tolerancia_fila] [int] NOT NULL,
	[destino_regra] [varchar](20) NOT NULL,
	[grupo_responsavel] [nvarchar](30) NULL,
	[etapa_falha] [nvarchar](20) NULL,
	[motivo_falha] [nvarchar](50) NULL,
	[cd_status] [tinyint] NOT NULL,
	[ds_status] [nvarchar](50) NOT NULL,
	[in_fora_janela_origem] [bit] NOT NULL,
	[dh_ultimo_evento_origem] [datetime] NULL,
	[dh_ultimo_evento_destino] [datetime2](3) NULL,
	[qt_registros_origem] [int] NOT NULL,
	[qt_registros_destino] [int] NOT NULL,
	[qt_fila_pendente] [bigint] NOT NULL,
	[qt_destino_nulos] [bigint] NOT NULL,
	[nm_job] [nvarchar](200) NULL,
	[job_ultima_execucao] [datetime] NULL,
	[job_status] [nvarchar](20) NULL,
	[proc_orquestrador] [varchar](128) NULL,
	[proc_carga] [varchar](128) NULL,
	[ds_acao_recomendada] [nvarchar](4000) NULL,
	[ds_evidencia] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_tb_pbi_mon_alertas_fato] PRIMARY KEY CLUSTERED 
(
	[alerta_fato_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_pbi_mon_alertas_fato_chave] UNIQUE NONCLUSTERED 
(
	[cli_cd_codigo_cliente] ASC,
	[processo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
