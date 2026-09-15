-- ============================================================
-- BASELINE: dbo.tb_fin_tipo_calculo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_tipo_calculo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_tipo_calculo](
	[ftc_cd_tipo_calculo] [tinyint] IDENTITY(1,1) NOT NULL,
	[ftc_nm_tipo_calculo] [varchar](30) NOT NULL,
 CONSTRAINT [pk_tb_fin_tipo_calculo] PRIMARY KEY CLUSTERED 
(
	[ftc_cd_tipo_calculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_fin_tipo_calculo] UNIQUE NONCLUSTERED 
(
	[ftc_nm_tipo_calculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
