-- ============================================================
-- BASELINE: dbo.tb_gr_fichas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_gr_fichas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_gr_fichas](
	[grv_id] [int] IDENTITY(1,1) NOT NULL,
	[grv_cd_cliente] [int] NOT NULL,
	[grv_cd_motorista] [int] NOT NULL,
	[grv_cd_transportadora_tecnorisk] [int] NOT NULL,
	[grv_dt_integracao] [datetime] NOT NULL,
	[grv_integracao_realizada] [bit] NOT NULL,
	[grv_json_request] [varchar](max) NOT NULL,
	[grv_json_response] [varchar](max) NOT NULL,
	[grv_cd_ficha_tecnorisk] [varchar](10) NULL,
	[grv_dt_vencimento] [datetime] NULL,
	[grv_status_sigla] [char](1) NULL,
	[grv_status_descricao] [varchar](100) NULL,
 CONSTRAINT [pk_gr_validacao_fichas] PRIMARY KEY CLUSTERED 
(
	[grv_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
