-- ============================================================
-- BASELINE: dbo.UspLoadTreinamentosLooker
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadTreinamentosLooker]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[UspLoadTreinamentosLooker]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF OBJECT_ID('tempdb..#source_dedup') IS NOT NULL
        DROP TABLE #source_dedup;

    ;WITH source_base AS
    (
        SELECT
              trein.MELI_ID
            , trein.DRIVER_ID
            , trein.CARRIER
            , trein.MILLA
            , trein.SVC
            , trein.PLACA
            , trein.ANTIGUEDAD
            , trein.DRIVER_STATUS
            , trein.COURSE_NAME
            , trein.DECRIPTION
            , trein.COURSE_PROGRESS
            , trein.SEMANA
            , trein.[DATA DO TREINAMENTO]
            , trein.[ULTIMA ROTA]
            , trein.Aderência
            , trein.CodigoCliente
            , trein.filename
            , trein.[timestamp]
            , trein.pk_composta
            , trein.FACILITY
            , cli.cli_id_logistics AS cd_transportadora
            , cli.cli_ds_nome      AS nome_transportadora
            , mot.Nome             AS nome_motorista
            , ROW_NUMBER() OVER
              (
                  PARTITION BY
                      trein.CodigoCliente,
                      trein.DRIVER_ID,
                      trein.COURSE_NAME,
                      trein.SVC
                  ORDER BY
                      trein.[timestamp] DESC,
                      trein.filename DESC
              ) AS rn
        FROM dbo.stg_looker_treinamentos_geral trein
        LEFT JOIN dbo.tb_clientes cli
            ON trein.CodigoCliente = cli.cli_cd_codigo_cliente
        LEFT JOIN dbo.tb_ml_motoristas mot
            ON trein.DRIVER_ID = mot.IdMotorista
        WHERE cli.cli_id_logistics IS NOT NULL
    )
    SELECT
          MELI_ID
        , DRIVER_ID
        , CARRIER
        , MILLA
        , SVC
        , PLACA
        , ANTIGUEDAD
        , DRIVER_STATUS
        , COURSE_NAME
        , DECRIPTION
        , COURSE_PROGRESS
        , SEMANA
        , [DATA DO TREINAMENTO]
        , [ULTIMA ROTA]
        , Aderência
        , CodigoCliente
        , filename
        , [timestamp]
        , pk_composta
        , FACILITY
        , cd_transportadora
        , nome_transportadora
        , nome_motorista
    INTO #source_dedup
    FROM source_base
    WHERE rn = 1;

    -- Atualiza existentes (nao atualiza COMPLETE)
    UPDATE tgt
       SET tgt.MELI_ID               = src.MELI_ID
         , tgt.DRIVER_ID             = src.DRIVER_ID
         , tgt.CARRIER               = src.CARRIER
         , tgt.MILLA                 = src.MILLA
         , tgt.SVC                   = src.SVC
         , tgt.PLACA                 = src.PLACA
         , tgt.ANTIGUEDAD            = src.ANTIGUEDAD
         , tgt.DRIVER_STATUS         = src.DRIVER_STATUS
         , tgt.COURSE_NAME           = src.COURSE_NAME
         , tgt.DECRIPTION            = src.DECRIPTION
         , tgt.COURSE_PROGRESS       = src.COURSE_PROGRESS
         , tgt.SEMANA                = src.SEMANA
         , tgt.[DATA DO TREINAMENTO] = src.[DATA DO TREINAMENTO]
         , tgt.[ULTIMA ROTA]         = src.[ULTIMA ROTA]
         , tgt.Aderência             = src.Aderência
         , tgt.CodigoCliente         = src.CodigoCliente
         , tgt.filename              = src.filename
         , tgt.[timestamp]           = src.[timestamp]
         , tgt.pk_composta           = src.pk_composta
         , tgt.FACILITY              = src.FACILITY
         , tgt.cd_transportadora     = src.cd_transportadora
         , tgt.nome_transportadora   = src.nome_transportadora
         , tgt.nome_motorista        = src.nome_motorista
    FROM dbo.tb_looker_treinamentos_geral tgt
    INNER JOIN #source_dedup src
        ON  tgt.CodigoCliente = src.CodigoCliente
        AND tgt.DRIVER_ID     = src.DRIVER_ID
        AND tgt.COURSE_NAME   = src.COURSE_NAME
        AND (tgt.SVC           = src.SVC           OR (tgt.SVC           IS NULL AND src.SVC           IS NULL))

   WHERE ISNULL(tgt.COURSE_PROGRESS, '') <> 'COMPLETE'
      AND ISNULL(src.[timestamp], '19000101') > ISNULL(tgt.[timestamp], '19000101');

    -- Insere somente novos
    INSERT INTO dbo.tb_looker_treinamentos_geral
    (
          MELI_ID
        , DRIVER_ID
        , CARRIER
        , MILLA
        , SVC
        , PLACA
        , ANTIGUEDAD
        , DRIVER_STATUS
        , COURSE_NAME
        , DECRIPTION
        , COURSE_PROGRESS
        , SEMANA
        , [DATA DO TREINAMENTO]
        , [ULTIMA ROTA]
        , Aderência
        , CodigoCliente
        , filename
        , [timestamp]
        , pk_composta
        , FACILITY
        , cd_transportadora
        , nome_transportadora
        , nome_motorista
    )
    SELECT
          src.MELI_ID
        , src.DRIVER_ID
        , src.CARRIER
        , src.MILLA
        , src.SVC
        , src.PLACA
        , src.ANTIGUEDAD
        , src.DRIVER_STATUS
        , src.COURSE_NAME
        , src.DECRIPTION
        , src.COURSE_PROGRESS
        , src.SEMANA
        , src.[DATA DO TREINAMENTO]
        , src.[ULTIMA ROTA]
        , src.Aderência
        , src.CodigoCliente
        , src.filename
        , src.[timestamp]
        , src.pk_composta
        , src.FACILITY
        , src.cd_transportadora
        , src.nome_transportadora
        , src.nome_motorista
    FROM #source_dedup src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.tb_looker_treinamentos_geral tgt
        WHERE tgt.CodigoCliente = src.CodigoCliente
          AND tgt.DRIVER_ID     = src.DRIVER_ID
          AND tgt.COURSE_NAME   = src.COURSE_NAME
          AND (tgt.SVC = src.SVC OR (tgt.SVC IS NULL AND src.SVC IS NULL))
    );
END;
GO
