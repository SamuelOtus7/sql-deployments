-- ============================================================
-- BASELINE: dbo.tb_envio_boas_vindas_lote
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_envio_boas_vindas_lote]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_envio_boas_vindas_lote](
	[evl_cd_lote] [bigint] IDENTITY(1,1) NOT NULL,
	[evl_cd_cliente] [int] NOT NULL,
	[evl_cd_usr_criacao] [int] NOT NULL,
	[evl_dh_criacao] [datetime] NOT NULL,
	[evl_ds_origem] [nvarchar](20) NOT NULL,
	[evl_qt_total] [int] NOT NULL,
	[evl_qt_sucesso] [int] NOT NULL,
	[evl_qt_falha] [int] NOT NULL,
	[evl_in_excluido] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[evl_cd_lote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
