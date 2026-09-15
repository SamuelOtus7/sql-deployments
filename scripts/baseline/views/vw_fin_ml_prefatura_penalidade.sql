-- ============================================================
-- BASELINE: dbo.vw_fin_ml_prefatura_penalidade
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_ml_prefatura_penalidade]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_fin_ml_prefatura_penalidade] AS
SELECT
	Id
	,IdTransportadora
	,Ano
	,Mes
	,Quinzena
	,DataReferencia
	,IdRota
	,IdPacote
	,IdPenalidade
	,Descricao
	,Penaliade = CASE
		WHEN Descricao LIKE 'Vehicle Daily Not Visited%' THEN 'Endereco nao visitado'
		WHEN Descricao LIKE 'Pnr Packages Penalty%' THEN 'PNR'
		WHEN Descricao LIKE 'Lost Packages Penalty%' THEN 'Pacotes Perdidos'
		ELSE NULL
	END
	,Quantidade
	,PrecoUnitario
	,Total
FROM [dbo].[tb_fin_prefatura_descontos]
GO
