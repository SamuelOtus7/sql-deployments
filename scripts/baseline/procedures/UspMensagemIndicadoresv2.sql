-- ============================================================
-- BASELINE: dbo.UspMensagemIndicadoresv2
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMensagemIndicadoresv2]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [db_Irisys]
--GO

CREATE procedure [dbo].[UspMensagemIndicadoresv2] 
(
@transportdora INT,
    @data date,
    @svc varchar(50),
  @codrelatorio int,
    @ciclo varchar(10) null,
    @xpt varchar(10) null 
)as 


-- PROCEDURE  [UspMensagemIndicadoresv2] ESTÁ SENDO UTILIZADA APENAS PARA ENVIO DE RELATÓRIOS SHOPEE. OS OUTROS RELATÓRIOS UTILIZAM  A PROCEDURE
-- [UspMensagemIndicadoresv2_XPT_DUPLO], POR CONTA DA LÓGICA DE PARAMETRIZAÇÃO POR XPT. SERÁ NECESSÁRIA A ATUALIZAÇÃO DO BACKEND PARA CONSIDERAR APENAS 
-- A PROCEDURE ´[UspMensagemIndicadoresv2_XPT_DUPLO] PARA AMBOS OS PROCESSOS


-------------------------------------------------------------------------------------------------------------------------------------------
-- set @ciclo = case 
--               --  when @ciclo = 'AM' then 'Vitor Ferreira'
--                 when @ciclo = 'pm' then 'am' 
--                 else 'am' end

-- am pra nulo
-- pm vira am


--DECLARE  @transportdora INT = 37 ,
--@data date = '2026-03-23',
--@svc varchar(10) = 'SSP28',
--@codrelatorio int = 1092,
--@ciclo varchar(10) = 'todos',
--@xpt varchar(10) = 'base'



--DECLARE  @transportdora INT = 27,
--@data date = '2024-04-04',
--@svc varchar(50) = 'LM Hub_SP_Jundiaí',
--@codrelatorio int = 1122

if @codrelatorio in (1092,1128,1146,1182,1195)
begin


  SELECT  Indicador as Indicador
      ,Valor


  FROM   
     (
    select 
      --  IdTransportadora
      -- ,IdRota
      -- 'Endereço incorreto: 2/nDestinatário ausente: 4/nEstabelecimento fechado: 6' as ListaInsucessos
       cast(format(DataReferencia,'dd/MM') as varchar(30)) as data
       ,cast(left(round(cast(sum(CAST(PacotesEntregues AS INT )) as decimal(10,2)) / SUM(CAST(TotalPacotes AS INT ) )*100,2),5) + '%'   as varchar(30)) as   [success_delivery]
       ,cast(sum(CAST(TotalPacotes AS INT)) as varchar(30)) as pacotes
       ,cast(sum(CAST(PacotesEntregues AS INT )) as varchar(30)) as  entregues
       ,cast(sum(case when StatusRota = 'Fechada' then 1 else 0 end ) as varchar(30)) as finalizados
       ,cast(sum(case when StatusRota = 'Ativa' then 1 else 0 end ) as varchar(30)) as abertos
       ,cast(sum(case when StatusRota = 'Retornar Para Estação' then 1 else 0 end ) as varchar(30)) as retornar_para_estacao
       ,cast(sum(CAST(PacotesPendentes AS INT) ) as varchar(30)) as qtde_pendentes
    --   ,cast(left(round(cast(sum(CAST(PacotesPendentes as INT)) as decimal(10,2)) / SUM(CAST(TotalPacotes AS INT))*100,2),5) + '%'   as varchar(30)) as   [perc_pendentes]
    ,CAST(
    FORMAT(
        TRY_CAST(SUM(TRY_CAST(PacotesPendentes AS INT)) AS DECIMAL(10, 2)) 
        / NULLIF(SUM(TRY_CAST(TotalPacotes AS INT)), 0) * 100, 
        'N1'
    ) + '%' 
AS VARCHAR(30)) AS [perc_pendentes]
       ,cast(sum(CAST(PacotesNaoEntregue as INT )) as varchar(30)) as         insucessos
            ,cast(sum(isnull(QuantidadeAmbulancia,0)) as varchar(30)) as ambulancia
      ,cast(sum(isnull(QuantidadeReclamacoes,0)) as varchar(30)) as qtd_Reclamacoes
      ,cast(servicecenter as varchar(30)) as sigla_svc
      ,cast(Base as varchar(30)) as nome_svc
          --   ,case when @ciclo = 'todos' then @ciclo else case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end end as   ciclo

      ,CAST(
    CASE 
        WHEN @ciclo = 'todos' THEN @ciclo 
        ELSE CASE WHEN FORMAT(datahorainicio,'HH') < 12 THEN 'AM' ELSE 'PM' END 
    END 
AS VARCHAR(30)) AS ciclo
, cast(sum(isnull(totalsacas,0)) as varchar(30)) as sacas
,CAST(
    FORMAT(
        TRY_CAST(SUM(TRY_CAST(pacotesnaoentregue AS INT)) AS DECIMAL(10, 2)) 
        / NULLIF(SUM(TRY_CAST(TotalPacotes AS INT)), 0) * 100, 
        'N1'
    ) + '%' 
AS VARCHAR(30)) AS  [perc_insucesso],
cast(sum(isnull(Quantidadeparadas,0)) as varchar(30))  as paradas



    from vw_rotas
    where
     (
       (IdTransportadora = 1387994348 AND StatusRota = 'Ativa')
    OR (IdTransportadora <> 1387994348)
)
and 
    IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
            )
    and DataReferencia = @data
    and servicecenter = @svc
    --  and origemsaida = @svc
        and (case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end = @ciclo or @ciclo  = 'todos')

      AND (
                (@xpt = 'XPT' AND OrigemSaida <> @svc) OR
                (@xpt = 'base' AND (OrigemSaida IS NULL OR OrigemSaida = '' OR OrigemSaida = @svc)) OR
                (@xpt = 'ambos' AND 1=1)
            )
    group by DataReferencia,servicecenter,Base
        ,case when @ciclo = 'todos' then @ciclo else case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end end
     ) p  
  UNPIVOT  
     (Valor FOR Indicador IN   
      (  
      data
      ,pacotes
      ,qtde_pendentes
      ,[success_delivery]
      ,[perc_pendentes]
      ,finalizados
      ,abertos
      ,retornar_para_estacao
      ,insucessos 
      ,sigla_svc
            ,nome_svc
      ,entregues
            ,ambulancia
            ,qtd_Reclamacoes
            ,ciclo
      ,sacas
      ,[perc_insucesso]
      ,paradas
      -- ,ListaInsucessos
      )  
  )AS unpvt

union ALL

  select 
    'lista_insucessos' as lista_insucessos
    ,cast(STRING_AGG('• ' + a.SubStatus  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor
    -- ,a.qtd
  FROM
  (
    select 

      b.SubStatus
      ,COUNT(*) qtd

    from vw_rotas as a
    inner join vw_pacotes as b
    on a.idtransportadora = b.idtransportadora
    and a.IdRota = b.IdRota

    where 
       (
       (a.IdTransportadora = 1387994348 AND a.StatusRota = 'Ativa')
    OR (a.IdTransportadora <> 1387994348)
)
and 
    a.IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
            )
    and a.DataReferencia = @data
    and a.servicecenter = @svc
    --  and origemsaida = @svc
        and (case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end = @ciclo or @ciclo  = 'todos')


        AND (
                (@xpt = 'XPT' AND OrigemSaida <> @svc) OR
                (@xpt = 'base' AND (OrigemSaida IS NULL OR OrigemSaida = '' OR OrigemSaida = @svc)) OR
                (@xpt = 'ambos' AND 1=1)
            )
    and StatusEntrega = 'Não Entregue'
    and b.SubStatus <> 'Transferido'
    group by b.SubStatus

  ) as a

union ALL

select 
    'lista_veiculos' as lista_veiculos
    ,cast(STRING_AGG('• ' + a.TipoVeiculo  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor
    -- ,a.qtd
FROM
(
    select 

        a.TipoVeiculo
        ,COUNT(*) qtd

    from vw_rotas as a

    where a.IdTransportadora in (
                    select distinct  cli_id_logistics
                    from tb_clientes 
                    where 1=1 
                    and cli_cd_codigo_cliente =  @transportdora
                    and cli_ds_logo_report  is not null
                    )
    and a.DataReferencia = @data
    and a.servicecenter = @svc
  --  and origemsaida = @svc

    and (case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end = @ciclo or @ciclo  = 'todos')
      AND (
                (@xpt = 'XPT' AND OrigemSaida <> @svc) OR
                (@xpt = 'base' AND (OrigemSaida IS NULL OR OrigemSaida = '' OR OrigemSaida = @svc)) OR
                (@xpt = 'ambos' AND 1=1)
            )

    group by a.TipoVeiculo

) as a


--- indicadores diarios
union ALL

SELECT  Indicador as Indicador
,Valor
FROM   
(            

SELECT
    cast(ind_dh_data as date) as data
    ,aci_cd_base
    ,cast(isnull([ind_in_veiculos_cadastrados]      ,0) as varchar(50)) as in_veiculos_cadastrados
    ,cast(isnull([ind_in_veiculos_disponibilizados] ,0) as varchar(50)) as in_veiculos_disp
    ,cast(isnull([ind_in_rotas_recebidas]           ,0) as varchar(50)) as in_rotas_recebidas
    ,cast(isnull([ind_in_rotas_carregadas]          ,0) as varchar(50)) as in_rotas_carregadas
    ,cast(isnull([ind_in_noShow]                    ,0) as varchar(50)) as in_noShow
    ,cast(isnull([ind_in_distrato]                  ,0) as varchar(50)) as in_distrato
    ,cast(isnull([ind_ds_noShow_nome]               ,0) as varchar(50)) as ds_noShow_nome
    ,cast(isnull([ind_ds_noShow_motivo]             ,0) as varchar(50)) as ds_noShow_motivo
    ,cast(isnull([ind_ds_noShow_operacao]           ,0) as varchar(50)) as ds_noShow_operacao
    ,cast(isnull([ind_in_distrato_nome]             ,0) as varchar(50)) as in_distrato_nome
    ,cast(isnull([ind_in_distrato_motivo]           ,0) as varchar(50)) as in_distrato_motivo
FROM (SELECT @svc AS ServiceCenter) AS Base
  outer apply (
          select * -- ALTRERAR PARA TRAZER APENAS OS CAMPOS NECESSÁRIOS
          from [tb_indicadores_diarios] as a
            inner join tb_acessos_indicadores as b
            on a.ind_cd_base = b.aci_cd_acessos_indicadores
              and a.ind_cd_transportadora = b.aci_cd_transportadora
          where cast(ind_dh_data as date) = @data
                    and ind_cd_transportadora = @transportdora
          and aci_cd_base = base.ServiceCenter
        ) as a
-- and  cast(ind_dh_data as date) = @data


) p  
UNPIVOT  
(Valor FOR Indicador IN   
(  
in_veiculos_cadastrados
,in_veiculos_disp
,in_rotas_recebidas
,in_rotas_carregadas
,in_noShow
,in_distrato
,ds_noShow_nome
,ds_noShow_motivo
,ds_noShow_operacao
,in_distrato_nome
,in_distrato_motivo
-- ,ListaInsucessos

)
)AS unpvt

end 



else if @codrelatorio in (1126,1160)
  begin

  SELECT  Indicador as Indicador
      ,Valor  
  FROM   
     (
    select 
      --  IdTransportadora
      -- ,IdRota
      -- 'Endereço incorreto: 2/nDestinatário ausente: 4/nEstabelecimento fechado: 6' as ListaInsucessos
       cast(format(DataReferencia,'dd/MM') as varchar(30)) as data
      -- ,cast(left(round(cast(sum(CAST(PacotesEntregues AS INT )) as decimal(10,2)) / SUM(CAST(TotalPacotes AS INT ) )*100,2),5) + '%'   as varchar(30)) as   [success_delivery]
      ,cast(
    left(
        round(
            cast(sum(CAST(PacotesEntregues AS INT )) as decimal(10,2)) 
            / NULLIF(SUM(CAST(TotalPacotes AS INT)), 0) * 100,
        2), 5
    ) + '%' 
as varchar(30)) as [success_delivery]


      ,     cast(sum(CAST(TotalPacotes AS INT)) as varchar(30)) as pacotes
       ,cast(sum(CAST(PacotesEntregues AS INT )) as varchar(30)) as  entregues
       ,cast(sum(case when StatusRota = 'Fechada' then 1 else 0 end ) as varchar(30)) as finalizados
       ,cast(sum(case when StatusRota = 'Ativa' then 1 else 0 end ) as varchar(30)) as abertos
       ,cast(sum(CAST(PacotesPendentes AS INT) ) as varchar(30)) as qtde_pendentes

    ,cast(
    left(
        round(
            cast(sum(CAST(PacotesPendentes AS INT )) as decimal(10,2)) 
            / NULLIF(SUM(CAST(TotalPacotes AS INT)), 0) * 100,
        2), 5
    ) + '%' 
as varchar(30)) as [perc_pendentes]

    -- ,cast(left(round(cast(sum(CAST(PacotesPendentes as INT)) as decimal(10,2)) / SUM(CAST(TotalPacotes AS INT))*100,2),5) + '%'   as varchar(30)) as   [perc_pendentes]
       ,cast(sum(CAST(PacotesNaoEntregue as INT )) as varchar(30)) as         insucessos
            ,cast(sum(isnull(QuantidadeAmbulancia,0)) as varchar(30)) as ambulancia
      ,cast(sum(isnull(QuantidadeReclamacoes,0)) as varchar(30)) as qtd_Reclamacoes
      ,         CAST(@ciclo AS VARCHAR(30)) AS ciclo
      , cast(sum(isnull(totalsacas,0)) as varchar(30)) as sacas
,CAST(
    FORMAT(
        TRY_CAST(SUM(TRY_CAST(pacotesnaoentregue AS INT)) AS DECIMAL(10, 2)) 
        / NULLIF(SUM(TRY_CAST(TotalPacotes AS INT)), 0) * 100, 
        'N1'
    ) + '%' 
AS VARCHAR(30)) AS  [perc_insucesso],
cast(sum(isnull(Quantidadeparadas,0)) as varchar(30))  as paradas


      --,cast(servicecenter as varchar(30)) as sigla_svc
      --,cast(Base as varchar(30)) as nome_svc
      --,cast(servicecenter as varchar(30)) as sigla_svc
      --,cast(Base as varchar(30)) as nome_svc


    from vw_rotas_diaatual
    where 
     (
    @ciclo = 'TODOS'
    OR Ciclo = @ciclo
)
and

    IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
            )
    and DataReferencia = @data
    --and servicecenter = @svc
    group by DataReferencia--,Ciclo

     ) p  
  UNPIVOT  
     (Valor FOR Indicador IN   
      (  
        data
      ,pacotes
      ,qtde_pendentes
      ,[success_delivery]
      ,[perc_pendentes]
      ,finalizados
      ,abertos
      ,insucessos 

      ,entregues
            ,ambulancia
            ,qtd_Reclamacoes
            ,ciclo
      ,sacas
      ,[perc_insucesso]
      ,paradas
      )  
  )AS unpvt

  union ALL

  select 
    'lista_insucessos' as lista_insucessos
    ,cast(STRING_AGG('• ' + a.SubStatus  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor
    -- ,a.qtd
  FROM
  (
    select 

      b.SubStatus
      ,COUNT(*) qtd

    from vw_rotas_diaatual as a
    inner join vw_pacotes_diaatual as b
    on a.idtransportadora = b.idtransportadora
    and a.IdRota = b.IdRota

    where a.IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
            )
    and a.DataReferencia = @data
    --and a.servicecenter = @svc
    and StatusEntrega = 'Não Entregue'
    and b.SubStatus <> 'Transferido'
    group by b.SubStatus

  ) as a



  ----------

  union all

select 
    'lista_veiculos' as lista_veiculos
    ,cast(STRING_AGG('• ' + a.TipoVeiculo  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor

    -- ,a.qtd
FROM
(
    select 

        a.TipoVeiculo
        ,COUNT(*) qtd

    from vw_rotas as a

    where a.IdTransportadora in (
                    select distinct  cli_id_logistics
                    from tb_clientes 
                    where 1=1 
                    and cli_cd_codigo_cliente =  @transportdora
                    and cli_ds_logo_report  is not null
                    )
    and a.DataReferencia = @data
  --  and origemsaida = @svc

    and (case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end = @ciclo or @ciclo  = 'todos')


    group by a.TipoVeiculo

) as a

--- indicadores diarios
union ALL

SELECT  Indicador as Indicador
,Valor
FROM   
(            

SELECT
    cast(ind_dh_data as date) as data
    ,aci_cd_base
    ,cast(isnull([ind_in_veiculos_cadastrados]      ,0) as varchar(50)) as in_veiculos_cadastrados
    ,cast(isnull([ind_in_veiculos_disponibilizados] ,0) as varchar(50)) as in_veiculos_disp
    ,cast(isnull([ind_in_rotas_recebidas]           ,0) as varchar(50)) as in_rotas_recebidas
    ,cast(isnull([ind_in_rotas_carregadas]          ,0) as varchar(50)) as in_rotas_carregadas
    ,cast(isnull([ind_in_noShow]                    ,0) as varchar(50)) as in_noShow
    ,cast(isnull([ind_in_distrato]                  ,0) as varchar(50)) as in_distrato
    ,cast(isnull([ind_ds_noShow_nome]               ,0) as varchar(50)) as ds_noShow_nome
    ,cast(isnull([ind_ds_noShow_motivo]             ,0) as varchar(50)) as ds_noShow_motivo
    ,cast(isnull([ind_ds_noShow_operacao]           ,0) as varchar(50)) as ds_noShow_operacao
    ,cast(isnull([ind_in_distrato_nome]             ,0) as varchar(50)) as in_distrato_nome
    ,cast(isnull([ind_in_distrato_motivo]           ,0) as varchar(50)) as in_distrato_motivo
FROM (SELECT isnull(@svc,'-') AS ServiceCenter) AS Base
  outer apply (
          select * -- ALTRERAR PARA TRAZER APENAS OS CAMPOS NECESSÁRIOS
          from [tb_indicadores_diarios] as a
            inner join tb_acessos_indicadores as b
            on a.ind_cd_base = b.aci_cd_acessos_indicadores
              and a.ind_cd_transportadora = b.aci_cd_transportadora
          where cast(ind_dh_data as date) = @data
                    and ind_cd_transportadora = @transportdora
          and aci_cd_base = base.ServiceCenter
        ) as a
-- and  cast(ind_dh_data as date) = @data

) p  
UNPIVOT  
(Valor FOR Indicador IN   
(  
in_veiculos_cadastrados
,in_veiculos_disp
,in_rotas_recebidas
,in_rotas_carregadas
,in_noShow
,in_distrato
,ds_noShow_nome
,ds_noShow_motivo
,ds_noShow_operacao
,in_distrato_nome
,in_distrato_motivo
-- ,ListaInsucessos

)
)AS unpvt
  end 


  else if @codrelatorio  in (1122,1199,1184)
  begin

    --DECLARE  @transportdora INT = 20230008,
    --  @data date = '2024-04-04',
    --  @svc varchar(50) = 'LM Hub_SP_Jundiaí'

    SELECT  Indicador as Indicador
        ,Valor

    FROM   
       (
      select 
        --  IdTransportadora
        -- ,IdRota
        -- 'Endereço incorreto: 2/nDestinatário ausente: 4/nEstabelecimento fechado: 6' as ListaInsucessos
        cast(format(DataHoraInicio,'dd/MM') as varchar(30)) as data
        ,cast(sum(PacotesEntregues) as varchar(30)) as entregues
        ,cast(left(round(cast(sum(PacotesEntregues) as decimal(10,2)) / SUM(TotalPacotes)*100,2),5) + '%'   as varchar(30)) as   [success_delivery]
        ,cast(sum(TotalPacotes) as varchar(30)) as         pacotes
        ,cast(sum(RotaFinalizada) as varchar(30)) as finalizados
        ,cast(sum(case when RotaFinalizada = 0 then 1 else 0 end ) as varchar(30)) as abertos
        ,cast(sum(PacotesPendentes) as varchar(30)) as qtde_pendentes
        ,cast(left(round(cast(sum(PacotesPendentes) as decimal(10,2)) / SUM(TotalPacotes)*100,2),5) + '%'   as varchar(30)) as   [perc_pendentes]
        ,cast(sum(PacotesNaoEntregue) as varchar(30)) as         insucessos
,cast(
    cast(
        cast(
            round(cast(sum(PacotesNaoEntregue) as decimal(10,2)) / NULLIF(SUM(TotalPacotes),0)*100,2) as decimal(10,2)
        ) as varchar(30)
    ) + '%'
as varchar(30)) as [perc_insucesso]
,cast(NomeHub as varchar(30)) as sigla_svc
        ,cast(Hub as varchar(30)) as nome_svc


      from vw_ssrs_spe_monitoramento 
      where IdTransportadora in (
                        select distinct  cli_id_shopee
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
            )
      and cast(datahorainicio as date) = @data
      and NomeHub = @svc
      group by cast(format(DataHoraInicio,'dd/MM') as varchar(30)),NomeHub,Hub

       ) p  
    UNPIVOT  
       (Valor FOR Indicador IN   
        (  
        data
        ,entregues
        ,pacotes
        ,qtde_pendentes
        ,[success_delivery]
        ,[perc_pendentes]
        ,finalizados
        ,abertos
        ,insucessos 
        ,[perc_insucesso]
        ,sigla_svc
        ,nome_svc
        -- ,ListaInsucessos
        )  
    )AS unpvt

    union all


    select 
      'lista_insucessos' as lista_insucessos
      ,cast(STRING_AGG('• ' + a.SubStatus  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor
      -- ,a.qtd
    FROM
    (
      select 

        b.SubStatus
        ,COUNT(*) qtd

      from vw_ssrs_spe_monitoramento  as a
      inner join vw_pacotes_spe_v4 as b
      on a.idtransportadora = b.idtransportadora
      and a.IDROTA = b.codigorota

      where a.IdTransportadora in (
                        select distinct  cli_id_shopee
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
            )
      and cast(a.datahorainicio as date) = @data
      and a.NomeHub = @svc
      and statusentrega = 'Não Entregue'
      group by b.SubStatus
    ) as a

union all


--- indicadores diarios

SELECT  Indicador as Indicador
,Valor
FROM   
(        

SELECT
    cast(ind_dh_data as date) as data
    ,aci_cd_base
    ,cast(isnull([ind_in_veiculos_cadastrados]      ,0) as varchar(50)) as [in_veiculos_cadastrados]
    ,cast(isnull([ind_in_veiculos_disponibilizados] ,0) as varchar(50)) as [in_veiculos_disp]
    ,cast(isnull([ind_in_rotas_recebidas]           ,0) as varchar(50)) as [in_rotas_recebidas]
    ,cast(isnull([ind_in_rotas_carregadas]          ,0) as varchar(50)) as [in_rotas_carregadas]
    ,cast(isnull([ind_in_noShow]                    ,0) as varchar(50)) as [in_noShow]
    ,cast(isnull([ind_in_distrato]                  ,0) as varchar(50)) as [in_distrato]
    ,cast(isnull([ind_ds_noShow_nome]               ,0) as varchar(50)) as [ds_noShow_nome]
    ,cast(isnull([ind_ds_noShow_motivo]             ,0) as varchar(50)) as [ds_noShow_motivo]
    ,cast(isnull([ind_ds_noShow_operacao]           ,0) as varchar(50)) as [ds_noShow_operacao]
    ,cast(isnull([ind_in_distrato_nome]             ,0) as varchar(50)) as [in_distrato_nome]
    ,cast(isnull([ind_in_distrato_motivo]           ,0) as varchar(50)) as [in_distrato_motivo]
FROM (SELECT @svc AS ServiceCenter) AS Base
  outer apply (
          select * -- ALTRERAR PARA TRAZER APENAS OS CAMPOS NECESSÁRIOS
          from [tb_indicadores_diarios] as a
            inner join tb_acessos_indicadores as b
            on a.ind_cd_base = b.aci_cd_acessos_indicadores
              and a.ind_cd_transportadora = b.aci_cd_transportadora
          where cast(ind_dh_data as date) = @data
                    and ind_cd_transportadora = @transportdora
          and aci_cd_base = base.ServiceCenter
        ) as a
-- and  cast(ind_dh_data as date) = @data

) p  
UNPIVOT  
(Valor FOR Indicador IN   
(  
[in_veiculos_cadastrados]
,[in_veiculos_disp]
,[in_rotas_recebidas]
,[in_rotas_carregadas]
,[in_noShow]
,[in_distrato]
,[ds_noShow_nome]
,[ds_noShow_motivo]
,[ds_noShow_operacao]
,[in_distrato_nome]
,[in_distrato_motivo]
-- ,ListaInsucessos

)
)AS unpvt


  end 


 
GO
