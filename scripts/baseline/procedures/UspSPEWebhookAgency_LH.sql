-- ============================================================
-- BASELINE: dbo.UspSPEWebhookAgency_LH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEWebhookAgency_LH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[UspSPEWebhookAgency_LH] as 






drop table if exists #base
select  top 500 * 
into #base 
from db_Irisys_Json.dbo.tb_spe_webhook with(nolock)
where 1=1
and cast(createdAt as date) =  CAST(getdate() as date) 
    AND ISJSON(jsondata) = 1

and JSON_VALUE(db_Irisys_Json.dbo.tb_spe_webhook.jsondata, '$.data.data_type') = '2'
--and id = 80701417


and processingStatus = 0


--select * from #base
--and idtransportadora is null
--and agency is null
--and cast(createdAt as date) = cast(getdate() as date) 
--and id = 74508860
DROP TABLE IF EXISTS #base2;

SELECT 
    JSON_VALUE(aux.jsondata, '$.data.agency_id') AS agency_id,
    'LH' TipoJsons,
    JSON_VALUE(aux.jsondata, '$.data.body.content_data.trip_number') AS rota,
    orders.spx_tn AS pacote,
    aux.id
INTO #base2
FROM #base AS aux
OUTER APPLY OPENJSON(aux.jsondata, '$.data.body.content_data.orders')
    WITH (
        spx_tn NVARCHAR(50) '$.spx_tn'
    ) AS orders
 
--JSON_VALUE(aux.jsondata, '$.data.data_type') = '2'
--CAST(createdAt as date) = CAST(getdate() as date)


--select * From #base2

	update   a
	set     
		agency = b.agency_id
		,idtransportadora = ISNULL(c1.cli_id_shopee, c2.cli_id_shopee)
		,TipoJson = b.TipoJsons
		,CodigoRota = b.rota
		,CodigoPacote = b.pacote

	from db_Irisys_Json.dbo.tb_spe_webhook as a with(nolock)
	inner join #base2 as b
	on a.id = b.id
	LEFT JOIN tb_clientes AS c1 ON c1.cli_agency_shpee = b.agency_id
	LEFT JOIN tb_clientes AS c2 ON c2.cli_agency_shopee_2 = b.agency_id;






-- Atualiza para '0' o campo UltimoRegistro para registros de 'order_update'
UPDATE db_Irisys_Json.dbo.tb_spe_webhook
SET UltimoRegistro = 0
WHERE 
   -- CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
    -- AND processingStatus = 0
     TipoJson = 'LH'
    AND idtransportadora IS NOT NULL
	and createdAt  >= cast(getdate() as date);


-- Seleciona o último registro para 'order_update' com base em Codigopacote
WITH UltimaInformacao AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (PARTITION BY Codigopacote,codigorota ORDER BY createdAt DESC) AS rn
    FROM 
        db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
    WHERE 
        CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
        -- AND processingStatus = 0
      and   TipoJson = 'LH'
        AND idtransportadora IS NOT NULL
        AND (Inprocessing = 0 OR Inprocessing IS NULL)
)
-- Atualiza o campo UltimoRegistro para '1' onde rn = 1 (último registro)
UPDATE db_Irisys_Json.dbo.tb_spe_webhook
SET UltimoRegistro = 1
FROM UltimaInformacao u
WHERE db_Irisys_Json.dbo.tb_spe_webhook.id = u.id
--AND u.rn = 1;

-- Atualiza para '0' o campo UltimoRegistro para registros de 'trip_info'
--UPDATE db_Irisys_Json.dbo.tb_spe_webhook
--SET UltimoRegistro = 0
--WHERE 
--    CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
--     AND processingStatus = 0
--    AND TipoJson = 'rota'
--    AND idtransportadora IS NOT NULL;

-- Seleciona o último registro para 'trip_info' com base em Codigorota
--WITH UltimaInformacaoRota AS (
--    SELECT 
--        id,
--        ROW_NUMBER() OVER (PARTITION BY Codigorota ORDER BY createdAt DESC) AS rn
--    FROM 
--        db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
--    WHERE 
--        CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)
--         AND processingStatus = 0
--        AND TipoJson = 'rota'
--        AND idtransportadora IS NOT NULL
--        AND (Inprocessing = 0 OR Inprocessing IS NULL)
--)
-- Atualiza o campo UltimoRegistro para '1' onde rn = 1 (último registro)
--UPDATE db_Irisys_Json.dbo.tb_spe_webhook
--SET UltimoRegistro = 1

--FROM UltimaInformacaoRota u
--WHERE db_Irisys_Json.dbo.tb_spe_webhook.id = u.id
--AND u.rn = 1;



GO
