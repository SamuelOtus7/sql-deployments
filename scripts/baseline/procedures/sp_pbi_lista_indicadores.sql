-- ============================================================
-- BASELINE: dbo.sp_pbi_lista_indicadores
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_pbi_lista_indicadores]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_pbi_lista_indicadores] as   
  
drop table if exists #Pacotes  
select *  
into #Pacotes   
from  vw_pacotes nolock  
where IdTransportadora = 2087146923  
and DataReferencia between '2023-07-01' and '2023-11-01'  
--and Excluido = 0  
  
drop table if exists #PacotesTransferidos  
select *    
into #PacotesTransferidos  
from #pacotes  
where  SubStatus = 'Transferido'  
  
  
drop table if exists #ListaTransferencia  
select distinct   
 *  
 ,row_number() over(partition by a.idpacote order by a.DataHoraEntrega) as OrdemTransf  
 ,row_number() over(partition by a.idpacote order by a.DataHoraEntrega desc) as OrdemTransfDesc  
 into #ListaTransferencia  
  
 from (  
 select distinct  
  
   a.DataHoraEntrega   
  ,a.DataReferencia  
  ,a.IdTransportadora   
  ,a.IdRota   
  ,a.identrega as idpacote  
  --,a.Cidade  
  ,a.SubStatus   
  ,a.StatusEntrega  
  --,a.StatusParada  
  ,a.IdRotaOrigem   
  ,a.IdRotaDestino  
  ,NULL AS TempoEntrega  
  ,c.NomeMotorista  
  ,d.NomeMotoristaDestino  
  
  
 from #pacotes as a  
 inner join #PacotesTransferidos as b  
 on a.identrega = b.identrega  
  
 left join   
  (  
  select distinct  
   IdTransportadora  
  ,IdRota  
  ,NomeMotorista  
  from vw_rotas   
  )as c  
  on a.IdTransportadora = c.IdTransportadora  
  and a.IdRota = c.IdRota  
  
 left join   
  (  
  select distinct  
   IdTransportadora  
  ,IdRota  
  ,NomeMotorista as NomeMotoristaDestino  
  from vw_rotas   
  )as d  
  on a.IdTransportadora = d.IdTransportadora  
  and a.IdRotaDestino = d.IdRota  
) as a  
  
  
  
UPDATE a  
set   
a.TempoEntrega = b.TempoEntrega  
  
from #ListaTransferencia as a  
inner join   
 (  
 select   
   fim.DataHoraEntrega  
  ,fim.idpacote  
  ,fim.OrdemTransfDesc  
  ,datediff(SECOND,inicio.DataHoraEntrega,fim.DataHoraEntrega) as TempoEntrega  
  
 from   
  (  
  select   
   DataHoraEntrega  
   ,idpacote  
  from #ListaTransferencia  
  where OrdemTransf =1   
    
  ) as inicio  
  
 inner join   
  (  
  select   
   DataHoraEntrega  
   ,idpacote  
   ,OrdemTransfDesc  
  from #ListaTransferencia  
  where OrdemTransfDesc = 1   
  
  ) as fim  
  on inicio.idpacote = fim.idpacote   
  
 ) as b  
on a.idpacote = b.idpacote   
and a.OrdemTransfDesc = b.OrdemTransfDesc  
  
  
  
--drop table tb_lista_transferencias  
--select     
  
--  DataHoraEntrega   
-- ,DataReferencia   
-- ,IdTransportadora   
-- ,IdRota   
-- ,idpacote   
-- ,SubStatus   
-- ,StatusEntrega   
-- ,TempoEntrega  
-- ,IdRotaOrigem   
-- ,IdRotaDestino  
-- ,NomeMotorista  
-- ,NomeMotoristaDestino  
  
--from tb_lista_transferencias  
  
--insert into tb_lista_transferencias  
  
select * from #ListaTransferencia  
--where idpacote = 42684573689  
--order by 10
GO
