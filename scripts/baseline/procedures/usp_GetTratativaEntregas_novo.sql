-- ============================================================
-- BASELINE: dbo.usp_GetTratativaEntregas_novo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_GetTratativaEntregas_novo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_GetTratativaEntregas_novo]  (          
@idtransportadora int         
--,@date date    
,@dataInicial date         
,@dataFinal date     
,@svc varchar(50)          
) as            


 --declare @idtransportadora int = 37        
 --,@dataInicial date = '2024-07-13'        
 --,@dataFinal date = '2024-07-15'     
 --,@date date = '2024-07-15'     
 --,@svc varchar(50) = 'SSP9'          
          
DECLARE @transportadora int = (select cli_id_logistics  from tb_clientes WHERE cli_cd_codigo_cliente= @idtransportadora)          
          
drop table if exists #vw_pacotes          
select *           
into #vw_pacotes          
from vw_pacotes        
where DataReferencia between @dataInicial and @dataFinal         
and idtransportadora  = @transportadora          
and StatusEntrega = 'Não Entregue'    
and Ambulancia = 0        
        
drop table if exists #vw_rotas          
select *           
into #vw_rotas          
from vw_rotas          
where DataReferencia between @dataInicial and @dataFinal         
and ServiceCenter in (select value from STRING_SPLIT(@svc, ','))          
and idtransportadora  = @transportadora      
and Ambulancia = 0      
          
       
select           
    pacote.DataReferencia          
    ,pacote.idrota          
    ,rotas.ServiceCenter           
 ,pacote.EnderecoParada as EnderecoEntrega          
 ,pacote.DataHoraEntrega as DataHoraInsucesso          
    ,rotas.Base          
    ,rotas.OrigemSaida AS XPT          
    ,rotas.NomeMotorista as Motorista          
    ,pacote.IdEntrega as idpacote          
    ,pacote.TipoEndereco          
    ,case when datepart(hour,rotas.DataHoraInicio) <= 12  then 'AM' else 'PM' end as Ciclo           
    ,motorista.Telefone ContatoMotorista          
    ,detalhes.TelefoneComprador ContatoRecebedor          
    ,detalhes.NomeComprador NomeRecebedor          
 ,isnull(tratativas.MotivoTratativa,pacote.SubStatus) as MotivoTratativa          
 ,tratativas.[Status]          
 ,tratativas.observacao          
 ,tratativas.imagem          
          
from #vw_pacotes as pacote          
          
left join #vw_rotas as rotas          
on pacote.IdTransportadora = rotas.IdTransportadora          
and pacote.IdRota = rotas.IdRota          
          
left join tb_ml_motoristas as motorista          
on rotas.NomeMotorista = motorista.Nome          
and rotas.idtransportadora = motorista.idtransportadora        
          
left join tb_tratativas_entregas as tratativas          
on pacote.IdTransportadora = tratativas.idtransportadora          
and pacote.IdRota = tratativas.idrota          
and pacote.identrega = tratativas.idpacote          
          
left join tb_ml_detalhes_pacotes as detalhes          
on pacote.IdTransportadora = detalhes.idtransportadora          
and pacote.identrega = detalhes.idpacote          
          
          
where pacote.DataReferencia between @dataInicial and @dataFinal             
and pacote.IdTransportadora = @transportadora          
and (          
    pacote.IdEntrega in (select idpacote  from tb_tratativas_entregas_inclusas ) or          
    pacote.StatusGeralEntrega in ('Insucesso')           
    )          
and rotas.ServiceCenter in (select value from STRING_SPLIT(@svc, ','))  
GO
