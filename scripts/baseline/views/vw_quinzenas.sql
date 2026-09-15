-- ============================================================
-- BASELINE: dbo.vw_quinzenas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_quinzenas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_quinzenas]
as
select
	distinct
	cast(cast(fin.Ano as varchar(4)) + case when fin.Mes < 10 then '0' else '' end + cast(fin.Mes as varchar(2)) + case when fin.Quinzena = 1 then '01' else '16' end as int) IdQuinzena
	,'Q' + CAST(fin.Quinzena AS VARCHAR(1)) + ' ' +
	CASE fin.Mes
		WHEN 1 THEN 'Janeiro'
		WHEN 2 THEN 'Fevereiro'
		WHEN 3 THEN 'Março'
		WHEN 4 THEN 'Abril'
		WHEN 5 THEN 'Maio'
		WHEN 6 THEN 'Junho'
		WHEN 7 THEN 'Julho'
		WHEN 8 THEN 'Agosto'
		WHEN 9 THEN 'Setembro'
		WHEN 10 THEN 'Outubro'
		WHEN 11 THEN 'Novembro'
		WHEN 12 THEN 'Dezembro'
	END + ' ' + 
	CAST(fin.Ano AS VARCHAR(4)) AS NomeQuinzena
from
	tb_fin_resultado_financeiro fin with(nolock)
GO
