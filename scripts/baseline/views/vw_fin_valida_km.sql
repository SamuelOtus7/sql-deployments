-- ============================================================
-- BASELINE: dbo.vw_fin_valida_km
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_valida_km]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_fin_valida_km] as 

select distinct

	a.datareferencia
	,a.mes
	,a.ano 
	,a.Quinzena
	,a.idtransportadora
	,a.idrota
	,a.servicecenter
	,b.ServiceCenter as SVCPrefatura
	,c.NivelDiferenca as NivelDiferenca
	,a.FaixaKm 
	,b.IntervaloFaixa
	,a.kmcoletado
	,a.TipoVeiculo
    ,b.Veiculo
	,case 
        when   KmCiclo = 'AMBULANCE' then 'Ambulancia' 
        when (RecebMeli) > 0 then 'Sim' 
        else 'Não' end as DimRecebeuProcessamento

	,    case 
		when /*a.UsouAPP  = 'Sim'  and */ c.idkmDA = c.idkmprefatura 
		then 1
		when /*a.UsouAPP  = 'Sim'  and */  c.idkmprefatura > c.idkmDA 
		then 2		
		when /*a.UsouAPP  = 'Sim'  and */  c.idkmDA > c.idkmprefatura 
		then 3			
		when /*a.UsouAPP  = 'Sim'  and */   a.TipoVeiculo <> b.Veiculo
		then 4	
    	else 0 end 
        ComparaFaixaKMId

	,case when a.UsouAPP  = 'Sim' then 1 else 0 end as UsouApp

	,ValorFinal 	as Recebimento
    ,TotalPrefatura
	,PgtoSaida 	as PgtoSaida
	,TipoPagamentoFrete
	,TipoPagamentoAdicional
    ,UsoDevido
    ,c.BaseFrete
	,a.DataAtualizacao

	--,case when b.idrota is not null and b.IntervaloFaixa is null then 1 else 0 end as MaiorDA

from [vw_resultado_financeiro] as a

left join tb_fin_prefatura as b WITH(nolock)
on a.idrota = b.idrota

left join vw_fin_nivel_faixakm as c
on a.idrota = c.idrota

where 1=1 
-- and a.IdTransportadora	= 2087146923
-- --and a.DataReferencia >= '2023-12-01'
-- and a.Ano	= 2024
-- and a.Mes	= 1
--and a.Quinzena = 	1
--and a.idrota = '173325930'
GO
