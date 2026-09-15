-- ============================================================
-- BASELINE: dbo.tb_integracao_flex_logs
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_integracao_flex_logs]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_integracao_flex_logs](
	[inf_cd_requisicao] [int] IDENTITY(1,1) NOT NULL,
	[inf_cd_codigo_cliente] [int] NOT NULL,
	[inf_cd_id_rota] [int] NOT NULL,
	[inf_ds_placa] [nvarchar](255) NOT NULL,
	[inf_nm_status] [int] NOT NULL,
	[inf_ds_mensagem_api] [nvarchar](max) NOT NULL,
	[inf_dh_data_hora] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[inf_cd_requisicao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
