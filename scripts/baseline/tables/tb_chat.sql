-- ============================================================
-- BASELINE: dbo.tb_chat
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_chat]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_chat](
	[cht_cd_chat] [int] IDENTITY(1,1) NOT NULL,
	[cht_ds_chat_id] [varchar](150) NOT NULL,
	[cht_cd_usuario] [int] NOT NULL,
	[cht_ds_status] [varchar](20) NOT NULL,
	[cht_dh_cricao] [datetime] NOT NULL,
	[cht_cd_usuario_cricao] [int] NOT NULL,
	[cht_cd_cliente] [int] NOT NULL,
	[cht_dh_atualizacao] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_chat] PRIMARY KEY CLUSTERED 
(
	[cht_cd_chat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
