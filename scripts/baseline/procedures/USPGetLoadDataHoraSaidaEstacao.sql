-- ============================================================
-- BASELINE: dbo.USPGetLoadDataHoraSaidaEstacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USPGetLoadDataHoraSaidaEstacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[USPGetLoadDataHoraSaidaEstacao]
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #RouteEvents;

    ;WITH CTE_Base AS
    (
        SELECT
              c.dac_cd_coleta
            , TRY_CAST(c.dac_ds_contexto AS BIGINT) AS IdRota
            , c.dac_cd_transportadora
            , c.dac_dh_referencia
            , dateadd(hour,-3,evt.DataHoraSaidaEstacao) as DataHoraSaidaEstacao
            , case when dateadd(hour,-3,evt.DataHoraSaidaEstacao) is null then 1 else 0 end as DataHoraSaidaEstacaoAusente
            , ROW_NUMBER() OVER
              (
                  PARTITION BY TRY_CAST(c.dac_ds_contexto AS BIGINT), c.dac_cd_transportadora
                  ORDER BY c.dac_dh_referencia DESC, c.dac_cd_coleta DESC
              ) AS rn
        FROM db_Irisys_Json.dbo.tb_dra_coleta c with(nolock)
        OUTER APPLY
        (              
            SELECT TOP 5000000
                  TRY_CAST(REPLACE(REPLACE(j.[date], 'T', ' '), 'Z', '') AS DATETIME) AS DataHoraSaidaEstacao
            FROM OPENJSON(c.dac_ds_contexto_json)
            WITH
            (
                  [name] VARCHAR(100) '$.name'
                , [date] VARCHAR(50)  '$.date'
            ) j
            WHERE j.[name] = 'service_center_exit'
        ) evt
        WHERE 1 = 1
          AND c.dac_ds_tipo_coleta = 'ML_LM_ROUTE_EVENTS'
          --and dac_ds_contexto = 347441270
          AND ISNULL(c.dac_in_processado, 0) = 0
          AND TRY_CAST(c.dac_ds_contexto AS BIGINT) IS NOT NULL
          --AND evt.DataHoraSaidaEstacao IS NOT NULL
    ),
    CTE_Final AS
    (
        SELECT TOP 5000000
              dac_cd_coleta
            , IdRota
            , dac_cd_transportadora
            , dac_dh_referencia
            , DataHoraSaidaEstacao
            , DataHoraSaidaEstacaoAusente
        FROM CTE_Base
        WHERE rn = 1
        ORDER BY dac_dh_referencia ASC, dac_cd_coleta ASC
    )
    SELECT
          dac_cd_coleta
        , IdRota
        , dac_cd_transportadora
        , dac_dh_referencia
        , DataHoraSaidaEstacao
        , DataHoraSaidaEstacaoAusente
    INTO #RouteEvents
    FROM CTE_Final cte
    join tb_clientes cli
        on cte.dac_cd_transportadora = cli.cli_id_logistics
        and cli.cli_in_ativo = 1
        and cli.cli_cd_codigo_cliente <> 7
    --left join tb_parametros pr
    --    on cli.cli_cd_codigo_cliente = pr.prm_cod_cliente
    --    and pr.prm_ds_categoria = 'Monitoramento Meli'
    --    and pr.prm_nm_parametro = 'Habilitar Reprocessamento de Eventos'
    --    and pr.prm_ds_valor = 'true'
        ;

    --alter table tb_ml_rotas add DataHoraSaidaEstacaoAusente int

    UPDATE r
       SET r.DataHoraSaidaEstacao = t.DataHoraSaidaEstacao
       ,r.DataHoraSaidaEstacaoAusente = t.DataHoraSaidaEstacaoAusente

    FROM dbo.tb_ml_rotas r
    INNER JOIN #RouteEvents t
        ON  r.IdRota = t.IdRota
        AND r.IdTransportadora = t.dac_cd_transportadora
    WHERE 1 = 1
      AND r.Excluido = 0
      AND r.statusrota <> 'planned';

    UPDATE c
       SET c.dac_in_processado    = 1
         , c.dac_dh_processamento = GETDATE()
    FROM db_Irisys_Json.dbo.tb_dra_coleta c
    INNER JOIN #RouteEvents t
        ON c.dac_cd_coleta = t.dac_cd_coleta
    INNER JOIN dbo.tb_ml_rotas r
        ON  r.IdRota = t.IdRota
        AND r.IdTransportadora = t.dac_cd_transportadora
    WHERE 1 = 1
      AND r.Excluido = 0
      AND r.statusrota <> 'planned';

END
GO
