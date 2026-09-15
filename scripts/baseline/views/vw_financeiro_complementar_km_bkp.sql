-- ============================================================
-- BASELINE: dbo.vw_financeiro_complementar_km_bkp
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_financeiro_complementar_km_bkp]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_financeiro_complementar_km_bkp]
as

select
	financeiro.IdTransportadora,
	cli_id_logistics as TransportadoraMktPlace,
	financeiro.Ano,
	financeiro.Mes,
	financeiro.Quinzena,
	cli_cd_codigo_cliente as Transportadora,
	financeiro.DataReferencia Data,
	financeiro.IdRota,
	'' IdPacote,
	
	case when (financeiro.TipoVeiculo <> prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end) then
		'Tipo rodado divergente'
	else case when prefatura.IdRota is null then 
		'Diferença de tarifa Negociado x Cadastrado' 
	else 'Faixa de KM' end end Reason,

	'Não se aplica' SubStatus,
	'' ObsSubStatus,
	financeiro.TipoVeiculo Veiculo,
	financeiro.CicloPM Ciclo,
	
	case when financeiro.TipoVeiculo not like 'Bulk%' and prefatura.IntervaloFaixa = '301/9999' then '>301'
	else case when financeiro.TipoVeiculo like 'Bulk%' then prefatura.IntervaloFaixa + ' - Bulk'
	else prefatura.IntervaloFaixa end end FaixaKmMeli,

	case when financeiro.TipoVeiculo not like 'Bulk%' and financeiro.FaixaKm = '301/9999' then '>301'
	else case when financeiro.TipoVeiculo like 'Bulk%' then financeiro.FaixaKm + ' - Bulk'
	else financeiro.FaixaKm end end FaixaKmML,

	financeiro.KmColetado KMTotalPercorrido,
	prefatura.Total PagoNaPrefatura,
	financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) ValorCorretoMLP,
	(financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0)) - prefatura.Total DiferencaPagoMelixValorMLP,
	cast(financeiro.Ano as varchar(4)) + case when financeiro.Mes < 10 then '0' else '' end + cast(financeiro.Mes as varchar(2)) + 'Q' + cast(financeiro.Quinzena as varchar(1)) NomeQuinzena,
	financeiro.ServiceCenter,
	financeiro.XPT,
	financeiro.LinkMapa LinkEvidencia

from
	tb_fin_resultado_financeiro financeiro
	left join (
	select 
	cli_cd_codigo_cliente as IdTransportadora
	,Ano
	,Mes
	,Quinzena
	,Veiculo
	,ContinuacaoVeiculo
	,ServiceCenter
	,KmCiclo
	,CicloPM
	,IntervaloFaixa
	,InicioIntervalo
	,FimIntervalo
	,Dia
	,IdRota
	,DataInicio
	,DataTermino
	,Placa
	,Motorista
	,Quantidade
	,PrecoUnitario
	,Total
	
	from tb_fin_prefatura as a
	inner join tb_clientes as b
	on a.IdTransportadora = b.cli_id_logistics
	-- and cli_cd_codigo_cliente = 1
	
	--and Ano = 2024
	--and Mes = 6
	--and Quinzena = 1



	)prefatura 
		on prefatura.IdTransportadora = financeiro.IdTransportadora
		and prefatura.Ano = financeiro.Ano
		and prefatura.Mes = financeiro.Mes
		and prefatura.Quinzena = financeiro.Quinzena
		and prefatura.IdRota = financeiro.IdRota

	join tb_clientes on financeiro.IdTransportadora = cli_cd_codigo_cliente


where 1=1
	--and financeiro.IdTransportadora = 1
	--and financeiro.Ano = 2024
	--and financeiro.Mes = 6
	--and financeiro.Quinzena = 1
	and (financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0)) > isnull(prefatura.Total,0)
	or
	(financeiro.TipoVeiculo <> prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end)


union all

--rotas que vieram da prefatura e não estão no financeiro na quinzena da rota, exemplo: uma rota do dia 31/05 que veio na pré-fatura da 1ª quinzena de junho
select
	prefatura.IdTransportadora,
	cli_id_logistics as TransportadoraMktPlace,
	prefatura.Ano,
	prefatura.Mes,
	prefatura.Quinzena,
	cli_cd_codigo_cliente Transportadora,
	financeiro.DataReferencia Data,
	financeiro.IdRota,
	'' IdPacote,
	
	case when (financeiro.TipoVeiculo <> prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end) then
		'Tipo rodado divergente'
	else case when prefatura.IdRota is null then 
		'Diferença de tarifa Negociado x Cadastrado' 
	else 'Faixa de KM' end end Reason,

	'Não se aplica' SubStatus,
	'' ObsSubStatus,
	financeiro.TipoVeiculo Veiculo,
	financeiro.CicloPM Ciclo,
	
	case when financeiro.TipoVeiculo not like 'Bulk%' and prefatura.IntervaloFaixa = '301/9999' then '>301'
	else case when financeiro.TipoVeiculo like 'Bulk%' then prefatura.IntervaloFaixa + ' - Bulk'
	else prefatura.IntervaloFaixa end end FaixaKmMeli,

	case when financeiro.TipoVeiculo not like 'Bulk%' and financeiro.FaixaKm = '301/9999' then '>301'
	else case when financeiro.TipoVeiculo like 'Bulk%' then financeiro.FaixaKm + ' - Bulk'
	else financeiro.FaixaKm end end FaixaKmML,

	financeiro.KmColetado KMTotalPercorrido,
	prefatura.Total PagoNaPrefatura,
	financeiro.RecebMeli - financeiro.DescontoCicloPM ValorCorretoMLP,
	(financeiro.RecebMeli - financeiro.DescontoCicloPM) - prefatura.Total DiferencaPagoMelixValorMLP,
	cast(financeiro.Ano as varchar(4)) + case when financeiro.Mes < 10 then '0' else '' end + cast(financeiro.Mes as varchar(2)) + 'Q' + cast(financeiro.Quinzena as varchar(1)) NomeQuinzena,
	financeiro.ServiceCenter,
	financeiro.XPT,
	financeiro.LinkMapa LinkEvidencia
from
	(
	select 
	cli_cd_codigo_cliente as IdTransportadora
	,Ano
	,Mes
	,Quinzena
	,Veiculo
	,ContinuacaoVeiculo
	,ServiceCenter
	,KmCiclo
	,CicloPM
	,IntervaloFaixa
	,InicioIntervalo
	,FimIntervalo
	,Dia
	,IdRota
	,DataInicio
	,DataTermino
	,Placa
	,Motorista
	,Quantidade
	,PrecoUnitario
	,Total
	
	from tb_fin_prefatura as a
	inner join tb_clientes as b
	on a.IdTransportadora = b.cli_id_logistics

	) as prefatura

	join tb_fin_resultado_financeiro financeiro on prefatura.IdTransportadora = financeiro.IdTransportadora
													and cast(convert(varchar,cast(cast(prefatura.Ano as varchar(4)) + '-' + cast(prefatura.Mes as varchar(2)) + '-' + cast(prefatura.Quinzena as varchar(2)) as date),112) as int) 
														> 
														cast(convert(varchar,cast(cast(financeiro.Ano as varchar(4)) + '-' + cast(financeiro.Mes as varchar(2)) + '-' + cast(financeiro.Quinzena as varchar(2)) as date),112) as int)
													and prefatura.IdRota = financeiro.IdRota

	join tb_clientes on financeiro.IdTransportadora = cli_cd_codigo_cliente
GO
