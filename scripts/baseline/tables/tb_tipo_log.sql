-- ============================================================
-- BASELINE: dbo.tb_tipo_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tipo_log]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tipo_log](
	[lgt_cd_tipo] [int] IDENTITY(1,1) NOT NULL,
	[lgt_ds_nome] [varchar](50) NOT NULL,
	[lgt_ds_descricao] [varchar](150) NOT NULL,
 CONSTRAINT [PK_tb_tipo_log] PRIMARY KEY CLUSTERED 
(
	[lgt_cd_tipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
