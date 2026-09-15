-- ============================================================
-- BASELINE: dbo.sp_sla_stuck
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_sla_stuck]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_sla_stuck] as

DROP TABLE IF EXISTS #db_Irisys_Json.dbo.tb_dra_coleta;
SELECT
    a.dac_cd_coleta,
    a.dac_ds_contexto_json,
    a.dac_cd_transportadora

INTO #tb_dra_coleta

from db_Irisys_Json.dbo.tb_dra_coleta as a
inner join (
SELECT 
    dac_ds_contexto,
    max(dac_dh_escrita) as max_dac_dh_escrita

FROM db_Irisys_Json.dbo.tb_dra_coleta nolock
WHERE 1=1
and dac_ds_contexto in (
    select CodigoPacote from tb_spe_pacotes_v5
    where codigorota in (
        select CodigoRota from tb_spe_rotas_v5 
        where DataReferencia >= cast(getdate() - 4 as date)
        and IdTransportadora = 20230015 
        -- and NomeHub = 'XPT_MS_Coxim'
        -- and dac_ds_contexto = 'BR250089032978G'
    )
    and Excluido = 0 
)
and dac_ds_tipo_coleta = 'SP_PACKAGE_HISTORY'
and dac_in_processado = 0

GROUP BY dac_ds_contexto
) as b
on a.dac_ds_contexto = b.dac_ds_contexto
and a.dac_dh_escrita = b.max_dac_dh_escrita

-- select * from #db_Irisys_Json.dbo.tb_dra_coleta

-- select 
--     dac_cd_coleta,
--     dac_ds_contexto_json,
--     dac_cd_transportadora
     
-- from db_Irisys_Json.dbo.tb_dra_coleta a
-- inner join  (
--     select
--         dac_ds_contexto
--         ,max(dac_dh_referencia) as dac_dh_referencia 
--     FROM db_Irisys_Json.dbo.tb_dra_coleta nolock
--     WHERE 1=1
--     and dac_ds_tipo_coleta = 'SP_PACKAGE_HISTORY'
--     and dac_ds_contexto IN (select codigopacote from tb_spe_pacotes_v5 where idtransportadora = 20230015 and DataReferencia between '2025-03-16' and '2025-03-31')
--     group by dac_ds_contexto
-- ) as t1 
-- on a.dac_ds_contexto = t1.dac_ds_contexto
-- and a.dac_dh_referencia = t1.dac_dh_referencia

-- where a.dac_ds_tipo_coleta = 'SP_PACKAGE_HISTORY'


-- Consulta ajustada para incluir todos os elementos de tracking_list, mesmo com children vazio
drop table if exists #tabela;
SELECT
    isnull(c.id,tl.id) as id,
    t.dac_cd_coleta,
    dac_cd_transportadora,
    JSON_VALUE(dac_ds_contexto_json, '$.data.shipment_id') AS shipment_id, -- Incluindo o shipment_id
    DATEADD(SECOND, tl.timestamp, '1970-01-01 00:00:00') AS tracking_timestamp,
    DATEADD(SECOND, c.timestamp, '1970-01-01 00:00:00') AS child_timestamp,
    JSON_VALUE(dac_ds_contexto_json, '$.data.tracking_list[0].message') AS tracking_message,
    tl.station_id AS tracking_station_id,
    tl.station_name AS tracking_station_name,
    tl.status AS tracking_status,
    c.status AS child_status,
    case
        WHEN c.status = 0 THEN 'Created'
        WHEN c.status = 658 THEN 'FMHub_Pickup_Assigned'
        WHEN c.status = 113 THEN 'FMHub_Pickup_Done'
        WHEN c.status = 39 THEN 'FMHub_Received'
        WHEN c.status = 210 THEN 'FMHub_Packing'
        WHEN c.status = 211 THEN 'FMHub_Packed'
        WHEN c.status = 231 THEN 'FMHub_LHPacking'
        WHEN c.status = 232 THEN 'FMHub_LHPacked'
        WHEN c.status = 233 THEN 'FMHub_LHTransporting'
        WHEN c.status = 234 THEN 'FMHub_LHTransported'
        WHEN c.status = 39 THEN 'SOC_Received'
        WHEN c.status = 210 THEN 'SOC_Packing'
        WHEN c.status = 211 THEN 'SOC_Packed'
        WHEN c.status = 630 THEN 'SOC_Staging'
        WHEN c.status = 231 THEN 'SOC_LHPacking'
        WHEN c.status = 232 THEN 'SOC_LHPacked'
        WHEN c.status = 233 THEN 'SOC_LHTransporting'
         WHEN c.status = 15 THEN 'SOC_LHTransporting'
        WHEN c.status = 234 THEN 'SOC_LHTransported'
        WHEN c.status = 631 THEN 'SOC_Stage_Out'
        WHEN c.status = 400 then 'Hub_Received'
        WHEN c.status = 417 then 'Hub_Assigning'
        WHEN c.status = 418 then 'Hub_Assigned'
        WHEN c.status = 2 then 'Delivering'
        WHEN c.status = 1 THEN  'LMHub_Received'
        WHEN c.status = 53 THEN 'Return_LMHub_Received'

        else
            case
                when tl.status = 4 then 'Delivered'
                when tl.status = 2 then 'Delivering'
                when tl.status = 5 then 'On-Hold'
                WHEN tl.status = 1 THEN  'LMHub_Received'

            else null end
        end as child_status_desc,
    -- tl.station_id AS tracking_station_id,
    tl.message AS tracking_message1,
    tl.operator AS tracking_operator,
    -- c.status AS child_status,


    c.station_name AS child_station_name,
    -- c.station_id AS child_station_id,
    c.message AS child_message,
    c.operator AS child_operator,
    c.biz_staff_id AS child_biz_staff_id,
    c.biz_staff_name AS child_biz_staff_name,
    c.ws_id AS child_ws_id,
    c.ws_name AS child_ws_name

into #tabela

FROM #tb_dra_coleta t
 CROSS APPLY
    OPENJSON(dac_ds_contexto_json, '$.data.tracking_list')
    WITH (
        id INT,
        parent_id INT,
        parent_key NVARCHAR(255),
        timestamp BIGINT,
        status INT,
        station_name NVARCHAR(255),
        station_id INT,
        message NVARCHAR(MAX),
        operator NVARCHAR(255),
        on_hold_reason NVARCHAR(MAX),
        third_party_name NVARCHAR(255),
        "3pl_name" NVARCHAR(255),
        is_data_fix BIT,
        tracking_color_enum INT,
        tags NVARCHAR(MAX) AS JSON,
        biz_staff_id NVARCHAR(255),
        biz_staff_name NVARCHAR(255),
        ws_id NVARCHAR(255),
        ws_name NVARCHAR(255),
        children NVARCHAR(MAX) AS JSON
    ) AS tl
OUTER APPLY -- Usando OUTER APPLY para incluir elementos com children vazio
    OPENJSON(tl.children)
    WITH (
        id INT,
        parent_id INT,
        parent_key NVARCHAR(255),
        timestamp BIGINT,
        status INT,
        station_name NVARCHAR(255),
        station_id INT,
        message NVARCHAR(MAX),
        operator NVARCHAR(255),
        on_hold_reason NVARCHAR(MAX),
        third_party_name NVARCHAR(255),
        "3pl_name" NVARCHAR(255),
        is_data_fix BIT,
        tracking_color_enum INT,
        tags NVARCHAR(MAX) AS JSON,
        biz_staff_id NVARCHAR(255),
        biz_staff_name NVARCHAR(255),
        ws_id NVARCHAR(255),
        ws_name NVARCHAR(255)
    ) AS c;


drop table if exists #tabela2;
select
    a.id
    ,a.shipment_id
    ,ROW_NUMBER() OVER (PARTITION BY shipment_id ORDER BY tracking_timestamp,child_timestamp ) AS IdOrdem
    ,a.dac_cd_transportadora
    ,a.tracking_timestamp
    ,a.child_timestamp
    ,a.tracking_station_name
    ,a.tracking_message1
    ,a.child_status_desc
    ,case
        WHEN CHARINDEX('[XPT_', a.child_message) > 0 AND CHARINDEX(']', a.child_message, CHARINDEX('[XPT_', a.child_message)) > 0 THEN
        SUBSTRING(
            a.child_message,
            CHARINDEX('[XPT_', a.child_message) + 1,
            CHARINDEX(']', a.child_message, CHARINDEX('[XPT_', a.child_message)) - CHARINDEX('[XPT_', a.child_message) - 1
        )
        ELSE NULL
        END TransferidoHub
    ,CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY shipment_id ORDER BY tracking_timestamp DESC ) = 1 
        THEN 1 
        ELSE 0 
    END AS FimSLA

    ,CASE
        WHEN (tracking_message1 = 'Parcel returning' AND child_status_desc = 'Return_LMHub_Received') or (tracking_message1 = 'Parcel delivered') THEN 1 ELSE 0 END AS Finalizado

    into #tabela2

from #tabela as a



drop table if exists #tabela3;
select
    id
    ,IdOrdem
    ,shipment_id
    ,dac_cd_transportadora
    ,tracking_timestamp
    ,child_timestamp
    ,tracking_station_name
    ,tracking_message1
    ,child_status_desc
    ,TransferidoHub
    ,case when child_status_desc  in ('SOC_LHTransporting', 'FMHub_LHTransporting') and TransferidoHub = bss_ds_nome then 1 else 0 end as InicioSLA
    ,bss_ds_nome
    ,FimSla
    ,Finalizado
	
   into #tabela3

from #tabela2 as a 

left join tb_bases as b
on a.TransferidoHub = b.bss_ds_nome
and a.dac_cd_transportadora = bss_cd_idtransportadora


drop table if exists #tablea_final;
select distinct
    a.id
    --,IdOrdem
    ,a.shipment_id as CodigoPacote
    ,a.tracking_timestamp	as DataHoraColeta
    ,a.child_timestamp as DataHoraStatus
    ,a.tracking_station_name as NomeHub
    ,a.child_status_desc as StatusColeta
    ,a.tracking_message1 as MensagemColeta
    ,a.child_message as MensagemStatus
    ,isnull(d.InicioSLA, 0) AS InicioSLA
    ,isnull(d.FimSla, 0) AS FimSla
    ,isnull(c.Finalizado, 0) AS Finalizado

into #tablea_final

from  #tabela as a
left join  (select shipment_id,isnull(child_timestamp,tracking_timestamp) as child_timestamp,InicioSLA from #tabela3 where InicioSLA = 1 ) as b
on a.shipment_id = b.shipment_id
left join  (select shipment_id,isnull(child_timestamp,tracking_timestamp) as child_timestamp,FimSLA,Finalizado from #tabela3 where FimSLA = 1 ) as c
on a.shipment_id = c.shipment_id

left join  (select shipment_id,tracking_timestamp,InicioSLA ,FimSLA,id from #tabela3  ) as d
on a.id = d.id
and a.tracking_timestamp = d.tracking_timestamp

where  isnull(a.child_timestamp,a.tracking_timestamp) between b.child_timestamp and c.child_timestamp

-- com o row_number nao deve precisa mais
update tb
set tb.FimSla = 1

from #tabela3 as tb
inner join (
    select
        a.shipment_id
        ,max(a.id) as id

    from #tabela3 as a
    left join #tablea_final as b
    on a.shipment_id = b.CodigoPacote

    where b.CodigoPacote is null

    group by shipment_id
) as c
on tb.shipment_id = c.shipment_id
and tb.id = c.id


insert into #tablea_final
select
    a.id
    ,a.shipment_id as CodigoPacote
    ,a.tracking_timestamp	as DataHoraColeta
    ,a.child_timestamp as DataHoraStatus
    ,a.tracking_station_name as NomeHub
    ,a.child_status_desc as StatusColeta
    ,a.tracking_message1 as MensagemColeta
    ,a.child_message as MensagemStatus
    ,isnull(d.InicioSLA, 0) AS InicioSLA
    ,isnull(d.FimSla, 0) AS FimSla
    ,isnull(c.Finalizado, 0) AS Finalizado

from  #tabela as a
left join  (select shipment_id,isnull(child_timestamp,tracking_timestamp) as child_timestamp,InicioSLA from #tabela3 where InicioSLA = 1 ) as b
on a.shipment_id = b.shipment_id

left join  (select shipment_id,isnull(child_timestamp,tracking_timestamp) as child_timestamp,FimSLA,Finalizado from #tabela3 where FimSLA = 1 ) as c
on a.shipment_id = c.shipment_id

left join  (select shipment_id,tracking_timestamp,InicioSLA ,FimSLA,id from #tabela3  ) as d
on a.id = d.id
and a.tracking_timestamp = d.tracking_timestamp

left join #tablea_final as e
on a.id = e.id

where  isnull(a.child_timestamp,a.tracking_timestamp) between b.child_timestamp and c.child_timestamp
and e.id is null


-- select tracking_station_name,* from #tablea_final
MERGE tb_spe_sla_stuck AS target
USING #tablea_final AS source
ON target.IdJson = source.id



WHEN NOT MATCHED BY TARGET THEN
    INSERT (CodigoPacote, IdJson, DataHoraColeta, EstacaoColeta, NomeHub, StatusColeta, MensagemColeta, MensagemStatus, InicioSLA, FimSla,Finalizado)
    VALUES (source.CodigoPacote, source.id, source.DataHoraColeta, source.DataHoraStatus, source.NomeHub, source.StatusColeta, source.MensagemColeta, source.MensagemStatus, source.InicioSLA, source.FimSla, source.Finalizado);



-- select distinct codigopacote from tb_spe_sla_stuck
-- select * from tb_spe_sla_stuck
-- select * from #tablea_final
-- select * from #table3
-- truncate table tb_spe_sla_stuck


update db_Irisys_Json.dbo.tb_dra_coleta
set dac_in_processado = 1
where dac_cd_coleta  in (
    select distinct dac_cd_coleta
    from #tabela
)


-- select * from vw_spe_pacotes_reprocessar

-- select * from tb_spe_pacotes_V5 nolock where idtransportadora = 20230015 and codigopacote = 'BR2532072393574'





GO
