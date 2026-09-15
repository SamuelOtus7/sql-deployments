-- ============================================================
-- BASELINE: dbo.vw_fin_resultado_financeiro_coopmetro_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_resultado_financeiro_coopmetro_off]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[vw_fin_resultado_financeiro_coopmetro_off]
as
select 
	 fin.IdTransportadora
	,fin.Ano
	,fin.Mes
	,fin.Quinzena
	,fin.IdRota
	,fin.DataReferencia
	,fin.ServiceCenter
	,isnull(fin.XPT,'') as XPT
	,isnull(fin.Base,'') as Base
	,isnull(fin.Placa,'') as Placa
	,isnull(fin.Motorista,'') as Motorista
	,isnull(fin.Destino,'') as Destino
	,isnull(fin.Cluster,'') as  Cluster
	,isnull(fin.TipoVeiculo,'') as TipoVeiculo
	,isnull(fin.CicloPM,'') as CicloPM
	,isnull(fin.DomingoOuFeriado,'') as DomingoOuFeriado
	,isnull(fin.TipoPagamentoFrete,'') as TipoPagamentoFrete
	,isnull(fin.TipoPagamentoAdicional,'') as TipoPagamentoAdicional
	,isnull(fin.QuantidadePacotes,0) as QuantidadePacotes
	,isnull(fin.PacotesEntregues,0) as PacotesEntregues
	,isnull(fin.Insucessos,0) as Insucessos
	,isnull(fin.Pendentes,0) as Pendentes
	,isnull(fin.QuantidadeParadas,0) as QuantidadeParadas
	,isnull(fin.QuantidadePontos,0) as QuantidadePontos
	,isnull(fin.PgtoSaida,0) as PgtoSaida
	,isnull(fin.PgtoSaidaKmMotorista,0) as PgtoSaidaKmMotorista
	,isnull(fin.PgtoSaidaKm0a100,0) as PgtoSaidaKm0a100
	,isnull(fin.PgtoSaidaKmPreFatura,0) as PgtoSaidaKmPreFatura
	,isnull(fin.PgtoParadas,0) as PgtoParadas
	,isnull(fin.PgtoRisco,0) as PgtoRisco
	,isnull(fin.PgtoAjudante,0) as PgtoAjudante
	,isnull(fin.PgtoLancamentoManual,0) as PgtoLancamentoManual
	,isnull(fin.PgtoValorManual,0) as PgtoValorManual
	,isnull(fin.PgtoTotal,0) as PgtoTotal
	,isnull(fin.Adicional,0) as Adicional
	,isnull(fin.KmColetado,0) as KmColetado
	,isnull(fin.LinkMapa,'') as LinkMapa
	,isnull(fin.FaixaKm,0) as FaixaKm
	,isnull(fin.RecebMeli,0) as RecebMeli
	,isnull(fin.RecebimentoParadas,0) as RecebimentoParadas
	,isnull(fin.RecebimentoDomingo,0) as RecebimentoDomingo
	,isnull(fin.RecebimentoRisco,0) as RecebimentoRisco
	,isnull(fin.RecebimentoAjudante,0) as RecebimentoAjudante
	,isnull(fin.Pedagio,0) as Pedagio
	,isnull(fin.RecebimentoLancamentoManual,0) as RecebimentoLancamentoManual
	,isnull(fin.RecebimentoValorManual,0) as RecebimentoValorManual
	,isnull(fin.ReceitaTotal,0) as ReceitaTotal
	,isnull(fin.TotalPrefatura,0) as TotalPrefatura
	,isnull(fin.MaiorValor,0) as MaiorValor
	,isnull(fin.ValorFinal,0) as ValorFinal
	,isnull(r.KmColetadoApp,0) as KmColetadoApp
	,isnull(r.LinkMapaApp,'') as LinkMapaApp
	,isnull(fin.RecebMeli0a100,0) RecebMeli0a100
from 
	vw_resultado_financeiro fin
	join tb_ml_rotas r on fin.IdRota = r.IdRota and fin.DataReferencia = r.DataReferencia and fin.IdTransportadora = r.IdTransportadora and r.Excluido = 0
where
	fin.IdTransportadora=1070423464

	
GO
