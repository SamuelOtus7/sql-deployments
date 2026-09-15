-- ============================================================
-- BASELINE: dbo.tb_pgto_espelh_temp_raw
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_espelh_temp_raw]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_espelh_temp_raw](
	[lote_id] [uniqueidentifier] NOT NULL,
	[nr_linha_arquivo] [int] NOT NULL,
	[id_arquivo] [nvarchar](100) NULL,
	[pedido] [nvarchar](100) NULL,
	[data_carregamento_lista] [nvarchar](100) NULL,
	[lista_entrega] [nvarchar](100) NULL,
	[motorista_lista] [nvarchar](200) NULL,
	[tipo_do_veiculo] [nvarchar](100) NULL,
	[ultima_ocorrencia] [nvarchar](150) NULL,
	[data_ultima_ocorrencia] [nvarchar](100) NULL,
	[tipo_da_ocorrencia] [nvarchar](150) NULL,
	[possui_comprovante] [nvarchar](20) NULL,
	[filial_entrega] [nvarchar](150) NULL,
	[rota_entrega] [nvarchar](200) NULL,
	[usuario_da_ocorrencia] [nvarchar](200) NULL,
	[dh_importacao] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_tb_pgto_espelh_temp_raw] PRIMARY KEY CLUSTERED 
(
	[lote_id] ASC,
	[nr_linha_arquivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
