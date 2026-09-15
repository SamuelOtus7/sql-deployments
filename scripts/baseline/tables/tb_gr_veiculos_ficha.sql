-- ============================================================
-- BASELINE: dbo.tb_gr_veiculos_ficha
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_gr_veiculos_ficha]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_gr_veiculos_ficha](
	[grv_cd_veiculo_ficha] [int] IDENTITY(1,1) NOT NULL,
	[grv_cd_ficha] [int] NOT NULL,
	[grv_cd_veiculo] [int] NOT NULL,
 CONSTRAINT [pk_gr_veiculos_ficha] PRIMARY KEY CLUSTERED 
(
	[grv_cd_veiculo_ficha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
