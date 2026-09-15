-- ============================================================
-- BASELINE: dbo.tb_rotina_tipo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rotina_tipo]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rotina_tipo](
	[rtt_cd_rotina_tipo] [int] IDENTITY(1,1) NOT NULL,
	[rtt_nm_rotina_tipo] [varchar](max) NOT NULL,
 CONSTRAINT [PK_tb_rotina_tipo] PRIMARY KEY CLUSTERED 
(
	[rtt_cd_rotina_tipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
