-- ============================================================
-- BASELINE: dbo.tb_push_notification_fila
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_push_notification_fila]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_push_notification_fila](
	[pnf_cd_push_notification] [int] IDENTITY(1,1) NOT NULL,
	[pnf_cd_usuario] [int] NOT NULL,
	[pnf_cd_cliente] [int] NOT NULL,
	[pnf_ds_status] [varchar](50) NOT NULL,
	[pnf_dh_envio] [datetime] NULL,
	[pnf_ds_titulo] [varchar](50) NOT NULL,
	[pnf_ds_mensagem] [varchar](255) NOT NULL,
	[pnf_cd_api_id] [varchar](50) NULL,
	[pnf_ds_erro] [nvarchar](255) NULL,
	[pnf_ds_dados_complementares] [nvarchar](max) NULL,
 CONSTRAINT [PK_tb_push_notification_fila] PRIMARY KEY CLUSTERED 
(
	[pnf_cd_push_notification] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
