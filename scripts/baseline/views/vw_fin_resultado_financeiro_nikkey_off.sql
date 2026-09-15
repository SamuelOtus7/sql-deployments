-- ============================================================
-- BASELINE: dbo.vw_fin_resultado_financeiro_nikkey_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_resultado_financeiro_nikkey_off]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vw_fin_resultado_financeiro_nikkey_off]
as
select 
	fin.*,
	r.KmColetadoApp,
	r.LinkMapaApp
from 
	vw_resultado_financeiro fin
	join tb_ml_rotas r on fin.IdRota = r.IdRota and fin.DataReferencia = r.DataReferencia and fin.IdTransportadora = r.IdTransportadora and r.Excluido = 0
where
	fin.IdTransportadora=2144088496

	
GO
