-- ============================================================
-- BASELINE: dbo.vw_ssrs_spe_monitoramento_JMT
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_spe_monitoramento_JMT]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_ssrs_spe_monitoramento_JMT]
as


select 
    IdTransportadora
    ,NomeMotorista
    ,ServiceCenter
    ,IdRota
    ,UltimaEntrega
    ,TotalPacotes
    ,PacotesEntregues
    ,PacotesPendentes
    ,Insucesso
    ,PacotesTransferidos
    ,Reclamacoes
    ,RotaFinalizada
    ,TotalRotas
    ,RotaEmCurso
    ,Progresso
    ,DataHoraInicio
    ,NomeHub
    ,Hub
    ,PacotesNaoEntregue
    ,MediaPacotesPorHora
    ,TempoTotalRotaHoras
    ,HorarioInicioRota

from tb_ssrs_spe_monitoramento nolock
WHERE DataReferencia = cast(getdate() as date) and
IdTransportadora = 20230023
GO
