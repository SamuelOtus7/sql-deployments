-- ============================================================
-- BASELINE: dbo.vw_ssrs_ml_monitoramento_status_pacote_JMT
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_ml_monitoramento_status_pacote_JMT]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_ssrs_ml_monitoramento_status_pacote_JMT] as   
  

select 
    idtransportadora
    ,servicecenter
    ,OrigemSaida
    ,ciclo
    ,CompradorAusente
    ,NegocioFechado
    ,EnderecoRuim
    ,CompradorRejeitado
    ,ErroDeRota
    ,BloqueadoPorPalavraChave
    ,Bloqueado
    ,Perdido
    ,EnderecoNaoVisitado
    ,EnderecoInacessivel
    ,Cancelado
    ,CompradorMudou
    ,Outros
    ,insucesso
from tb_insucessos_por_ciclo nolock
where 
DataReferencia = cast(getdate() as date)
and idtransportadora = 1025381599


GO
