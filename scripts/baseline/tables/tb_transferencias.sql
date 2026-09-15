-- ============================================================
-- BASELINE: dbo.tb_transferencias
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_transferencias]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_transferencias](
	[tra_cd_transferencia] [int] IDENTITY(1,1) NOT NULL,
	[tra_cd_cliente] [int] NOT NULL,
	[tra_cd_usuario_gestor] [int] NOT NULL,
	[tra_cd_veiculo] [int] NOT NULL,
	[tra_cd_motorista] [int] NOT NULL,
	[tra_dt_retirada] [date] NOT NULL,
	[tra_dt_devolucao] [date] NULL,
	[tra_cd_status_gestor] [int] NOT NULL,
	[tra_cd_usuario_criacao] [int] NOT NULL,
	[tra_dh_criacao] [datetime] NOT NULL,
	[tra_cd_usuario_modificacao] [int] NOT NULL,
	[tra_dh_modificacao] [datetime] NOT NULL,
	[tra_cd_status_motorista] [int] NULL,
 CONSTRAINT [pk_tb_transferencias] PRIMARY KEY CLUSTERED 
(
	[tra_cd_transferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
