-- ============================================================
-- BASELINE: dbo.stg_report_carrier_1950609251_raw
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_report_carrier_1950609251_raw]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_report_carrier_1950609251_raw](
	[data_txt] [nvarchar](50) NULL,
	[id_rota_txt] [nvarchar](50) NULL,
	[id_motorista_txt] [nvarchar](50) NULL,
	[nome_motorista] [nvarchar](200) NULL,
	[veiculo] [nvarchar](100) NULL,
	[placa] [nvarchar](30) NULL,
	[km_coletado_txt] [nvarchar](50) NULL,
	[service_center] [nvarchar](150) NULL,
	[envios_despachados_txt] [nvarchar](50) NULL,
	[envios_entregues_txt] [nvarchar](50) NULL,
	[nao_visitado_txt] [nvarchar](50) NULL
) ON [PRIMARY]
GO
