-- ============================================================
-- BASELINE: dbo.tb_pgto_espelho_importacoes_detalhes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_espelho_importacoes_detalhes]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_espelho_importacoes_detalhes](
	[peid_cd_detalhe] [bigint] IDENTITY(1,1) NOT NULL,
	[peid_cd_importacao] [bigint] NOT NULL,
	[peid_nu_linha] [int] NOT NULL,
	[peid_ds_periodo] [nvarchar](100) NULL,
	[peid_ds_rota] [nvarchar](100) NULL,
	[peid_ds_placa] [nvarchar](50) NULL,
	[peid_ds_veiculo] [nvarchar](100) NULL,
	[peid_ds_hub_svc] [nvarchar](100) NULL,
	[peid_qt_pacotes] [int] NULL,
	[peid_qt_insucessos] [int] NULL,
	[peid_qt_paradas] [int] NULL,
	[peid_nm_motorista] [nvarchar](200) NULL,
	[peid_ds_matricula] [nvarchar](50) NULL,
	[peid_ds_observacao] [nvarchar](500) NULL,
	[peid_vl_total] [nvarchar](50) NULL,
	[peid_ds_cpf] [nvarchar](20) NULL,
	[peid_ds_status] [nvarchar](20) NOT NULL,
	[peid_ds_motivo_erro] [nvarchar](max) NULL,
	[peid_qt_tentativas_insercao] [int] NOT NULL,
	[peid_ds_log_erro_insercao] [nvarchar](max) NULL,
 CONSTRAINT [PK__tb_pgto___D942C580E4C04CEB] PRIMARY KEY CLUSTERED 
(
	[peid_cd_detalhe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
