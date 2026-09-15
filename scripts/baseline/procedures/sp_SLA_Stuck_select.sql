-- ============================================================
-- BASELINE: dbo.sp_SLA_Stuck_select
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_SLA_Stuck_select]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_SLA_Stuck_select] as

drop table if exists #tabelaSLA;
drop table if exists #vld;
WITH
    PacotesTentativas
    AS
    (
        SELECT
            p.idtransportadora,
            p.DataReferencia,
            r.NomeHub,
            p.codigopacote,
            p.codigorota,
            p.SubStatus,
            p.cidade,
             CASE 
                WHEN p.cidade IN ('Sonora','Alcinópolis','Corguinho','Rochedo')
                    then 2
                WHEN r.NomeHub IN ('XPT_PA_Castanhal')
                    then 0
                else 1
              end DiasSla,
            -- COUNT(DataHoraEntrega) AS TentativasEntrega,
            ROW_NUMBER() OVER (PARTITION BY p.codigopacote ORDER BY p.DataHoraEntrega ) AS TentativasEntrega,
            MAX(StatusEntrega) AS UltimoStatusEntrega,
            MAX(p.DataHoraEntrega) AS UltimaDataHoraEntrega
        -- sum(case when dt.diadasemana = 'domingo' then 24 else 0 end) as Domingo,
        -- sum(case when dt.diadasemana = 'sábado' then 24 else 0 end) as Sabado

        FROM tb_spe_pacotes_V5 p
            left join DimData as dt
            on p.DataReferencia = dt.Data

            left join tb_spe_rotas_v5 as r
            on p.idtransportadora = r.idtransportadora
                and p.CodigoRota = r.CodigoRota

        where p.idtransportadora =  20230015
            and p.DataReferencia >= '2025-07-01'
        -- and p.DataReferencia between '2025-05-19' and '2025-05-22'
        -- and p.Excluido = 0
        --  and codigopacote  = 'BR2500799841357'
        -- and codigopacote in (
        --     select distinct codigopacote from tb_spe_sla_stuck where codigopacote = 'BR254137989017Y'
        -- )

        GROUP BY codigopacote,p.idtransportadora, r.NomeHub, p.codigorota, p.DataReferencia,DataHoraEntrega, p.SubStatus,p.cidade
    ),

    PacotesComPrazoAjustado
    AS
    (
        SELECT
            p.idtransportadora,
            p.DataReferencia,
            p.NomeHub,
            sla.StatusColeta,
            p.codigorota,
            p.codigopacote,
            p.UltimoStatusEntrega ,
            p.SubStatus as MotivoInsucesso,

            max(p.TentativasEntrega ) as TentativasEntrega,
            max(p.UltimaDataHoraEntrega ) as UltimaDataHoraEntrega,
            dateadd(hour,-3,max(sla.DataEntradaPacote )) as DataEntradaPacote,
            DATEDIFF(day, max(sla.DataEntradaPacote), max(p.UltimaDataHoraEntrega) )   tempo,
            DATEADD(day, DiasSla, MAX(sla.DataEntradaPacote)) AS PrazoInicial,
            sum(CASE WHEN DiaDaSemana = 'domingo' THEN 1 ELSE 0 END)  as tempofds

        FROM PacotesTentativas p
            LEFT JOIN (
                    select

                a.StatusColeta
                        , b.dataentradaPacote
                        , a.codigopacote
                        , b.Finalizado

            from (
                            select

                    ROW_NUMBER() over (partition by a.codigopacote order by a.DatahoraColeta desc) as row_num
                            , *
                from tb_spe_sla_stuck a

                    ) as a

                inner join
                (
                            SELECT
                    codigopacote,
                    max(Finalizado) AS Finalizado,
                    min(CASE WHEN InicioSLA = 1 THEN EstacaoColeta END) AS DataEntradaPacote

                FROM tb_spe_sla_stuck
                GROUP BY codigopacote

                            ) b
                on a.codigopacote = b.codigopacote

            where row_num = 1

    ) sla ON p.codigopacote = sla.codigopacote

            left join DimData dt
            on dt.Data between sla.DataEntradaPacote and p.UltimaDataHoraEntrega

        group by         p.idtransportadora,
        p.DataReferencia,
        p.NomeHub,
        sla.StatusColeta,
        p.codigorota,
        p.codigopacote,
        p.UltimoStatusEntrega,
        p.SubStatus,
        DiasSla

        -- WHERE p.TentativasEntrega > 1
    )

SELECT distinct
    *
    , CAST(
        CASE 
            WHEN LAG(UltimoStatusEntrega) 
                OVER (PARTITION BY codigopacote ORDER BY UltimaDataHoraEntrega) IN ('OnHold','Transferred') 
                THEN DATEADD(day, 3, PrazoInicial) 
            ELSE 
                case when DATEPART(WEEKDAY, PrazoInicial) = 1 then DATEADD(day, 1, PrazoInicial) else PrazoInicial end   
        END AS DATE
    ) AS DataVencimento

into #tabelaSLA
FROM PacotesComPrazoAjustado


select

    a.*
    
    , case when SLAIrisys = SLAPrefatura then 'Igual' else 'Diferente' end as ComparacaoSLA

into #vld

from (
    select
        p.*
        , CASE 
            WHEN DataEntradaPacote IS NOT NULL THEN 'Teve Coleta' 
            ELSE 'Nao Teve Coleta' 
        END AS Coletado
        , pre.SLAPrefatura
        , CASE 
            when cast(UltimaDataHoraEntrega as date) <= cast(DataVencimento as date) and TentativasEntrega = 1 and UltimoStatusEntrega <> 'Delivered' then 'Dentro'
            when cast(UltimaDataHoraEntrega as date) <= cast(DataVencimento as date) and TentativasEntrega < 3 and UltimoStatusEntrega = 'Delivered' then 'Dentro'
            --when cast(UltimaDataHoraEntrega as date) <= cast(DataVencimento as date) and UltimoStatusEntrega = 'Delivering' then 'Pendente'
            when  UltimoStatusEntrega = 'Delivering' then 'Pendente'
            when cast(UltimaDataHoraEntrega as date) <= cast(DataVencimento as date) and TentativasEntrega > 1 and UltimoStatusEntrega in ('OnHold','Transferred')  then 'Fora'
        else 'Fora'
    END AS SLAIrisys

    from #tabelaSLA p
        left join (

    select
            null ano
        , null mes
        , null quinzena
        , 40 idtransportadora	
        , rota
        , pacote pacote
        , null  as kmrodado
        , null as FlagRisco
        , null as TarifaAplicada
        , cidade
        , case 
        when valorecebimento = ' 4,00 ' then 'Dentro'
        when valorecebimento = ' 3,00 ' then 'Fora'
        else null end as SLAPrefatura

        from tb_prefatura_shopee
) as pre
        on p.codigopacote = pre.pacote
) as a

    left join DimData dt
    on cast(dataentradaPacote as date) = dt.Data


-- where CAST(datavencimento as date)  = '2025-06-03'


select 
    *
from #vld
-- where CodigoPacote = 'BR250030224771F'


-- select distinct  
-- a.codigopacote 
-- ,b.shipment_id
--  from #vld as a
-- left join tb_spe_sla_spx as b
-- on a.codigopacote = b.shipment_id
-- where b.shipment_id is null
-- and nomehub = 'XPT_MS_São Gabriel do Oeste'



-- select distinct  
--  nomehub
-- ,count(*) as TotalPacotes
-- ,sum(case when b.shipment_id is not null then 1 else 0 end) as Encontrado
-- ,sum(case when b.shipment_id is null then 1 else 0 end) as NaoEncontrado
--  from #vld as a
-- left join tb_spe_sla_spx as b
-- on a.codigopacote = b.shipment_id
-- and nomehub = station_name  
-- where 1=1 
-- -- and b.shipment_id is null
-- and nomehub = 'XPT_MS_São Gabriel do Oeste'
-- group by nomehub


-- select
--     a.expected_date
-- , station_name
-- , count(*) as TotalPacotes
-- , sum(case when b.codigopacote is not null then 1 else 0 end) as Encontrado
-- , sum(case when b.codigopacote is null then 1 else 0 end) as NaoEncontrado
-- from tb_spe_sla_spx as a
--     left join #vld as b
--     on a.shipment_id = b.codigopacote
--         and a.station_name = b.nomehub
--         and a.expected_date = b.datavencimento
-- where a.shipment_id is not null
-- and expected_date = '2025-05-22'
-- --and station_name = 'XPT_BA_Mata de São João'
-- group by station_name, a.expected_date


-- select
--     a.expected_date
--     , station_name
--     , a.shipment_id

-- from tb_spe_sla_spx as a
--     left join #vld as b
--     on a.shipment_id = b.codigopacote
--         and a.station_name = b.nomehub
--         and a.expected_date = b.datavencimento
-- where b.codigopacote is null
--     and a.shipment_id is not null
--     and station_name = 'XPT_BA_Mata de São João'
--     and expected_date = '2025-05-22'

-- select *  from tb_spe_pacotes_v5 where codigopacote  = 'BR258574603062L'
-- order by DataHoraColeta,	EstacaoColeta
-- select cast(datavencimento as date), *  from #VLD where codigopacote = 'BR2574335350978'

--resumo diferenca
-- select 
--     CASE 
--         WHEN  DentroPrazo = 'Igual' then DentroPrazo 
--         else case when  NumDiaSemana in (7, 1) then 'Inicio FDS' ELSE  DentroPrazo end end as DentroPrazo
  
--     ,count(*)    as TotalPacotes
--     -- ,sum(case when NumDiaSemana in (7, 1) then 1 end) as InicioFDS
-- from (
--     select 
--         p.*
--         , pre.DentroSLA
--         ,case when PrazoSLA = pre.DentroSLA then 'Igual' else 'Diferente' end as DentroPrazo
        
--     from #tabelaSLA p
--     left join (

--     select
--             null ano
--                     , null mes
--                     , null quinzena
--                     , 40 idtransportadora	
--                     , rota
--                     ,pacote pacote
--                     , null  as kmrodado
--                     , null as FlagRisco
--                     , null as TarifaAplicada
--                     , cidade
--                     , case 
--                         when valorecebimento = ' 4,00 ' then 'Dentro'
--                         when valorecebimento = ' 3,00 ' then 'Fora'
--                     else null end as DentroSLA
 
--     from tb_prefatura_shopee
-- ) as pre
-- on p.codigopacote = pre.pacote
-- ) as a

-- left join DimData dt
-- on cast(dataentradaPacote as date) = dt.Data    


-- group by rollup( CASE 
--         WHEN  DentroPrazo = 'Igual' then DentroPrazo 
--         else case when  NumDiaSemana in (7, 1) then 'Inicio FDS' ELSE  DentroPrazo end end)

-- having count(*) > 1



--extrato diferenca
-- select 
--     DentroPrazo,
--     case when  NumDiaSemana in (7, 1) then 'Inicio FDS' ELSE  null end as InicioFDS,
--     *
-- from (
--     select 
--         p.*
--         , pre.DentroSLA
--         ,case when PrazoSLA = pre.DentroSLA then 'Igual' else 'Diferente' end as DentroPrazo
        
--     from #tabelaSLA p
--     left join (

--     select
--             null ano
--                     , null mes
--                     , null quinzena
--                     , 40 idtransportadora	
--                     , rota
--                     ,pacote pacote
--                     , null  as kmrodado
--                     , null as FlagRisco
--                     , null as TarifaAplicada
--                     , cidade
--                     , case 
--                         when valorecebimento = ' 4,00 ' then 'Dentro'
--                         when valorecebimento = ' 3,00 ' then 'Fora'
--                     else null end as DentroSLA
 
--     from tb_prefatura_shopee
-- ) as pre
-- on p.codigopacote = pre.pacote
-- ) as a

-- left join DimData dt
-- on cast(dataentradaPacote as date) = dt.Data    

-- where DentroPrazo = 'Diferente'





-- select count(*) from #tabelaSLA
-- where DataEntradaPacote is null


-- select * from tb_spe_sla_stuck where codigopacote = 'BR255329182979H'

-- select * from tb_spe_sla_stuck where codigopacote = 'BR2542136127378'
GO
