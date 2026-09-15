-- ============================================================
-- BASELINE: dbo.UspGetDetalhePacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDetalhePacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspGetDetalhePacotes]
(
    @IdPacoteParam     bigint       = NULL,
    @Marketplace       VARCHAR(50)  = NULL,
    @QuantidadeLote    int          = 250
)
AS

    INSERT INTO tb_tratativas_entregas_inclusas VALUES ( @IdPacoteParam );

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @QueueID bigint = NULL;
    DECLARE @Json varchar(max);
    DECLARE @IdTransportadora int;
    DECLARE @IdPacote bigint;
    DECLARE @DataColeta datetime;
    DECLARE @VerificaJson bit;
    DECLARE @Contador int = 0;

    DROP TABLE IF EXISTS #tabela;

    -- Reserva o lote na memória (não marca a coleta real ainda)
    SELECT TOP (@QuantidadeLote)
        dac_cd_coleta,
        dac_in_processado,
        dac_ds_contexto,
        dac_ds_contexto_json,
        dac_dh_coleta,
        dac_cd_transportadora,
        CASE
            WHEN LEFT(dac_ds_contexto_json, 1) IN ('{', '[')
             AND dac_ds_contexto_json <> '[]'
             AND dac_ds_contexto_json <> '{}'
            THEN 1
            ELSE 0
        END AS verifica_json
    INTO #tabela
    FROM db_Irisys_Json.dbo.tb_dra_coleta WITH (UPDLOCK, READPAST, ROWLOCK)

	    INNER JOIN dbo.tb_clientes AS cli WITH (NOLOCK)
        ON cli.cli_id_logistics = dac_cd_transportadora
       AND cli.cli_in_ativo = 1
    INNER JOIN dbo.tb_parametros AS prm WITH (NOLOCK)
        ON prm.prm_cod_cliente = cli.cli_cd_codigo_cliente
       AND prm.prm_nm_parametro = 'Habilitar Analise de PNR'
       AND prm.prm_ds_valor = 'true'

    WHERE dac_ds_tipo_coleta = 'PACKAGE_DETAIL_ML'
      AND dac_in_processado = 0
      AND dac_dh_referencia >= '20260401'
      --AND dac_cd_transportadora IN (
      --      1726310024, 678279205, 2130011770, 1950609251,
      --      472463006, 652375997, 643493085
      --)
    ORDER BY dac_cd_coleta;

    WHILE @Contador < @QuantidadeLote
    BEGIN

        SET @QueueID = NULL;
        SET @Json = NULL;
        SET @IdTransportadora = NULL;
        SET @IdPacote = NULL;
        SET @DataColeta = NULL;
        SET @VerificaJson = 0;

        -- CORREÇÃO: TOP 1 — antes atualizava TODAS as linhas pendentes do #tabela
        -- num único UPDATE, marcava ~250 como processado no temp e só 1 ia pra Load.
        -- testes
        ;WITH Q AS (
            SELECT TOP 1 *
            FROM #tabela
            WHERE dac_in_processado = 0
            ORDER BY dac_cd_coleta
        )
        UPDATE Q
        SET
            @QueueID            = dac_cd_coleta,
            @Json               = dac_ds_contexto_json,
            @IdTransportadora   = dac_cd_transportadora,
            @IdPacote           = TRY_CAST(dac_ds_contexto AS bigint),
            @DataColeta         = dac_dh_coleta,
            @VerificaJson       = verifica_json,
            dac_in_processado   = 1;

        IF @QueueID IS NULL
            BREAK;

        IF @IdPacote IS NOT NULL AND @IdTransportadora IS NOT NULL
        BEGIN
            IF @VerificaJson = 1
                EXEC UspLoadDetalhePacotes @Json, @IdPacote, @IdTransportadora, @DataColeta;
            ELSE
                -- JSON vazio: Load grava SEM_INFORMACAO
                EXEC UspLoadDetalhePacotes '{}', @IdPacote, @IdTransportadora, @DataColeta;
        END;

        SET @Contador = @Contador + 1;

    END;

    -- Só as linhas que passaram pelo loop (dac_in_processado = 1 no #tabela) viram processado = 1 na coleta real
    UPDATE c
    SET
        c.dac_in_processado    = 1,
        c.dac_dh_processamento = GETDATE()
    FROM db_Irisys_Json.dbo.tb_dra_coleta AS c
    INNER JOIN #tabela AS t
        ON t.dac_cd_coleta = c.dac_cd_coleta
    WHERE t.dac_in_processado = 1;

    IF (@IdPacoteParam IS NOT NULL)
    BEGIN
        MERGE tb_ml_pacotes AS TARGET
        USING tb_ml_detalhes_pacotes AS sourcer
            ON [target].IdTransportadora = sourcer.IdTransportadora
           AND [target].DataReferencia = sourcer.InicioPromessaEntrega
           AND [target].idpacote = sourcer.idpacote
           AND [target].excluido = 0
           AND [target].SubStatus <> 'transferred'
        WHEN MATCHED
             AND [target].StatusEntrega <> sourcer.SubStatus
             AND [target].idpacote = @IdPacoteParam
        THEN UPDATE SET
            [target].StatusEntrega = sourcer.SubStatus;

        INSERT INTO tb_tratativas_entregas
        (
            IdTransportadora, IdRota, idpacote, MotivoTratativa, Status,
            Observacao, imagem, DataCriacao, DataAtualizacao
        )
        SELECT
            IdTransportadora, IdRota, IdEntrega, NULL, StatusEntrega,
            NULL, NULL, GETDATE(), NULL
        FROM vw_pacotes
        WHERE IdEntrega = @IdpacoteParam;

        IF @Marketplace = 'SHOPEE'
        BEGIN
            INSERT INTO tb_tratativas_entregas (IdPacote)
            VALUES (@IdPacoteParam);
        END;
    END;
GO
