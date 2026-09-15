-- ============================================================
-- BASELINE: dbo.UspGetAppFinBravoxListarRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetAppFinBravoxListarRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
           
CREATE procedure [dbo].[UspGetAppFinBravoxListarRotas]  
(  
 @Transportadora int  
 --@Rota varchar(50)  
 ,@Ano   int  
 ,@Mes   int  
 ,@Quinzena int  
 ,@svc varchar(max)  
)as  
  
--esta rpocedure alimenta a tela financeiro bravox  
  
  
  
--  ----'KM Rodado' [Distância Percorrida]  
--  ----    'Link KM' [Link da Distância]  
--  ----    'Ciclo' [Período do Dia]  
--  ----    'Tipo de veículo' [Tipo do Veículo]  
--  ----    'Base' [Localização Base]  
--  ----    'Pacotes' [Quantidade de Pacotes]  
--  ----    'Pontos' [Quantidade de Pontos]  
--  ----    'Paradas' [Quantidade de Paradas]  
--  ----    'Pacotes Entregues' [Pacotes Entregues]  
--  ----    'Ajudante' [Recebimento do Ajudante]  
--  ----    'Área de risco' [Receb. Área de Risco]  
--  ----    'Data' [Data da Rota]  
  
  --declare @Transportadora int = 5,  
  -- @Rota varchar(50) = null  
  
  
SELECT  distinct   
      fin.[Ano]  
     ,fin.[Mes]  
     ,fin.[Quinzena]  
     ,isnull(tbinsert.ID,fin.[IdRota])    as ID  
     ,fin.[DataReferencia]       as Data  
  ,isnull(tbinsert.[Hora Incio],fin.HoraInicio)  as [Hora Incio]  
     ,isnull(tbinsert.[Service Center],fin.[ServiceCenter]) as [Service Center]  
  
     ,fin.[Placa]  
  
     ,[Motorista]         -- campos da bravox  
     ,tbinsert.[Tipo de Contrato]  -- campos da bravox  
     ,tbinsert.[Prazo]     -- campos da bravox  
     ,tbinsert.[Tipo de rota]   -- campos da bravox --Tipo de contrato?  
  
     ,fin.[Cluster]  
     ,isnull(tbinsert.Categoria,fin.[TipoVeiculo]) as [Categoria] --[Tipo do Veículo]  
  
     ,isnull(tbinsert.Ciclo,[CicloPM])    as [Ciclo]  
  
     ,[QuantidadeParadas]       as [Quantidade de Paradas]  
  
     ,isnull(tbinsert.[Valor Saida] ,fin.[PgtoSaida])         as [Valor Saida]  
  
     , case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end        as [Valor Parada]  
       
  ,case when tbinsert.[Tipo de rota] = 'Dividida'   
    then isnull(  tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end  ,fin.[PgtoTotal] ) / 2   
    else isnull(  tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end  ,fin.[PgtoTotal] ) end as [Total] --é esse campo mesmo?   
  
     ,isnull(tbinsert.KM,fin.[KmColetadoPagamento])   as [KM]  
  
     -- ,fin.[FaixaKmPagamento]         as [Faixa de kM] --[Faixa kM (DA)]  
        ,CAST(ISNULL( tbinsert.faixakm , fin.[FaixaKmPagamento]) AS varchar(10)) AS [Faixa de kM]  
  ,tbinsert.[Motorista recebedor]  
  ,tbinsert.[Motorista recebedor 2]  
  ,tbinsert.[Valores Extras]  
  ,tbinsert.[Valor de apoio]  
  ,tbinsert.[OBS Valor de apoio]  
  ,tbinsert.[Valor Pedágio]  
  ,tbinsert.[OBS Valor Pedágio]  
  ,tbinsert.[Valor Desconto]  
  ,tbinsert.[OBS Valor Desconto]  
  ,tbinsert.[Valor Extra]  
  ,tbinsert.[OBS Valor Extra]  
  
 FROM [vw_resultado_financeiro] fin  
  
inner join tb_clientes as clientes  
on fin.IdTransportadora = clientes.cli_cd_codigo_cliente  
  
left join   
  (  
   select   
    idrota as idrotaapp  
    ,UsouAPP  
   from vw_rotas_motoristas   
   where 1=1  
   --and idrota = @rota  
  )  
  as usouapp  
  on fin.idrota = usouapp.idrotaapp  
  
left join [tb_fin_ficha_motorista] as tbinsert  
on  clientes.cli_cd_codigo_cliente = tbinsert.[IdTransportadora]  
and fin.[IdRota] = tbinsert.[id]  
  
where 1=1  
and clientes.cli_cd_codigo_cliente = @Transportadora  
-- AND fin.IdRota = @Rota  
and fin.Ano   = @ano  
and fin.Mes   = @mes  
and fin.Quinzena = @quinzena  
and fin.[ServiceCenter] = @svc  
  
GO
