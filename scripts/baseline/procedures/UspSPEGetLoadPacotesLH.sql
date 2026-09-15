-- ============================================================
-- BASELINE: dbo.UspSPEGetLoadPacotesLH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetLoadPacotesLH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPEGetLoadPacotesLH]
AS
BEGIN

    SET NOCOUNT ON;


    -------------------------------------------------------------------------
    -- 1. WEBHOOKS LH PENDENTES
    --    Origem: PRODUÇÃO
    -------------------------------------------------------------------------
    DROP TABLE IF EXISTS #aux;

    SELECT *
    INTO #aux
    FROM [db_Irisys_Json].[dbo].[tb_spe_webhook] WITH (NOLOCK)
    WHERE CAST(createdAt AS DATE) = CAST(GETDATE() AS date)
	and	TipoJson = 'LH'
      AND IdTransportadora IS NOT NULL
      AND ProcessingStatus = 0;


    -------------------------------------------------------------------------
    -- 2. EXTRAÇÃO DOS PACOTES + ChegadaNaEstacao
    --
    -- ChegadaNaEstacao:
    --   1) pega a última estação do trip_path
    --      pelo maior station_sequence
    --
    --   2) procura essa station_id dentro do trip_info
    --
    --   3) usa o campo ata dessa estação
    -------------------------------------------------------------------------
    DROP TABLE IF EXISTS #pacote_atualizado;

    SELECT DISTINCT

        clientes.cli_id_shopee AS IdTransportadora,

        JSON_VALUE(
            aux.JsonData,
            '$.data.body.content_data.trip_number'
        ) AS CodigoRota,

        orders.spx_tn AS CodigoPacote,

        orders.destination_station AS StationId,


        ---------------------------------------------------------------------
        -- NOVO CAMPO ChegadaNaEstacao
        ---------------------------------------------------------------------
        CASE
            WHEN ATAInfo.ata > 0
            THEN CAST(
                DATEADD(
                    SECOND,
                    ATAInfo.ata,
                    CAST('1970-01-01' AS DATETIME2)
                )
                AT TIME ZONE 'UTC'
                AT TIME ZONE 'E. South America Standard Time'
                AS DATETIME2(0)
            )
            ELSE NULL
        END AS ChegadaNaEstacao,


        aux.Id

    INTO #pacote_atualizado

    FROM #aux AS aux


    -------------------------------------------------------------------------
    -- PACOTES
    -------------------------------------------------------------------------
    OUTER APPLY OPENJSON
    (
        aux.JsonData,
        '$.data.body.content_data.orders'
    )
    WITH
    (
        spx_tn              NVARCHAR(50) '$.spx_tn',
        destination_station INT          '$.destination_station'
    ) AS orders


    -------------------------------------------------------------------------
    -- ÚLTIMA ESTAÇÃO DO TRIP_PATH
    -------------------------------------------------------------------------
    OUTER APPLY
    (
        SELECT TOP 1
            TP.station_id

        FROM OPENJSON
        (
            aux.JsonData,
            '$.data.body.content_data.trip_path'
        )
        WITH
        (
            station_id       INT '$.station_id',
            station_sequence INT '$.station_sequence'
        ) AS TP

        ORDER BY
            TP.station_sequence DESC

    ) AS UltimaEstacao


    -------------------------------------------------------------------------
    -- ChegadaNaEstacao DA ÚLTIMA ESTAÇÃO
    -------------------------------------------------------------------------
    OUTER APPLY
    (
        SELECT TOP 1
            TI.ata

        FROM OPENJSON
        (
            aux.JsonData,
            '$.data.body.content_data.trip_info'
        )
        WITH
        (
            station_id INT    '$.station_id',
            ata        BIGINT '$.ata'
        ) AS TI

        WHERE TI.station_id = UltimaEstacao.station_id

    ) AS ATAInfo


    -------------------------------------------------------------------------
    -- IDENTIFICA TRANSPORTADORA
    -------------------------------------------------------------------------
    INNER JOIN dbo.tb_clientes AS clientes
        ON
        (
               JSON_VALUE(aux.JsonData, '$.data.agency_id')
                    = clientes.cli_agency_shpee

            OR JSON_VALUE(aux.JsonData, '$.data.agency_id')
                    = clientes.cli_agency_shopee_2
        )

    WHERE orders.spx_tn IS NOT NULL
      AND LTRIM(RTRIM(orders.spx_tn)) <> '';


    -------------------------------------------------------------------------
    -- 3. REMOVE DUPLICIDADE DO LOTE
    --    MESMO PACOTE + ROTA + TRANSPORTADORA
    --    FICA O WEBHOOK DE MAIOR ID
    -------------------------------------------------------------------------
    ;WITH Duplicatas AS
    (
        SELECT
            *,
            ROW_NUMBER() OVER
            (
                PARTITION BY
                    IdTransportadora,
                    CodigoRota,
                    CodigoPacote

                ORDER BY Id DESC
            ) AS rn

        FROM #pacote_atualizado
    )

    DELETE FROM Duplicatas
    WHERE rn > 1;


    -------------------------------------------------------------------------
    -- 4. REMOVE ROTAS DE TESTE
    -------------------------------------------------------------------------
    DELETE FROM #pacote_atualizado
    WHERE CodigoRota LIKE '%teste%';


    -------------------------------------------------------------------------
    -- 5. MERGE NA TB_SPE_PACOTES_LH
    -------------------------------------------------------------------------
    MERGE dbo.tb_spe_pacotes_lh AS TARGET

    USING #pacote_atualizado AS SOURCE

        ON  TARGET.IdTransportadora = SOURCE.IdTransportadora
        AND TARGET.CodigoRota       = SOURCE.CodigoRota
        AND TARGET.CodigoPacote     = SOURCE.CodigoPacote


    -------------------------------------------------------------------------
    -- PACOTE JÁ EXISTE
    -------------------------------------------------------------------------
    WHEN MATCHED THEN

        UPDATE SET

            TARGET.CodigoPacote     = SOURCE.CodigoPacote,
            TARGET.CodigoRota       = SOURCE.CodigoRota,
            TARGET.StationId        = SOURCE.StationId,
            TARGET.IdTransportadora = SOURCE.IdTransportadora,

            -------------------------------------------------------------
            -- NÃO APAGA ChegadaNaEstacao EXISTENTE CASO O NOVO JSON VENHA SEM
            -------------------------------------------------------------
            TARGET.ChegadaNaEstacao =
                ISNULL(
                    SOURCE.ChegadaNaEstacao,
                    TARGET.ChegadaNaEstacao
                )


    -------------------------------------------------------------------------
    -- PACOTE NOVO
    -------------------------------------------------------------------------
    WHEN NOT MATCHED BY TARGET THEN

        INSERT
        (
            IdTransportadora,
            CodigoRota,
            CodigoPacote,
            StationId,
            ChegadaNaEstacao
        )

        VALUES
        (
            SOURCE.IdTransportadora,
            SOURCE.CodigoRota,
            SOURCE.CodigoPacote,
            SOURCE.StationId,
            SOURCE.ChegadaNaEstacao
        );


    -------------------------------------------------------------------------
    -- 6. MARCA WEBHOOK COMO PROCESSADO
    --    ATUALIZA A ORIGEM DE PRODUÇÃO
    -------------------------------------------------------------------------
    UPDATE webhook

    SET
        webhook.ProcessingDatetime = GETDATE(),
        webhook.ProcessingStatus   = 1

    FROM [db_Irisys_Json].[dbo].[tb_spe_webhook] AS webhook

    INNER JOIN #aux AS aux
        ON aux.Id = webhook.Id;


END
GO
