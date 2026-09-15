-- ============================================================
-- BASELINE: dbo.tb_responsavel
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_responsavel]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_responsavel](
	[Código Responsável] [int] IDENTITY(1,1) NOT NULL,
	[Nome] [varchar](max) NOT NULL,
	[Status] [bit] NOT NULL,
 CONSTRAINT [PK_tb_responsavel] PRIMARY KEY CLUSTERED 
(
	[Código Responsável] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
