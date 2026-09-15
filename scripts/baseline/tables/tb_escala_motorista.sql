-- ============================================================
-- BASELINE: dbo.tb_escala_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_escala_motorista]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_escala_motorista](
	[em_cd_escala_motorista] [int] IDENTITY(1,1) NOT NULL,
	[em_data_referencia] [date] NULL,
	[em_cd_motorista] [int] NOT NULL,
	[em_ds_placa] [varchar](15) NOT NULL,
	[em_ds_tipo] [varchar](50) NOT NULL,
	[em_ds_frota] [varchar](2) NOT NULL,
	[em_cd_base] [int] NOT NULL,
	[em_ds_ciclo] [varchar](50) NOT NULL,
	[em_ds_escala] [varchar](30) NOT NULL,
	[em_cd_usuario_escala] [int] NOT NULL,
	[em_dh_escala] [datetime] NOT NULL,
	[em_cd_cliente] [int] NULL,
	[em_ultimo_valor_procedure] [varchar](50) NULL,
	[em_origem_alteracao] [varchar](20) NULL,
 CONSTRAINT [PK_tb_escala_motorista] PRIMARY KEY CLUSTERED 
(
	[em_cd_escala_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
