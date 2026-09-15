-- ============================================================
-- BASELINE: dbo.vw_fin_resultado_financeiro_vetor_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_resultado_financeiro_vetor_off]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vw_fin_resultado_financeiro_vetor_off]
as
select 
	* 
from 
	tb_fin_resultado_financeiro
where
	IdTransportadora=1359951875
	and 1 = 0

	
GO
