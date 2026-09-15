-- ============================================================
-- BASELINE: dbo.tb_apontamento_geo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_apontamento_geo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_apontamento_geo](
	[apg_cd_apontamento] [bigint] IDENTITY(1,1) NOT NULL,
	[apg_dh_apontamento] [datetime] NOT NULL,
	[apg_cd_transportadora] [varchar](20) NOT NULL,
	[apg_cd_motorista] [varchar](150) NOT NULL,
	[apg_latitude] [decimal](18, 9) NOT NULL,
	[apg_longitude] [decimal](18, 9) NOT NULL,
	[apg_dh_escrita] [datetime] NOT NULL,
	[DataReferencia]  AS (CONVERT([date],[apg_dh_apontamento])) PERSISTED,
 CONSTRAINT [pk_apontamento_geo] PRIMARY KEY CLUSTERED 
(
	[apg_cd_apontamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
