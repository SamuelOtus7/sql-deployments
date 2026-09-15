-- ============================================================
-- BASELINE: dbo.UspSPEWebhookAgency
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEWebhookAgency]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPEWebhookAgency]
as 

drop table if exists #base
select  top 5000 * 
into #base 
from db_Irisys_Json.dbo.tb_spe_webhook with(nolock)
where 1=1
and processingStatus = 0
and idtransportadora is null
and agency is null
and cast(createdAt as date) = cast(getdate() as date) 
and    JSON_VALUE(db_Irisys_Json.dbo.tb_spe_webhook.jsondata, '$.data.data_type') = '3'


drop table if exists #base2
select 
agency_id
,TipoJsons
,rota
,pacote
,aux.id

into #base2

from #base as aux
cross apply openjson (aux.jsondata, '$.data')
WITH (
    agency_id int '$.agency_id',
    TipoJsons nvarchar(100) '$.body.content_data.business_type',
    rota nvarchar(max) '$.body.content_data.data[0].trip_number',
    pacote nvarchar(max) '$.body.content_data.data[0].order_number'
);


update   a
set     
    agency = b.agency_id
    ,   idtransportadora = COALESCE(c1.cli_id_shopee,
                                c2.cli_id_shopee,
                                c3.cli_id_shopee,
                                c4.cli_id_shopee,
                c5.cli_id_shopee),TipoJson = b.TipoJsons
    ,CodigoRota = b.rota
    ,CodigoPacote = b.pacote

FROM db_Irisys_Json.dbo.tb_spe_webhook AS a WITH (NOLOCK)
INNER JOIN #base2 AS b
    ON a.id = b.id
LEFT JOIN tb_clientes AS c1 
    ON c1.cli_agency_shpee = b.agency_id
LEFT JOIN tb_clientes AS c2 
    ON c2.cli_agency_shopee_2 = b.agency_id
LEFT JOIN tb_clientes AS c3 
    ON c3.cli_agency_shopee_3 = b.agency_id
LEFT JOIN tb_clientes AS c4 
    ON c4.cli_agency_shopee_4 = b.agency_id
  LEFT JOIN tb_clientes AS c5 
    ON c5.cli_agency_Shopee_5 = b.agency_id

--where b.CodigoRota is not null


-- insert into tb_spe_motoristas
-- select base.driver_id,
--      base.idtransportadora,
--      null as idstation,
--      base.driver_name,
--      null as TipoVeiculo,
--      null as TotalEntregas,
--      null as Latitude,
--      null as Longitude,
--      null as Transportadora,
--      base.driver_name as NomeMotorista,
--      null as FotoDocumento,
--      null as FotoMotorista,
--      1 as Ativo,
--      null as DataInativo,
--      null as NomeTipoVeiculo,
--      null as CPF,
--      null as Status,
--      null as Email,
--      null as SubStatus,
--      null as StatusLogin,
--      null as Renavam,
--      null as ModificacaoSPX,
--      null as DisplayStatus,
--      null as Aniversario,
--      null as NomeStation,
--      null as UltimoLoginSPX,
--      null as Cidade,
--      null as Rua,
--      null as Numero,
--      null as Cep,
--      null as FlagAgencia
-- from (
--     select driver_id,
--          driver_name,
--          idtransportadora
--     from db_Irisys_Json.dbo.tb_spe_webhook as base
--       cross apply (
--         SELECT driver_id,
--              driver_name
--         FROM OPENJSON(base.jsondata)
--         WITH (
--           driver_id varchar(100) '$.data.body.content_data.data[0].driver_id',
--           driver_name varchar(100) '$.data.body.content_data.data[0].driver_name'
--         )) as drivers
--     where cast(createdAt as date) = cast(getdate() as date) and TipoJson = 'trip_info'
--    --WHERE CAST(createdAt AS DATE) BETWEEN DATEADD(DAY, -2, CAST(GETDATE() AS DATE)) AND CAST(GETDATE() AS DATE) -- adicionado temporariamente para reprocessamento de motoristas nulas

--     group by driver_id,
--          driver_name,
--          idtransportadora
--    ) as base
--   left join tb_spe_motoristas as drivers
--   on base.driver_id = drivers.IdMotorista
--and base.idtransportadora = drivers.idtransportadora
-- where drivers.IdMotorista is null  -- CONSULTA ANTIGA.



MERGE INTO tb_spe_motoristas AS target
USING (
    SELECT 
        driver_id as IdMotorista,
        driver_name as NomeMotorista,
        idtransportadora as Idtransporte
    FROM db_Irisys_Json.dbo.tb_spe_webhook AS base
    CROSS APPLY (
        SELECT 
            driver_id,
            driver_name
        FROM OPENJSON(base.jsondata)
        WITH (
            driver_id VARCHAR(100) '$.data.body.content_data.data[0].driver_id',
            driver_name VARCHAR(100) '$.data.body.content_data.data[0].driver_name'
        )
    ) AS drivers_data
    WHERE CAST(base.createdAt AS DATE) = CAST(GETDATE() AS DATE)
      AND base.TipoJson = 'trip_info'
    GROUP BY 
        driver_id,
        driver_name,
        idtransportadora
) AS source

ON target.IdMotorista = source.IdMotorista 
AND (target.idtransportadora = source.Idtransporte 
        OR (target.idtransportadora IS NULL AND source.Idtransporte IS NULL))
    --WHEN MATCHED THEN
    -- Redundante: Faz nada efetivamente
   -- UPDATE SET target.IdMotorista = target.IdMotorista
WHEN NOT MATCHED THEN
    INSERT (
        IdMotorista,
        idtransportadora,
        NomeMotorista,
    Nome,

        Ativo

    )
    VALUES (
        source.IdMotorista,         -- IdMotorista
        source.Idtransporte,  -- idtransportadora
        source.NomeMotorista,       -- NomeMotorista
    source.NomeMotorista, -- nome

        1                      -- Ativo

    );



-- BEGIN TRY
--    MERGE INTO tb_spe_motoristas AS target
--    USING (
--        SELECT 
--            drivers.driver_id,
--            drivers.driver_name,
--            base.idtransportadora
--        FROM db_Irisys_Json.dbo.tb_spe_webhook AS base
--        CROSS APPLY (
--            SELECT 
--                driver_id,
--                driver_name
--            FROM OPENJSON(base.jsondata)
--            WITH (
--                driver_id VARCHAR(100) '$.data.body.content_data.data[0].driver_id',
--                driver_name VARCHAR(100) '$.data.body.content_data.data[0].driver_name'
--            )
--        ) AS drivers
--        WHERE CAST(base.createdAt AS DATE) = '2024-11-28'
--          AND base.TipoJson = 'trip_info'
--          AND drivers.driver_id NOT IN (
--              SELECT IdMotorista
--              FROM tb_spe_motoristas
--              GROUP BY IdMotorista
--              HAVING COUNT(*) > 1 -- Excluir IDs duplicados
--          )
--        GROUP BY 
--            drivers.driver_id,
--            drivers.driver_name,
--            base.idtransportadora
--    ) AS source
--    ON target.IdMotorista = source.driver_id
--       AND (target.idtransportadora = source.idtransportadora OR target.idtransportadora IS NULL) -- Tratar nulos
--    WHEN MATCHED THEN
--        UPDATE SET 
--            target.NomeMotorista = source.driver_name,
--            target.idtransportadora = source.idtransportadora, -- Atualização de idtransportadora
--            target.Ativo = 1
--    WHEN NOT MATCHED THEN
--        INSERT (
--            IdMotorista,
--            idtransportadora,
--            IdStation,
--            Nome,
--            TipoVeiculo,
--            TotalEntregas,
--            Latitude,
--            Longitude,
--            Transportadora,
--        NomeMotorista,
--            FotoDocumento,
--            FotoMotorista,
--            Ativo,
--            DataInativo,
--            NomeTipoVeiculo,
--            CPF,
--            Status,
--            Email,
--            SubStatus,
--            StatusLogin,
--            Renavam,
--            ModificacaoSPX,
--            DisplayStatus,
--            Aniversario,
--            NomeStation,
--            UltimoLoginSPX,
--            Cidade,
--            Rua,
--            Numero,
--            Cep,
--            FlagAgencia
--        )
--        VALUES (
--            source.driver_id,
--            source.idtransportadora,
--            NULL,
--            source.driver_name,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--        source.driver_name,
--            NULL,
--            NULL,
--            1,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL,
--            NULL
--        );
--END TRY
--BEGIN CATCH
--    --PRINT 'Erro detectado: ' + ERROR_MESSAGE();
--END CATCH;




-- Atualiza para '0' o campo UltimoRegistro para registros de 'order_update'
UPDATE db_Irisys_Json.dbo.tb_spe_webhook
SET UltimoRegistro = 0
WHERE 
    CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
    AND processingStatus = 0
    AND TipoJson = 'order_update'
    AND idtransportadora IS NOT NULL;

-- Seleciona o último registro para 'order_update' com base em Codigopacote
WITH UltimaInformacao AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (PARTITION BY Codigopacote,codigorota ORDER BY createdAt DESC) AS rn
    FROM 
        db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
    WHERE 
        CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
         AND processingStatus = 0
        AND TipoJson = 'order_update'
        AND idtransportadora IS NOT NULL
        AND (Inprocessing = 0 OR Inprocessing IS NULL)
)
-- Atualiza o campo UltimoRegistro para '1' onde rn = 1 (último registro)
UPDATE db_Irisys_Json.dbo.tb_spe_webhook
SET UltimoRegistro = 1
FROM UltimaInformacao u
WHERE db_Irisys_Json.dbo.tb_spe_webhook.id = u.id
AND u.rn = 1;

-- Atualiza para '0' o campo UltimoRegistro para registros de 'trip_info'
UPDATE db_Irisys_Json.dbo.tb_spe_webhook
SET UltimoRegistro = 0
WHERE 
    CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
     AND processingStatus = 0
    AND TipoJson = 'trip_info'
    AND idtransportadora IS NOT NULL;

-- Seleciona o último registro para 'trip_info' com base em Codigorota
WITH UltimaInformacaoRota AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (PARTITION BY Codigorota ORDER BY createdAt DESC) AS rn
    FROM 
        db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
    WHERE 
        CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
         AND processingStatus = 0
        AND TipoJson = 'trip_info'
        AND idtransportadora IS NOT NULL
        AND (Inprocessing = 0 OR Inprocessing IS NULL)
)
-- Atualiza o campo UltimoRegistro para '1' onde rn = 1 (último registro)
UPDATE db_Irisys_Json.dbo.tb_spe_webhook
SET UltimoRegistro = 1

FROM UltimaInformacaoRota u
WHERE db_Irisys_Json.dbo.tb_spe_webhook.id = u.id
AND u.rn = 1;



 
GO
