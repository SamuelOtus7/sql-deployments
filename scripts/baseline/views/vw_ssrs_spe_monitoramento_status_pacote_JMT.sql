-- ============================================================
-- BASELINE: dbo.vw_ssrs_spe_monitoramento_status_pacote_JMT
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_spe_monitoramento_status_pacote_JMT]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_ssrs_spe_monitoramento_status_pacote_JMT] as 


select 
idtransportadora
,servicecenter
,CompradorAusente
,NegocioFechado
,EnderecoRuim
,Compradorrejeitado
,ForaRota
,ProblemasMecanicos
,MotoristaSemTempo
,FalhaAplicativo
,AreaRisco
,ClienteMudou
,Outros
,Perdido

from tb_ssrs_spe_monitoramento_status_pacote nolock

where DataReferencia = cast(dateadd(hour,-2,getdate()) as date) and
idtransportadora =  20230023
GO
