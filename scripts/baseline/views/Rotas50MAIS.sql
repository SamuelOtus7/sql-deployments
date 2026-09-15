-- ============================================================
-- BASELINE: dbo.Rotas50MAIS
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[Rotas50MAIS]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Rotas50MAIS]  AS 

select 
IdTransportadora
,Id
,IdRota
,DataReferencia
,DataHoraInicio
,TempoPlanejadoMinutos
,StatusRota
,SubStatusRota
,StatusPrazo
,ServiceCenter
,NomeServiceCenter
,Base
,CidadeBase
,TipoOrigemSaida
,OrigemSaida
,TipoRota
,TipoVeiculo
,NomeMotorista
,IdMotorista
,Codigo_usuario_motorista
,Placa
,NivelExperienciaMotorista
,IdNivelMotorista
,NivelMotorista
,QuantidadePacotesTransportados
,PercentualEntregasBemSucedidas
,PercentualEntregasSemRelamacaoes
,PossuiAjudante
,Ajudante
,KmColetado
,LinkMapa
,UsouAPP
,UsuarioDA
,CidadeDistante
,TotalPacotes
,PacotesEntregues
,PacotesPendentes
,PacotesNaoEntregue
,PacotesEntreguesForaAreaEntrega
,PacotesTransferidos
,TempoEmRota
,TempoChegadaAreaEntrega
,TempoAreaEntrega
,PercentualProgresso
,KmTotal
,TempoEmRotaSec
,SegundosEntreEntregas
,RotaFinalizada
,StatusGeralRota
,QuantidadePontos
,QuantidadeParadas
,QuantidadeReclamacoes
,QuantidadeAmbulancia
,StatusPrimeiraEntrega
,StatusSegundaEntrega
,DataPrimeiraEntrega
,DataUltimaEntrega
,Cidades
,CidadeReferencia
,KmColetadoMeli
,LinkMapaMeli
,KmColetadoAPP
,LinkMapaApp
,AmbulanciaFiltro
,Ambulancia
,KmMotorista
,QuantidadeApontamento
,Apuracao
,HoraInicio
,Ciclo
,AlarmeRotaEntregaAtraso
,AlarmeRotaEntregaAtrasoFiltro
,FaixaPrimeiroUltimoPacote
,TempoInativo
,tipo
,LogisticsRota
,Reclamacores
,CodOrigemSaida
,DescOrigemSaida
,ClassificacaoStemOut
,bss_ds_label
,Svc_Cidade
,Estado
,IdTrevo
,LancRisco
,LinkPacote
,KmMapaPacote
,CategoriaVeiculo
,PacotesDS
,ReclamacoesAbertasPeloTotalReclamacoes
,FlagSEMIDAY
,TotalSacas
,NovoXPT
,PacotesSemSacas
,PacotesComImagem
,vei_Cd_ano
,DataAtualizacao
,EnderecosVisitados
,TeveAcaoGps
,svc_nm_region
,QTD_Reclamacoes_em_aberto
,QTD_Reclamacoes_total
,vei_dh_criacao
,QuantidadePnr
,AmbulanciaStatus
,AmbulanciaPagamento
,AmbulanciaIdMotorista
,TipoFrota
,KM_Rtt
,KM_Trevo
,DataHoraSaidaEstacao
,Ciclo_Novo
,StemOutReal
,TipoRotaClassificada
,DataHoraSaidaEstacaoFormatada
,PercentualPerformance
,DriverId
,Ciclo_Novo_fc
from vw_rotas where IdTransportadora = 1726310024
GO
