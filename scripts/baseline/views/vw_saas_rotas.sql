-- ============================================================
-- BASELINE: dbo.vw_saas_rotas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_rotas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_saas_rotas]
as
select
  IdTransportadora
  ,Id 
  ,IdRota
  ,DataReferencia
  ,StatusRota
  ,SubStatusRota
  ,StatusPrazo
  ,ServiceCenter
  ,NomeServiceCenter
  ,Base
  ,CidadeBase
  ,OrigemSaida
  ,TipoRota
  ,TipoVeiculo
  ,NomeMotorista
  ,Placa
  ,KmColetado
  ,LinkMapa
  ,CidadeDistante
  ,PacotesEntregues
  ,PacotesPendentes
  ,PacotesNaoEntregue
  ,PacotesEntreguesForaAreaEntrega
  ,PacotesTransferidos
  ,EnderecosVisitados
  ,TempoEmRota
  ,TempoAreaEntrega
  ,KmTotal
  ,TempoEmRotaSec
  ,SegundosEntreEntregas
  ,RotaFinalizada
  ,QuantidadePontos
  ,QuantidadeParadas
  ,QuantidadeReclamacoes
  ,QuantidadeAmbulancia
  ,StatusPrimeiraEntrega
  ,StatusSegundaEntrega
  ,DataUltimaEntrega
  ,Cidades
  ,KmColetadoMeli
  ,LinkMapaMeli
  ,KmColetadoAPP
  ,AmbulanciaFiltro
  ,Ambulancia
  ,HoraInicio
  ,Ciclo
  ,AlarmeRotaEntregaAtraso
  ,AlarmeRotaEntregaAtrasoFiltro
  ,TempoInativo
  ,tipo
  ,LogisticsRota
  ,Reclamacores
  ,CodOrigemSaida
  ,DescOrigemSaida
  ,ClassificacaoStemOut
  ,LancRisco
  ,KmMapaPacote
  ,CategoriaVeiculo
  ,TotalSacas
  ,PacotesSemSacas
  ,PacotesComImagem  
  ,FlagSEMIDAY
  ,KM_Rtt
  ,KM_Trevo
  ,UsuarioDA 
  ,Datahorasaidaestacao
  ,Ciclo_Novo
  ,StemOutReal
  ,TipoRotaClassificada
  ,DataHoraSaidaEstacaoFormatada
  ,PercentualPerformance
  ,DataPrimeiraEntrega
  ,TipoOrigemSaida
  ,NivelMotorista -- INSERIDA POR MURILO 29/05 PARA RELATÓRIO DE ANALISE GERENCIAL
  ,PercentualEntregasBemSucedidas -- INSERIDA POR MURILO 29/05 PARA RELATÓRIO DE ANALISE GERENCIAL
from
   vw_rotas r

GO
