-- ============================================================
-- BASELINE: dbo.tb_vl_veiculo_aluguel
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_vl_veiculo_aluguel]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_vl_veiculo_aluguel](
	[vva_cd_alguel] [int] IDENTITY(1,1) NOT NULL,
	[vva_cd_tipo_veiculo] [int] NOT NULL,
	[vva_ds_descricao] [nvarchar](100) NOT NULL,
	[vva_ds_label]  AS (case when [vva_Localidade] IS NOT NULL AND [vva_modelo] IS NULL then ([vva_ds_descricao]+' - ')+[vva_Localidade] when [vva_Localidade] IS NULL AND [vva_modelo] IS NOT NULL then ([vva_ds_descricao]+' - ')+[vva_modelo] when [vva_Localidade] IS NULL AND [vva_modelo] IS NOT NULL then (([vva_ds_descricao]+' - ')+([vva_Localidade]+' - '))+[vva_modelo] else [vva_ds_descricao] end) PERSISTED NOT NULL,
	[vva_Localidade] [nvarchar](100) NULL,
	[vva_modelo] [nvarchar](255) NULL,
	[vva_vl_aluguel] [varchar](9) NULL,
	[vva_cd_cliente] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[vva_cd_alguel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
