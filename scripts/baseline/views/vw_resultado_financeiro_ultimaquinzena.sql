-- ============================================================
-- BASELINE: dbo.vw_resultado_financeiro_ultimaquinzena
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_resultado_financeiro_ultimaquinzena]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_resultado_financeiro_ultimaquinzena]
as
select  
	a.IdQuinzena
	,a.NomeQuinzena
	,a.IdTransportadora
	,a.Ano
	,a.Mes
	,a.Quinzena
	,a.IdRota
	,a.DataReferencia
	,a.HoraInicio
	,a.ServiceCenter
	,a.serviceCenterPrefatura
	,a.XPT
	,a.Base
	,a.Placa
	,a.Motorista
	,a.Destino
	,a.Cluster
	,a.TipoVeiculo
	,a.TipoVeiculoPreFatura
	,a.CicloPM
	,a.CicloPMFatura
	,a.DomingoOuFeriado
	,a.QuantidadePacotes
	,a.PacotesEntregues
	,a.Insucessos
	,a.Pendentes
	,a.QuantidadeParadas
	,a.QuantidadePontos
	,a.Adicional
	,a.KmColetado
	,a.LinkMapa
	,a.FaixaKm
	,a.RecebMeli
	,a.RecebTotal
	,a.RecebimentoParadas
	,a.RecebimentoDomingo
	,a.RecebimentoRisco
	,a.RecebimentoAjudante
	,a.Pedagio
	,a.RecebimentoLancamentoManual
	,a.RecebimentoValorManual
	,a.ReceitaTotal
	,a.TotalPrefatura
	,a.MaiorValor
	,a.ValorFinal
	,a.RecebMeli0a100
	,a.FretePreFatura
	,a.RecebimentoDomingoPrefatura
	,a.FaixaPreFatura
	,a.DescontoCicloPM
	,a.ValorAdicional0_60
	,a.ValorAdicional61_90
	,a.ValorAdicionalAcima_90
	,a.TxAdicionalDomingo
	,a.TxAdicionalCiclo_pm
	,a.TxAdicionalAjudante
	,a.TxAdicionalRisco
	,a.RecebimentoBase
	,a.UsouAPP
	,a.Apuracao
	,a.CadPreFatura
	,a.MaiorValorKM
	,a.RecebMeliZerado
	,a.PrefaturaZerado
	,a.UsoDevido
	,a.AdicionalInsucessos
	,a.NumeroRota
	,a.TipoVeiculoCad
	,a.QuantidadeAmbulancia
	,a.IDFINANCEIRO
	,a.DataAtualizacao
	,a.ServiceCenterIgual
	,a.ServiceCenterIgualtx
	,a.TipoVeiculoIgual
	,a.TipoVeiculoIgualyx
	,a.CicloPMIgual
	,a.CicloPMIgualtx
	,a.RecebimentoIgual
	,a.RecebimentoIgualtx
	,a.PlacaIgual
	,a.PlacaIgualtx
	,a.ParadasIgual
	,a.ParadasIgualtx
	,a.ValorParadasIgual
	,a.ValorParadasIgualtx
	,a.PlacaFatura
	,a.ParadasPreFatura
	,a.ValorParadaPreFatura


    ,a.TipoVeiculo  as VeiculoDA
    ,b.Veiculo      as VeiculoPF
	,KMDA.Ordem as idkmDA
	,kmprefatura.Ordem as idkmprefatura
	,KMDA.Ordem - kmprefatura.Ordem as NivelDiferenca
    ,case 
        when KMDA.Ordem is null and kmprefatura.Ordem is null then 'Sem base frete' 
        when KMDA.Ordem is null then 'Sem base frete' 
        when KMDA.Ordem is null then 'Sem Prefatura' else 'Base cadastrada' end BaseFrete
	,b.ServiceCenter as SVCPrefatura
	,b.IntervaloFaixa
	,case 
        when   KmCiclo = 'AMBULANCE' then 'Ambulancia' 
        when (RecebMeli) > 0 then 'Sim' 
        else 'Não' end as DimRecebeuProcessamento

	,    case 
		when KMDA.Ordem = kmprefatura.Ordem 
		then 1
		when /*a.UsouAPP  = 'Sim'  and */  kmprefatura.Ordem > KMDA.Ordem
		then 2		
		when /*a.UsouAPP  = 'Sim'  and */  KMDA.Ordem > kmprefatura.Ordem 
		then 3			
		when /*a.UsouAPP  = 'Sim'  and */   a.TipoVeiculo <> b.Veiculo
		then 4	
    	else 0 end 
        ComparaFaixaKMId

	,case when a.UsouAPP  = 'Sim' then 1 else 0 end as UsouAppId
	,ValorFinal 	as Recebimento
from 
	[vw_resultado_financeiro] as a
	left join tb_fin_prefatura as b on a.idrota = b.idrota
	left join vw_nivel_faixa_km as KMDA on a.idtransportadora = KMDA.bft_cd_transportadora
									and a.servicecenter = KMDA.servicecenter
									and a.FaixaKm = KMDA.FaixaKm
									and a.TipoVeiculo = KMDA.TipoVeiculo
	left join vw_nivel_faixa_km as kmprefatura on a.idtransportadora = kmprefatura.bft_cd_transportadora
									AND a.servicecenter = kmprefatura.servicecenter
									AND case when a.FaixaPreFatura = '301/99999' then '301/999999' else a.FaixaPreFatura end = kmprefatura.FaixaKm
									AND a.TipoVeiculo = kmprefatura.TipoVeiculo

where
	a.DataInicioQuinzena >= case when DAY(getdate()) <= 15 then dateadd(day,15,DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()) - 1, 0)) else DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()), 0) end
GO
