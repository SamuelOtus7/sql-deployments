-- ============================================================
-- BASELINE: dbo.vw_fin_ml_prefatura_complementar
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_ml_prefatura_complementar]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_fin_ml_prefatura_complementar] as

select 
 a.IdTransportadora	
,a.Ano	
,a.Mes	
,a.Quinzena	
,a.IdRota
,a.Veiculo	
,a.ContinuacaoVeiculo	
,a.ServiceCenter	
,a.KmCiclo	
,b.pfc_ds_conceito_billing
,b.pfc_ds_status_final as StatusComplementar
,a.CicloPM	
,a.IntervaloFaixa	
,a.InicioIntervalo	
,a.FimIntervalo
,a.Placa	
,a.Motorista
,a.Total as ValorPrefatura
,a.VLParada as ValorParada
,b.pfc_vl_servico as ValorComplementar

from tb_fin_prefatura as a
left join [dbo].[tb_fin_prefatura_complementar] as b
on a.idrota  = b.pfc_cd_rota

where IdTransportadora = 1024706007
and Ano				   = 2026
and Mes				   = 07
--and Quinzena		   = 02




GO
