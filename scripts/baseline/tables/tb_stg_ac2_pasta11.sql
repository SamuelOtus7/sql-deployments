-- ============================================================
-- BASELINE: dbo.tb_stg_ac2_pasta11
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_ac2_pasta11]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_ac2_pasta11](
	[ID_Driver_correto] [nvarchar](255) NULL,
	[Motorista_do_espelho] [nvarchar](255) NULL,
	[Nome_na_fonte] [nvarchar](255) NULL,
	[Categoria] [nvarchar](255) NULL,
	[Valor] [nvarchar](255) NULL,
	[Ação] [nvarchar](255) NULL,
	[Data_da_ocorrência] [nvarchar](255) NULL,
	[ID_Rota] [nvarchar](255) NULL,
	[Pacote_Código] [nvarchar](255) NULL,
	[Placa] [nvarchar](255) NULL,
	[Descrição_para_o_motorista] [nvarchar](max) NULL,
	[Status_técnico] [nvarchar](max) NULL,
	[Motivo_técnico] [nvarchar](max) NULL,
	[Arquivo_fonte] [nvarchar](255) NULL,
	[Alerta_de_identificação] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
