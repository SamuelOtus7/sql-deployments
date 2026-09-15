-- ============================================================
-- BASELINE: dbo.vw_ssrs_ml_monitoramento_status_pacote
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_ml_monitoramento_status_pacote]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
  
--select * from vw_ssrs_ml_monitoramento_status_pacote  
--select * from vw_ssrs_ml_monitoramento_status_pacote  
  
CREATE view [dbo].[vw_ssrs_ml_monitoramento_status_pacote] as   
  

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
where DataReferencia = cast(getdate() as date)
  /*
SELECT  
a.idtransportadora,  
servicecenter,  
OrigemSaida,  
case when DATEPART(hour,b.DataHoraInicio) < 12 then 'AM' ELSE 'PM' end ciclo,  
--a.idrota,  
  COUNT(CASE WHEN a.SubStatus = 'buyer_absent' THEN 1 END) AS CompradorAusente,  
  COUNT(CASE WHEN a.SubStatus = 'business_closed' THEN 1 END) AS NegocioFechado,  
  COUNT(CASE WHEN a.SubStatus = 'bad_address' THEN 1 END) AS EnderecoRuim,  
  COUNT(CASE WHEN a.SubStatus = 'buyer_rejected' THEN 1 END) AS CompradorRejeitado,  
  COUNT(CASE WHEN a.SubStatus = 'missrouted' THEN 1 END) AS ErroDeRota,  
  COUNT(CASE WHEN a.SubStatus = 'blocked_by_keyword' THEN 1 END) AS BloqueadoPorPalavraChave,  
  0 AS Bloqueado,  
  COUNT(CASE WHEN a.SubStatus = 'missing' THEN 1 END) AS Perdido,  
  COUNT(CASE WHEN a.SubStatus = 'unvisited_address' THEN 1 END) AS EnderecoNaoVisitado,  
  COUNT(CASE WHEN a.SubStatus = 'inaccessible_address' THEN 1 END) AS EnderecoInacessivel,  
  COUNT(CASE WHEN a.SubStatus = 'cancelled' THEN 1 END) AS Cancelado,  
  COUNT(CASE WHEN a.SubStatus = 'buyer_moved' THEN 1 END) AS CompradorMudou,  
  COUNT(CASE WHEN   a.StatusEntrega in ('On_Hold','On Hold','OnHold','Cancelled','not_delivered') and    
     isnull(a.SubStatus,'Não categorizado') not in ('buyer_absent','business_closed','bad_address','buyer_rejected',  
          'missrouted','blocked_by_keyword','missing',  
          'unvisited_address','inaccessible_address','buyer_moved','cancelled','transferred') THEN 1 END) AS Outros,  
  COUNT(CASE WHEN a.StatusEntrega in ('On_Hold','On Hold','OnHold','Cancelled','not_delivered')  
  and isnull(a.SubStatus,'Não categorizado')  <> 'transferred' THEN 1 END) AS insucesso  
    
    
FROM  
  tb_ml_pacotes as a  
  inner join tb_ml_rotas as b  
  on a.idrota = b.idrota and a.DataReferencia = b.DataReferencia and a.IdTransportadora = b.IdTransportadora  
  inner join tb_clientes as c on a.IdTransportadora = c.cli_id_logistics and c.cli_in_ativo = 1 and c.cli_cd_codigo_cliente <> 7  
WHERE  
   b.StatusRota <> 'planned'  
  and a.Excluido = 0  
  and b.Excluido = 0  
  and b.datareferencia = cast(dateadd(hour,-2,getdate()) as date) -- NÃO ALTERAR, USADO PARA ENVIOS NOS FECHAMENTOS DIÁRIOS  
  and a.datareferencia = cast(dateadd(hour,-2,getdate()) as date) -- NÃO ALTERAR, USADO PARA ENVIOS NOS FECHAMENTOS DIÁRIOS  

  group by a.idtransportadora,servicecenter,OrigemSaida,case when DATEPART(hour,b.DataHoraInicio) < 12 then 'AM' ELSE 'PM' end--,a.idrota  
 */
GO
