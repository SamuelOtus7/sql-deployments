-- ============================================================
-- BASELINE: dbo.vw_fin_nivel_faixakm
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_nivel_faixakm]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_fin_nivel_faixakm] as 

select  
	a.datareferencia
	,a.idtransportadora
	,a.idrota
	,a.servicecenter
	,a.FaixaKm 
	,b.IntervaloFaixa

    ,a.TipoVeiculo  as VeiculoDA
    ,b.Veiculo      as VeiculoPF

	,KMDA.Ordem as idkmDA
	,kmprefatura.Ordem as idkmprefatura

	,KMDA.Ordem - kmprefatura.Ordem as NivelDiferenca
    ,case 
        when KMDA.Ordem is null and kmprefatura.Ordem is null then 'Sem base frete' 
        when KMDA.Ordem is null then 'Sem base frete' 
        when KMDA.Ordem is null then 'Sem Prefatura' else 'Base cadastrada' end BaseFrete

from [vw_resultado_financeiro] as a
left join tb_fin_prefatura as b
on a.idrota = b.idrota

left join vw_nivel_faixa_km as KMDA
on  1=1
and a.idtransportadora = KMDA.bft_cd_transportadora
and a.servicecenter = KMDA.servicecenter
and a.FaixaKm = KMDA.FaixaKm
and a.TipoVeiculo = KMDA.TipoVeiculo

left join vw_nivel_faixa_km as kmprefatura
on a.idtransportadora = kmprefatura.bft_cd_transportadora
AND a.servicecenter = kmprefatura.servicecenter
AND a.FaixaPreFatura = kmprefatura.FaixaKm
AND a.TipoVeiculo = kmprefatura.TipoVeiculo

where 1=1

--and a.usouapp = 'Sim'
 --and a.IdRota  in ('148918946')


--order by 1,2


--126444501
GO
