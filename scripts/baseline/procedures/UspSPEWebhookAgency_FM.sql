-- ============================================================
-- BASELINE: dbo.UspSPEWebhookAgency_FM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEWebhookAgency_FM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPEWebhookAgency_FM] as 




	DROP TABLE IF EXISTS #base;



	SELECT  top 500 *
	INTO #base
	FROM db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
	WHERE 1 = 1
		AND processingStatus = 0
		AND idtransportadora IS NULL
		AND agency IS NULL
	and cast(createdAt as date) = cast(getdate() as date) 
			AND ISJSON(jsondata) = 1

	and JSON_VALUE(db_Irisys_Json.dbo.tb_spe_webhook.jsondata, '$.data.data_type') = '1'

	and processingStatus = 0;


	DROP TABLE IF EXISTS #base2;
	SELECT
		aux.id,
		-- Agency ID
		JSON_VALUE(aux.jsondata, '$.data.agency_id') AS agency_id,

		-- Tipo do JSON ? FM-Trip ou FM-Order
		JSON_VALUE(aux.jsondata, '$.data.body.content_data.business_name') AS TipoJsons,

		-- Código da rota (sempre presente nos dois tipos)
		JSON_VALUE(aux.jsondata, '$.data.body.content_data.data.trip_number') AS rota,

		-- Código do pacote ? só existe para FM-Order
		CASE 
			WHEN JSON_VALUE(aux.jsondata, '$.data.body.content_data.business_name') = 'FM-Order'
				 THEN JSON_VALUE(aux.jsondata, '$.data.body.content_data.data.order_number')
			ELSE NULL
		END AS pacote

	INTO #base2
	FROM #base AS aux
	WHERE ISJSON(aux.jsondata) = 1
	  AND JSON_VALUE(aux.jsondata, '$.data.body.content_data.business_name') IN ('FM-Trip', 'FM-Order');

UPDATE a
SET 
    agency = b.agency_id,
    idtransportadora = COALESCE(c1.cli_id_shopee,
                                c2.cli_id_shopee,
                                c3.cli_id_shopee,
                                c4.cli_id_shopee),
    TipoJson = TipoJsons,
    CodigoRota = b.rota,
    CodigoPacote = b.pacote
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



	-- Atualiza para '0' o campo UltimoRegistro para registros de 'order_update'
	UPDATE db_Irisys_Json.dbo.tb_spe_webhook
	SET UltimoRegistro = 0
	WHERE 
	 cast(createdAt as date) = cast(getdate() as date) 
		-- AND processingStatus = 0
	  and   TipoJson   IN ('FM-Trip')
		AND idtransportadora IS NOT NULL;

	-- Seleciona o último registro para 'order_update' com base em Codigopacote
	WITH UltimaInformacao AS (
		SELECT 
			id,
			ROW_NUMBER() OVER (PARTITION BY codigorota ORDER BY createdAt DESC) AS rn
		FROM 
			db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
		WHERE 
	 cast(createdAt as date) = cast(getdate() as date) 
			-- AND processingStatus = 0
	  and   TipoJson   IN ('FM-Trip')
			AND idtransportadora IS NOT NULL
			AND (Inprocessing = 0 OR Inprocessing IS NULL)
	)
	-- Atualiza o campo UltimoRegistro para '1' onde rn = 1 (último registro)
	UPDATE db_Irisys_Json.dbo.tb_spe_webhook
	SET UltimoRegistro = 1
	FROM UltimaInformacao u
	WHERE db_Irisys_Json.dbo.tb_spe_webhook.id = u.id
	and rn = 1










	
	-- Atualiza para '0' o campo UltimoRegistro para registros de 'order_update'
	UPDATE db_Irisys_Json.dbo.tb_spe_webhook
	SET UltimoRegistro = 0
	WHERE 
	 cast(createdAt as date) = cast(getdate() as date) 
		-- AND processingStatus = 0
	  and   TipoJson   IN ( 'FM-Order')
		AND idtransportadora IS NOT NULL;

	-- Seleciona o último registro para 'order_update' com base em Codigopacote
	WITH UltimaInformacao AS (
		SELECT 
			id,
			ROW_NUMBER() OVER (PARTITION BY Codigopacote,codigorota ORDER BY createdAt DESC) AS rn
		FROM 
			db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
		WHERE 
	 cast(createdAt as date) = cast(getdate() as date) 
			-- AND processingStatus = 0
	  and   TipoJson   IN ('FM-Order')
			AND idtransportadora IS NOT NULL
			AND (Inprocessing = 0 OR Inprocessing IS NULL)
	)
	-- Atualiza o campo UltimoRegistro para '1' onde rn = 1 (último registro)
	UPDATE db_Irisys_Json.dbo.tb_spe_webhook
	SET UltimoRegistro = 1
	FROM UltimaInformacao u
	WHERE db_Irisys_Json.dbo.tb_spe_webhook.id = u.id
and rn=1

--AND u.rn = 1;



GO
