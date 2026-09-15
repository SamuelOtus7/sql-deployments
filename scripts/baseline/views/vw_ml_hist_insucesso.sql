-- ============================================================
-- BASELINE: dbo.vw_ml_hist_insucesso
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
--/****** Object:  View [dbo].[vw_ml_hist_insucesso]    Script Date: 7/22/2026 3:14:35 PM ******/  
--SET ANSI_NULLS ON  
--GO  
  
--SET QUOTED_IDENTIFIER ON  
--GO  
  
  
CREATE  view [dbo].[vw_ml_hist_insucesso] as  
  
  
select    
  
    a.CodInsucesso  
    ,a.IdTransportadora  
    ,a.DataReferencia  
    ,a.DataAtualizacao  
    ,a.IdRota  
    ,a.IdPacote  
    ,a.NomeMotorista  
    ,a.ServiceCenter  
    ,a.XPT  
    ,a.NomeEtiqueta  
    ,pct.StatusEntrega  
    ,a.SubStatus  
    ,a.statusrota  
    ,a.Endereco  
    ,a.EnderecoParada  
    ,a.QuantidadeReclamacoes  
    ,a.ForaAreaEntrega  
    ,a.Revertido  
    ,a.RevertidoOutraRota  
    ,a.IdRotaRevertida  
    ,a.DataReversao  
    ,b.TipoRecebedor  
    ,b.NomeRecebedor  
    ,b.NomeComprador   
    ,b.TelefoneComprador  
    ,case when a.Revertido = 1 then 'Sim' else 'Não' end as RevertidoFiltro  
    ,case when a.RevertidoOutraRota = 1 then 'Sim' else 'Não' end as RevertidoOutraRotaFitro  
    ,isnull(tempo.SkTempo,-1) as SkTempo      
    ,0.8 Meta -- criar uma tela para cada cliente controlar sua meta  
    ,trat.MotivoTratativa   
  
    ,trat.Status as StatusTratativa   
    ,trat.Observacao as ObservacaoTratativa  
    ,trat.Imagem  
    ,trat.UsuarioTratativa as UsuarioAtualizacaoTratativa  
    ,isnull(usu.usr_nm_usuario,'Tratativas sem operador') as NomeUsuarioTratativa  
    ,NomeContato1  
    ,TelefoneContato1  
    ,EmailContato1  
    ,NomeContato2  
    ,TelefoneContato2  
    ,EmailContato2  
    ,NomeContato3  
    ,TelefoneContato3  
    ,EmailContato3  
 --,vwp.id  
 , 1 as ID  
  
from tb_ml_hist_insucesso as a with(nolock)  
  
left join tb_ml_detalhes_pacotes as B with(nolock)   
on a.idpacote  = b.IdPacote  
and a.IdTransportadora = b.IdTransportadora  
  
left join tb_Tratativas_Entregas as trat with(nolock)  
on CAST(a.IdRota as varchar(20))  = trat.IdRota  
and CAST(a.IdPacote  as varchar(20)) = trat.IdPacote  
and a.IdTransportadora = trat.IdTransportadora  
  
left join DimTempo as tempo  
on tempo.hora = a.HoraReversao  
and minuto = 0  
  
left join tb_ml_pacotes as pct with(nolock)  
on a.IdRota = pct.IdRota  
and a.IdPacote = pct.IdPacote  
  
--inner join vw_pacotes vwp on vwp.IdEntrega = a.IdPacote   
----and vwp.DataReferencia = a.DataReferencia  
  
left join tb_usuario usu with(nolock)  
on trat.UsuarioTratativa = usr_cd_usuario   
  
  
where 1=1   
--and a.substatus not in ('Pendente','Transferido','Entregue')  
--and pct.SubStatus not in ('delivered','transferred')  
and a.idtransportadora in (1726310024,678279205,2130011770,1950609251  
            ,472463006,652375997,652375997,643493085,1622793553,2087146923,7)  
--and a.idpacote = 47527429801  
  
--and vwp.substatus <> 'Transferido'  
--and vwp.statusentrega <> 'Pendente'  
  
--and a.substatus <> 'Perdido'   
-- AND CAST(a.IdRota as varchar(20)) = 'AT202504021ZW69'  
-- and  DataReferencia = '2025-03-15'  
  
GO
