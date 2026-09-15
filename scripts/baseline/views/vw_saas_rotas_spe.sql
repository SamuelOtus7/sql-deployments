-- ============================================================
-- BASELINE: dbo.vw_saas_rotas_spe
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_rotas_spe]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_saas_rotas_spe]
as
select
	IdInterno
	,CodigoRota
	,IdStation
	,NomeHub
	,Hub
	,IdTransportadora
	,IdMotorista
	,Motorista
	,DataReferencia
	,TotalPacotes
	,DataHoraColeta
	,PacotesEntregues
	,PacotesNaoEntregue
	,PacotesPendentes
	,RotaFinalizada
	,DataUltimaEntrega
	,KmColetado
	,LinkMapa
	,TipoVeiculo
	,DataHoraInicio
	,FiltroCarregamento
	,Paradas
	,CidadeReferencia
	,DistanciaTotal
	,LancRisco
	,UsuarioIrisys
	,CidadeDistante
	,SiglaHubMedida
	,PerformacePacotes
	,Placa
	,Ciclo
	,InicioDaRota
	,DataHoraInicioExib
	,TipoRota
	,FiltroRedelivery
	,DataHoraDesignacaoRota
from
	vw_rotas_spe_v4
GO
