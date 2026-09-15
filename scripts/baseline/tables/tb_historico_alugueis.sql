-- ============================================================
-- BASELINE: dbo.tb_historico_alugueis
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_historico_alugueis]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_historico_alugueis](
	[his_cd_historico] [int] IDENTITY(1,1) NOT NULL,
	[his_ds_placa] [nvarchar](20) NOT NULL,
	[his_ds_valor] [varchar](9) NULL,
	[his_ds_valor_total] [varchar](9) NULL,
	[his_ds_nome_usuario] [nvarchar](255) NOT NULL,
	[his_ds_nome_motorista] [nvarchar](255) NOT NULL,
	[his_cd_usuario] [int] NOT NULL,
	[his_cd_cliente] [int] NOT NULL,
	[his_ds_data_inicio] [datetime2](7) NOT NULL,
	[his_ds_data_termino] [datetime2](7) NULL,
	[his_dh_criacao] [datetime] NOT NULL,
	[his_dh_atualizacao] [datetime] NOT NULL,
	[his_cd_ano] [varchar](20) NULL,
	[his_ds_cobranca] [nvarchar](255) NULL,
	[his_cd_motorista] [int] NOT NULL,
	[his_cd_veiculo] [int] NOT NULL,
	[his_fl_status_aluguel] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[his_cd_historico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
