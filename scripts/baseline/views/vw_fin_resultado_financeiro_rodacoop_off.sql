-- ============================================================
-- BASELINE: dbo.vw_fin_resultado_financeiro_rodacoop_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_resultado_financeiro_rodacoop_off]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vw_fin_resultado_financeiro_rodacoop_off]
as
select 
	IdTransportadora
	,Ano
	,Mes
	,Quinzena
	,IdRota
	,DataReferencia
	,ServiceCenter
	,XPT
	,Base
	,Placa
	,Motorista
	,Destino
	,Cluster
	,TipoVeiculo
	,CicloPM
	,DomingoOuFeriado
	,TipoPagamentoFrete
	,TipoPagamentoAdicional
	,QuantidadePacotes
	,PacotesEntregues
	,Insucessos
	,Pendentes
	,QuantidadeParadas
	,QuantidadePontos
	,PgtoSaida
	,PgtoParadas
	,Adicional
	,KmColetado
	,LinkMapa
	,FaixaKm
	,isnull(RecebMeli,0) - isnull(DescontoCicloPM,0) RecebMeli
	,RecebimentoParadas
	,RecebimentoDomingo
	,RecebimentoRisco
	,RecebimentoAjudante
	,Pedagio
	,ReceitaTotal
from 
	tb_fin_resultado_financeiro
where
	IdTransportadora=59903397
	and 1=0
	
GO
