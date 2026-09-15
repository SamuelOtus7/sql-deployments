-- ============================================================
-- BASELINE: dbo.tb_sin_sinistro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_sin_sinistro]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_sin_sinistro](
	[sin_cd_sinistro] [int] IDENTITY(1,1) NOT NULL,
	[sin_ds_matricula] [varchar](50) NOT NULL,
	[sin_cd_transportadora] [int] NULL,
	[sin_in_possui_ajudante] [bit] NOT NULL,
	[sin_ds_cpf_ajudante] [varchar](11) NULL,
	[sin_ds_nome_ajudante] [varchar](200) NULL,
	[sin_ds_telefone_ajudante] [varchar](20) NULL,
	[sin_cd_cliente_transportadora] [int] NOT NULL,
	[sin_dt_data] [date] NOT NULL,
	[sin_cd_base] [int] NOT NULL,
	[sin_qt_pacotes] [int] NULL,
	[sin_qt_pacotes_entregues] [int] NULL,
	[sin_qt_pacotes_insucesso] [int] NULL,
	[sin_qt_sinistrado] [int] NULL,
	[sin_qt_recuperada] [int] NULL,
	[sin_ds_placa] [varchar](20) NULL,
	[sin_cd_tipo_veiculo] [int] NULL,
	[sin_in_elemento_assumiu_direcao_veiculo] [bit] NOT NULL,
	[sin_ds_numero_solicitacao_monitoramento_veiculo] [varchar](50) NULL,
	[sin_cd_fase_transporte] [int] NULL,
	[sin_ds_cep] [varchar](8) NULL,
	[sin_ds_bairro] [varchar](100) NULL,
	[sin_ds_cidade] [varchar](100) NULL,
	[sin_ds_estado] [char](2) NULL,
	[sin_ds_rua] [varchar](100) NULL,
	[sin_ds_numero] [varchar](20) NULL,
	[sin_ds_complemento] [varchar](100) NULL,
	[sin_vl_prejuizo] [decimal](10, 2) NULL,
	[sin_cd_natureza_sinistro] [int] NULL,
	[sin_vl_valor_total_embarcado] [decimal](10, 2) NULL,
	[sin_vl_valor_total_prejuizo] [decimal](10, 2) NULL,
	[sin_vl_valor_total_recuperado] [decimal](10, 2) NULL,
	[sin_in_descontar_motorista] [bit] NULL,
	[sin_in_descontar_success_delivery] [bit] NULL,
	[sin_ds_numero_processo_seguradora] [varchar](100) NULL,
	[sin_ds_seguradora] [int] NULL,
	[sin_ds_bo_preliminar] [varchar](200) NULL,
	[sin_ds_link_bo_preliminar] [varchar](2000) NULL,
	[sin_ds_observacao_preliminar] [varchar](4000) NULL,
	[sin_ds_bo] [varchar](200) NULL,
	[sin_ds_link_bo] [varchar](2000) NULL,
	[sin_ds_observacao] [varchar](4000) NULL,
	[sin_cd_usr_criacao] [int] NOT NULL,
	[sin_dh_modificacao] [datetime] NOT NULL,
	[sin_cd_usr_modificacao] [int] NOT NULL,
	[sin_in_ativo] [bit] NOT NULL,
	[sin_in_excluido] [bit] NOT NULL,
	[sin_dh_criacao] [datetime] NOT NULL,
	[sin_perimeter] [int] NOT NULL,
	[sin_status] [int] NULL,
	[sin_route] [varchar](200) NULL,
	[sin_cd_cod_driver] [int] NULL,
	[sin_ds_package] [varchar](4000) NULL,
	[sin_dt_hora_sinistro] [varchar](8) NULL,
	[sin_cd_mktplace] [int] NULL,
	[sin_ds_status_seguro] [varchar](50) NULL,
	[sin_ds_status_motorista] [varchar](50) NULL,
	[sin_ds_status_motorista_justificativa] [varchar](200) NULL,
	[sin_in_monitoramento_ativo] [bit] NOT NULL,
	[sin_in_rota_risco] [bit] NOT NULL,
	[sin_in_prioridade_aplicada] [bit] NOT NULL,
	[sin_in_veiculo_inativo] [bit] NOT NULL,
	[sin_in_veiculo_sem_atividade] [bit] NOT NULL,
	[sin_ds_tempo_inatividade] [varchar](30) NULL,
	[sin_ds_ultima_posicao_registrada] [nvarchar](500) NULL,
	[sin_dh_ultimo_horario_registrado] [datetime2](0) NULL,
	[sin_qt_tentativas_contato] [int] NULL,
	[sin_ds_pontos_alerta] [nvarchar](max) NULL,
	[sin_ds_oitiva_relato] [nvarchar](max) NULL,
	[sin_ds_responsavel_investigacao] [nvarchar](200) NULL,
	[sin_dt_encerramento_investigacao] [date] NULL,
 CONSTRAINT [PK__tb_sin_s__DC67461318CDA046] PRIMARY KEY CLUSTERED 
(
	[sin_cd_sinistro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
