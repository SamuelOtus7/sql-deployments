-- ============================================================
-- BASELINE: dbo.vw_validacao_financeiro
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacao_financeiro]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_validacao_financeiro]
as
select
	isnull(prefatura.IdTransportadora,financeiro.IdTransportadora) IdTransportadora,
	cast(isnull(prefatura.Ano,financeiro.Ano) as int) Ano,
	cast(isnull(prefatura.Mes,financeiro.Mes) as int) Mes,
	dt.Mes NomeMes,
	cast(isnull(prefatura.Quinzena,financeiro.Quinzena) as int) Quinzena,
	cast(isnull(prefatura.Quinzena,financeiro.Quinzena) as varchar) + 'ª' NomeQuinzena,
	isnull(prefatura.IdRota,financeiro.IdRota) IdRota,
	isnull(prefatura.DataInicio,financeiro.DataReferencia) DataRota,
	isnull(financeiro.Base, '') Base,
	isnull(financeiro.TipoVeiculo, '') TipoVeiculo,
	isnull(financeiro.KmColetado, 0) KmColetado,
	isnull(financeiro.LinkMapa, '') LinkMapa,
	isnull(financeiro.TipoPagamentoFrete, '') TipoPagamentoFrete,
	isnull(financeiro.TipoPagamentoAdicional, '') TipoPagamentoAdicional,
	isnull(financeiro.QuantidadePacotes, 0) TotalPacotes,
	isnull(financeiro.PacotesEntregues, 0) PacotesEntregues,
	isnull(financeiro.Insucessos, 0) Insucessos,
	isnull(financeiro.Pendentes, 0) Pendentes,
	isnull(financeiro.QuantidadeParadas, 0) QuantidadeParadas,
	isnull(financeiro.QuantidadePontos, 0) QuantidadePontos,
	isnull(prefatura.Total, 0) TotalPreFatura,
	isnull(financeiro.RecebMeli, 0) RecebMeli,
	isnull(financeiro.RecebimentoParadas, 0) RecebimentoParadas,
	isnull(financeiro.RecebimentoDomingo, 0) RecebimentoDomingo,
	isnull(financeiro.RecebimentoAjudante, 0) RecebimentoAjudante,
	isnull(financeiro.RecebimentoRisco, 0) RecebimentoRisco,
	isnull(financeiro.DescontoCicloPM, 0) DescontoCicloPM,
	isnull(financeiro.ReceitaTotal, 0) ReceitaDA,
	isnull(prefatura.IntervaloFaixa, 0) FaixaPreFatura,
	isnull(financeiro.FaixaKm, 0) FaixaDA,
	isnull(prefatura.CicloPM, '') CicloPMPreFatura,
	isnull(financeiro.CicloPM, '') CicloPMDA,

	case when isnull(prefatura.Total,0) = isnull(financeiro.ReceitaTotal,0) then 'Valores Iguais' 
	else case when isnull(prefatura.Total,0) > isnull(financeiro.ReceitaTotal,0) then 'Pré Fatura'
	else 'Irisys' end end MaiorValor,
	
	case when prefatura.IdRota is null then 'Rota ausente na pré fatura' else
	case when financeiro.IdRota is null then 'Rota ausente no Irisys'
	else 'Rota encontrada nas duas bases' end end StatusRotaBatimento,
	isnull(Parada,0) Parada,
	isnull(VLParada,0) VLParada,
	'Mercado Livre' Marketplace,
	'LM' Operacao

	--prefatura.IdRota IdRotaPreFatura,
	--financeiro.IdRota IdRota,
	--prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end Veiculo,
	--financeiro.TipoVeiculo,
	--case when prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end = financeiro.TipoVeiculo then  1 else 0 end ValidaVeiculo
from
	tb_fin_prefatura prefatura

	left join tb_fin_resultado_financeiro financeiro on prefatura.Ano = financeiro.Ano
													and prefatura.Mes = financeiro.Mes
													and prefatura.Quinzena = financeiro.Quinzena
													and prefatura.IdRota = financeiro.IdRota

	left join (select distinct NumMes, Mes from DimData) dt on isnull(prefatura.Mes,financeiro.Mes) = dt.NumMes

	--inner join tb_clientes as cli
	--on prefatura.IdTransportadora = cli.cli_id_logistics 


union all

select
	prefatura.IdTransportadora IdTransportadora,
	cast(prefatura.Ano as int) Ano,
	cast(prefatura.Mes as int) Mes,
	dt.Mes NomeMes,
	cast(prefatura.Quinzena as int) Quinzena,
	cast(prefatura.Quinzena as varchar) + 'ª' NomeQuinzena,
	prefatura.IdRota IdRota,
	prefatura.DataInicio DataRota,
	'' Base,
	'' TipoVeiculo,
	0 KmColetado,
	'' LinkMapa,
	'' TipoPagamentoFrete,
	'' TipoPagamentoAdicional,
	0 TotalPacotes,
	0 PacotesEntregues,
	0 Insucessos,
	0 Pendentes,
	0 QuantidadeParadas,
	0 QuantidadePontos,
	isnull(prefatura.Total, 0) TotalPreFatura,
	0 RecebMeli,
	0 RecebimentoParadas,
	0 RecebimentoDomingo,
	0 RecebimentoAjudante,
	0 RecebimentoRisco,
	0 DescontoCicloPM,
	0 ReceitaDA,
	isnull(prefatura.IntervaloFaixa, '') FaixaPreFatura,
	'' FaixaDA,
	isnull(prefatura.CicloPM, '') CicloPMPreFatura,
	'' CicloPMDA,

	'' MaiorValor,
	
	'' StatusRotaBatimento,
	isnull(Parada,0) Parada,
	isnull(VLParada,0) VLParada,
	'Mercado Livre' Marketplace,
	'FM' Operacao

	--prefatura.IdRota IdRotaPreFatura,
	--financeiro.IdRota IdRota,
	--prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end Veiculo,
	--financeiro.TipoVeiculo,
	--case when prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end = financeiro.TipoVeiculo then  1 else 0 end ValidaVeiculo
from
	tb_fin_fm_prefatura prefatura  with(nolock)
	left join (select distinct NumMes, Mes from DimData with(nolock)) dt on prefatura.Mes = dt.NumMes

GO
