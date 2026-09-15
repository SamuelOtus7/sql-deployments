-- ============================================================
-- BASELINE: dbo.tb_validacao_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacao_rotas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacao_rotas](
	[vrt_cd_validacao] [int] IDENTITY(1,1) NOT NULL,
	[vrt_cd_rota] [varchar](30) NULL,
	[vrt_cd_status_validacao] [int] NOT NULL,
	[vrt_cd_usuario_validacao] [int] NOT NULL,
	[vrt_dt_data_hora_validacao] [datetime] NOT NULL,
	[vrt_ds_observacao_validacao] [varchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[vrt_cd_validacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [Uk_validacao_rotas] UNIQUE NONCLUSTERED 
(
	[vrt_cd_rota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
