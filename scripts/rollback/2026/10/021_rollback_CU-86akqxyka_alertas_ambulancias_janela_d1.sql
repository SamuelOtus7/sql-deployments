/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqxyka
  Autor        : Devin
  Data         : 2026-10-01
  DescriÃ§Ã£o    : Restaura a definicao vigente de
                 dbo.vw_pbi_mon_alertas_processos_calc (versao de 29/09/2026,
                 extraida do PROD via OBJECT_DEFINITION): LOOKER_AMBULANCIAS
                 volta a exigir rotas/carga de HOJE e perde a tolerancia D-1
                 compartilhada com LOOKER_PNR.
  Forward ref  : scripts/forward/2026/10/021_forward_CU-86akqxyka_alertas_ambulancias_janela_d1.sql
  Objetos      : dbo.vw_pbi_mon_alertas_processos_calc (CREATE OR ALTER VIEW)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_pbi_mon_alertas_processos_calc'))
        THROW 50022, 'View dbo.vw_pbi_mon_alertas_processos_calc nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_pbi_mon_alertas_processos_calc]

AS

WITH Ref AS

(

    SELECT

        CAST(GETDATE() AS DATE) AS dt_hoje,

        CAST(GETDATE() AS TIME(0)) AS hr_agora

),

ClientesCatalogo AS

(

    SELECT

        c.cli_id_logistics,

        c.cli_id_shopee,

        c.cli_ds_nome,

        c.cli_cd_codigo_cliente,

        c.cli_in_ativo,

        c.cli_in_excluido,

        CASE

            WHEN pr_dashboard.prm_ds_valor = N'true'

             AND ISNULL(pr_dashboard.prm_in_ativo, 1) = 1

             AND ISNULL(pr_dashboard.prm_in_excluido, 0) = 0

            THEN CAST(1 AS BIT)

            ELSE CAST(0 AS BIT)

        END AS in_dashboard_alarmes_habilitado

    FROM dbo.tb_clientes AS c WITH (NOLOCK)

    LEFT JOIN dbo.tb_parametros AS pr_dashboard WITH (NOLOCK)

        ON pr_dashboard.prm_cod_cliente = c.cli_cd_codigo_cliente

       AND pr_dashboard.prm_ds_categoria = N'Alertas'

       AND pr_dashboard.prm_nm_parametro = N'Habilitar Dashboard Alarmes'

       AND ISNULL(pr_dashboard.prm_in_ativo, 1) = 1

       AND ISNULL(pr_dashboard.prm_in_excluido, 0) = 0

    WHERE c.cli_cd_codigo_cliente <> 7

),

MetricasOrigem AS

(

    /* ML_ROTAS */

    SELECT

        N'ML_ROTAS' AS processo_codigo,

        TRY_CAST(o.cmt_cd_transportadora AS INT) AS id_transportadora,

        MAX(o.cmt_dh_escrita) AS dh_ultimo_evento_origem,

        COUNT(*) AS qt_registros_origem,

        SUM(CASE WHEN o.cmt_in_processado = 0 THEN 1 ELSE 0 END) AS qt_fila_pendente,

        MIN(CASE WHEN o.cmt_in_processado = 0 THEN o.cmt_dh_escrita END) AS dh_fila_mais_antiga

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_ml_coleta_totalizador AS o WITH (NOLOCK)

    WHERE CAST(o.cmt_dh_referencia AS DATE) = r.dt_hoje

    GROUP BY TRY_CAST(o.cmt_cd_transportadora AS INT)



    UNION ALL



    /* ML_PACOTES */

    SELECT

        N'ML_PACOTES',

        TRY_CAST(o.cmr_cd_transportadora AS INT),

        MAX(o.cmr_dh_escrita),

        COUNT(*),

        SUM(CASE WHEN o.cmr_in_processado = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.cmr_in_processado = 0 THEN o.cmr_dh_escrita END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_ml_coleta_rotas AS o WITH (NOLOCK)

    WHERE CAST(o.cmr_dh_referencia AS DATE) = r.dt_hoje

    GROUP BY TRY_CAST(o.cmr_cd_transportadora AS INT)



    UNION ALL



    /* ML_FM_ROTAS */

    SELECT

        N'ML_FM_ROTAS',

        TRY_CAST(o.dac_cd_transportadora AS INT),

        MAX(o.dac_dh_escrita),

        COUNT(*),

        SUM(CASE WHEN o.dac_in_processado = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.dac_in_processado = 0 THEN o.dac_dh_escrita END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_dra_coleta AS o WITH (NOLOCK)

    WHERE CAST(o.dac_dh_referencia AS DATE) = r.dt_hoje

      AND o.dac_ds_tipo_coleta = N'ML_FM_ROUTES'

    GROUP BY TRY_CAST(o.dac_cd_transportadora AS INT)



    UNION ALL



    /* ML_FM_PARADAS */

    SELECT

        N'ML_FM_PARADAS',

        TRY_CAST(o.dac_cd_transportadora AS INT),

        MAX(o.dac_dh_escrita),

        COUNT(*),

        SUM(CASE WHEN o.dac_in_processado = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.dac_in_processado = 0 THEN o.dac_dh_escrita END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_dra_coleta AS o WITH (NOLOCK)

    WHERE CAST(o.dac_dh_referencia AS DATE) = r.dt_hoje

      AND o.dac_ds_tipo_coleta = N'ML_FM_ROUTE'

    GROUP BY TRY_CAST(o.dac_cd_transportadora AS INT)



    UNION ALL



    /* ML_LH_ROTAS */

    SELECT

        N'ML_LH_ROTAS',

        TRY_CAST(o.dac_cd_transportadora AS INT),

        MAX(o.dac_dh_escrita),

        COUNT(*),

        SUM(CASE WHEN o.dac_in_processado = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.dac_in_processado = 0 THEN o.dac_dh_escrita END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_dra_coleta AS o WITH (NOLOCK)

    WHERE CAST(o.dac_dh_referencia AS DATE) = r.dt_hoje

      AND o.dac_ds_tipo_coleta = N'ML_LH_ROUTES'

    GROUP BY TRY_CAST(o.dac_cd_transportadora AS INT)



    UNION ALL



    /* ML_MOTORISTAS */

    SELECT

        N'ML_MOTORISTAS',

        TRY_CAST(o.dac_cd_transportadora AS INT),

        MAX(o.dac_dh_escrita),

        COUNT(*),

        SUM(CASE WHEN o.dac_in_processado = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.dac_in_processado = 0 THEN o.dac_dh_escrita END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_dra_coleta AS o WITH (NOLOCK)

    WHERE CAST(o.dac_dh_referencia AS DATE) = r.dt_hoje

      AND o.dac_ds_tipo_coleta = N'DRIVER_ML'

    GROUP BY TRY_CAST(o.dac_cd_transportadora AS INT)



    UNION ALL



    /* ML_LM_ROUTE_EVENTS */

    SELECT

        N'ML_LM_ROUTE_EVENTS',

        TRY_CAST(o.dac_cd_transportadora AS INT),

        MAX(o.dac_dh_escrita),

        COUNT(*),

        SUM(CASE WHEN o.dac_in_processado = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.dac_in_processado = 0 THEN o.dac_dh_escrita END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_dra_coleta AS o WITH (NOLOCK)

    WHERE CAST(o.dac_dh_referencia AS DATE) = r.dt_hoje

      AND o.dac_ds_tipo_coleta = N'ML_LM_ROUTE_EVENTS'

    GROUP BY TRY_CAST(o.dac_cd_transportadora AS INT)



    UNION ALL



    /* SPE_ROTAS_V5_TRIP */

    SELECT

        N'SPE_ROTAS_V5_TRIP',

        o.idtransportadora,

        MAX(o.createdAt),

        COUNT(*),

        SUM(CASE WHEN o.processingStatus = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.processingStatus = 0 THEN o.createdAt END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_spe_webhook AS o WITH (NOLOCK)

    WHERE CAST(o.createdAt AS DATE) = r.dt_hoje

      AND o.TipoJson = N'trip_info'

      AND o.idtransportadora IS NOT NULL

    GROUP BY o.idtransportadora



    UNION ALL



    /* SPE_ROTAS_V5_FM */

    SELECT

        N'SPE_ROTAS_V5_FM',

        o.idtransportadora,

        MAX(o.createdAt),

        COUNT(*),

        SUM(CASE WHEN o.processingStatus = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.processingStatus = 0 THEN o.createdAt END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_spe_webhook AS o WITH (NOLOCK)

    WHERE CAST(o.createdAt AS DATE) = r.dt_hoje

      AND o.TipoJson = N'FM-TRIP'

      AND o.idtransportadora IS NOT NULL

    GROUP BY o.idtransportadora



    UNION ALL



    /* SPE_ROTAS_V5_LH */

    SELECT

        N'SPE_ROTAS_V5_LH',

        o.idtransportadora,

        MAX(o.createdAt),

        COUNT(*),

        SUM(CASE WHEN o.processingStatus = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.processingStatus = 0 THEN o.createdAt END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_spe_webhook AS o WITH (NOLOCK)

    WHERE CAST(o.createdAt AS DATE) = r.dt_hoje

      AND o.TipoJson = N'LH'

      AND o.idtransportadora IS NOT NULL

    GROUP BY o.idtransportadora



    UNION ALL



    /* SPE_PACOTES_V5 */

    SELECT

        N'SPE_PACOTES_V5',

        o.idtransportadora,

        MAX(o.createdAt),

        COUNT(*),

        SUM(CASE WHEN o.processingStatus = 0 THEN 1 ELSE 0 END),

        MIN(CASE WHEN o.processingStatus = 0 THEN o.createdAt END)

    FROM Ref AS r

    CROSS JOIN db_Irisys_Json.dbo.tb_spe_webhook AS o WITH (NOLOCK)

    WHERE CAST(o.createdAt AS DATE) = r.dt_hoje

      AND o.TipoJson = N'order_update'

      AND o.idtransportadora IS NOT NULL

    GROUP BY o.idtransportadora



    UNION ALL



    /* LOOKER_RTT - staging */

    SELECT

        N'LOOKER_RTT',

        c.cli_id_logistics,

        MAX(s.DataExtracao),

        COUNT(*),

        CAST(0 AS BIGINT),

        CAST(NULL AS DATETIME2(3))

    FROM Ref AS r

    CROSS JOIN dbo.tb_stg_looker_rtt AS s WITH (NOLOCK)

    INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)

        ON c.cli_cd_codigo_cliente = s.CodigoCliente

    WHERE CAST(s.DataExtracao AS DATE) = r.dt_hoje

    GROUP BY c.cli_id_logistics



    UNION ALL



    /* LOOKER_TREINAMENTOS - staging */

    SELECT

        N'LOOKER_TREINAMENTOS',

        s.cd_transportadora,

        MAX(s.timestamp),

        COUNT(*),

        CAST(0 AS BIGINT),

        CAST(NULL AS DATETIME2(3))

    FROM Ref AS r

    CROSS JOIN dbo.stg_looker_treinamentos_geral AS s WITH (NOLOCK)

    WHERE CAST(s.timestamp AS DATE) = r.dt_hoje

      AND s.cd_transportadora IS NOT NULL

    GROUP BY s.cd_transportadora



    UNION ALL



    /* LOOKER_AMBULANCIAS */

    SELECT

        N'LOOKER_AMBULANCIAS',

        d.amb_cd_transportadora,

        MAX(d.amb_data),

        COUNT(*),

        CAST(0 AS BIGINT),

        CAST(NULL AS DATETIME2(3))

    FROM Ref AS r

    CROSS JOIN dbo.tb_looker_ambulancias AS d WITH (NOLOCK)

    WHERE d.amb_data = r.dt_hoje

    GROUP BY d.amb_cd_transportadora



    UNION ALL



    /* LOOKER_PNR - staging (snapshot diario da coleta BSC) */

    SELECT

        N'LOOKER_PNR',

        c.cli_id_logistics,

        MAX(s.DataExtracao),

        COUNT(*),

        CAST(0 AS BIGINT),

        CAST(NULL AS DATETIME2(3))

    FROM Ref AS r

    CROSS JOIN dbo.tb_looker_pnr AS s WITH (NOLOCK)

    INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)

        ON c.cli_cd_codigo_cliente = s.CodigoCliente

    WHERE s.DataExtracao >= DATEADD(DAY, -1, r.dt_hoje)

    GROUP BY c.cli_id_logistics

),

MetricasDestino AS

(

    /* ML_ROTAS */

    SELECT

        N'ML_ROTAS' AS processo_codigo,

        d.IdTransportadora AS id_transportadora,

        MAX(d.DataAtualizacao) AS dh_ultimo_evento_destino,

        COUNT(*) AS qt_registros_destino,

        CAST(0 AS BIGINT) AS qt_destino_nulos

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_rotas AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* ML_PACOTES */

    SELECT

        N'ML_PACOTES',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_pacotes AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* ML_FM_ROTAS */

    SELECT

        N'ML_FM_ROTAS',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_fm_rotas AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* ML_FM_PARADAS */

    SELECT

        N'ML_FM_PARADAS',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_fm_paradas AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* ML_LH_ROTAS */

    SELECT

        N'ML_LH_ROTAS',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_lh_rotas AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* ML_MOTORISTAS */

    SELECT

        N'ML_MOTORISTAS',

        d.IdTransportadora,

        MAX(d.DataColeta),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_motoristas AS d WITH (NOLOCK)

    WHERE CAST(d.DataColeta AS DATE) = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* ML_LM_ROUTE_EVENTS */

    SELECT

        N'ML_LM_ROUTE_EVENTS',

        d.IdTransportadora,

        MAX(d.DataHoraSaidaEstacao),

        COUNT(*),

        SUM(CASE

            WHEN d.DataHoraSaidaEstacao IS NULL

             AND (d.DataHoraSaidaEstacaoAusente = 0 OR d.DataHoraSaidaEstacaoAusente IS NULL)

            THEN 1 ELSE 0

        END)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_rotas AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

      AND d.Excluido = 0

      AND d.StatusRota <> N'planned'

    GROUP BY d.IdTransportadora



    UNION ALL



    /* SPE_ROTAS_V5 (trip, FM, LH compartilham destino) */

    SELECT

        N'SPE_ROTAS_V5_TRIP',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    SELECT

        N'SPE_ROTAS_V5_FM',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    SELECT

        N'SPE_ROTAS_V5_LH',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* SPE_PACOTES_V5 */

    SELECT

        N'SPE_PACOTES_V5',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_spe_pacotes_v5 AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* LOOKER_RTT - destino via tb_ml_bsc_rtt + tb_ml_rotas (excecao) */

    SELECT

        N'LOOKER_RTT',

        rot.IdTransportadora,

        MAX(b.DataInsert),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_bsc_rtt AS b WITH (NOLOCK)

    INNER JOIN dbo.tb_ml_rotas AS rot WITH (NOLOCK)

        ON rot.IdRota = b.IdRota

    WHERE CAST(b.DataInsert AS DATE) = r.dt_hoje

      AND rot.StatusRota <> N'planned'

      AND rot.Excluido = 0

    GROUP BY rot.IdTransportadora



    UNION ALL



    /* LOOKER_TREINAMENTOS */

    SELECT

        N'LOOKER_TREINAMENTOS',

        d.cd_transportadora,

        MAX(d.timestamp),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_looker_treinamentos_geral AS d WITH (NOLOCK)

    WHERE CAST(d.timestamp AS DATE) = r.dt_hoje

    GROUP BY d.cd_transportadora



    UNION ALL



    /* LOOKER_AMBULANCIAS */

    SELECT

        N'LOOKER_AMBULANCIAS',

        d.amb_cd_transportadora,

        MAX(d.amb_data_etl),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_looker_ambulancias AS d WITH (NOLOCK)

    WHERE CAST(d.amb_data_etl AS DATE) = r.dt_hoje

    GROUP BY d.amb_cd_transportadora



    UNION ALL



    /* LOOKER_PNR - destino tb_pnr_bsc (freshness por pnr_dh_criacao) */

    SELECT

        N'LOOKER_PNR',

        c.cli_id_logistics,

        MAX(d.pnr_dh_criacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_pnr_bsc AS d WITH (NOLOCK)

    INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)

        ON c.cli_cd_codigo_cliente = d.pnr_cd_cliente

    WHERE CAST(d.pnr_dh_criacao AS DATE) >= DATEADD(DAY, -1, r.dt_hoje)

    GROUP BY c.cli_id_logistics



    UNION ALL



    /* LOOKER_PARADAS - destino tb_ml_bsc_paradas (sem coluna de data; cliente/freshness via tb_ml_rotas) */

    SELECT

        N'LOOKER_PARADAS',

        rot.IdTransportadora,

        MAX(rot.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_bsc_paradas AS p WITH (NOLOCK)

    INNER JOIN dbo.tb_ml_rotas AS rot WITH (NOLOCK)

        ON rot.IdRota = p.IdRota

    WHERE CAST(rot.DataReferencia AS DATE) >= DATEADD(DAY, -1, r.dt_hoje)

      AND rot.StatusRota <> N'planned'

      AND rot.Excluido = 0

    GROUP BY rot.IdTransportadora



    UNION ALL



    /* ML_INDICADORES_ROTA */

    SELECT

        N'ML_INDICADORES_ROTA',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_rotas AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

      AND d.Excluido = 0

    GROUP BY d.IdTransportadora



    UNION ALL



    /* ML_CIDADE_DISTANTE_DIA */

    SELECT

        N'ML_CIDADE_DISTANTE_DIA',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        SUM(CASE

            WHEN d.CidadeDistante IS NULL OR LTRIM(RTRIM(d.CidadeDistante)) = N'' THEN 1

            ELSE 0

        END)

    FROM Ref AS r

    CROSS JOIN dbo.tb_ml_rotas AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

      AND d.Excluido = 0

    GROUP BY d.IdTransportadora



    UNION ALL



    /* SPE_INDICADORES_V5 */

    SELECT

        N'SPE_INDICADORES_V5',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* SPE_CIDADE_DISTANTE_DIA */

    SELECT

        N'SPE_CIDADE_DISTANTE_DIA',

        d.IdTransportadora,

        MAX(d.DataAtualizacao),

        COUNT(*),

        SUM(CASE

            WHEN d.CidadeDistante IS NULL OR LTRIM(RTRIM(d.CidadeDistante)) = N'' THEN 1

            ELSE 0

        END)

    FROM Ref AS r

    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)

    WHERE d.DataReferencia = r.dt_hoje

    GROUP BY d.IdTransportadora



    UNION ALL



    /* DRA_HISTORICO_ROTAS â€” cobertura de ontem por transportadora */

    SELECT

        N'DRA_HISTORICO_ROTAS',

        d.dhr_cd_cliente,

        MAX(d.dhr_dh_coleta),

        COUNT(*),

        CAST(0 AS BIGINT)

    FROM Ref AS r

    CROSS JOIN dbo.tb_dra_historico_rotas AS d WITH (NOLOCK)

    WHERE d.dhr_dt_data = DATEADD(DAY, -1, r.dt_hoje)

    GROUP BY d.dhr_cd_cliente



    UNION ALL



    /* ML_PROCESSAMENTO_KM_ROTAS â€” rotas de hoje sem km apos 1h */

    SELECT

        N'ML_PROCESSAMENTO_KM_ROTAS',

        r.IdTransportadora,

        MAX(km.dateCreated),

        COUNT(*),

        SUM(CASE

            WHEN km.id IS NULL

             AND r.DataHoraColeta < DATEADD(HOUR, -1, GETDATE())

            THEN 1 ELSE 0

        END)

    FROM Ref AS ref

    CROSS JOIN dbo.tb_ml_rotas AS r WITH (NOLOCK)

    LEFT JOIN dbo.tb_ml_processamento_km_rotas AS km WITH (NOLOCK)

        ON km.idRota = r.IdRota

    WHERE r.DataReferencia = ref.dt_hoje

      AND r.Excluido = 0

      AND r.StatusRota <> N'planned'

      AND r.DataHoraColeta IS NOT NULL

    GROUP BY r.IdTransportadora

),

Base AS

(

    SELECT

        p.processo_id,

        p.processo_codigo,

        p.processo_nome,

        p.tabela_destino,

        p.plataforma,

        p.job_nome,

        p.proc_orquestrador,

        p.proc_carga,

        p.tipo_regra,

        p.in_origem_irisys_json,

        ISNULL(p.in_origem_obrigatoria, 1) AS in_origem_obrigatoria,

        p.sla_minutos,

        p.sla_label,

        p.nr_tolerancia_fila,

        p.destino_regra,

        p.parametro_habilita,

        p.in_ativo,

        p.hr_validacao,

        p.ds_acao_origem,

        p.ds_acao_fila,

        p.ds_acao_destino,

        p.ds_acao_job,

        p.ds_acao_origem_sem_dados,

        p.ds_acao_origem_parada,

        p.ds_acao_destino_sem_carga,

        p.ds_acao_destino_desatualizado,

        p.ds_acao_destino_data_antiga,

        p.ds_acao_destino_nulos,

        p.ds_acao_job_erro,

        p.ds_acao_job_travado,

        CASE p.id_cliente_campo

            WHEN N'cli_id_logistics' THEN cv.cli_id_logistics

            WHEN N'cli_id_shopee' THEN cv.cli_id_shopee

        END AS id_transportadora,

        cv.cli_ds_nome AS nm_transportadora,

        cv.cli_cd_codigo_cliente,

        cv.cli_in_ativo AS in_cliente_ativo,

        cv.cli_in_excluido AS in_cliente_excluido,

        cv.in_dashboard_alarmes_habilitado,

        CASE

            WHEN ISNULL(parm.prm_ds_valor, N'true') = N'true' THEN CAST(1 AS BIT)

            ELSE CAST(0 AS BIT)

        END AS in_processo_habilitado,

        CASE

            WHEN cv.cli_in_ativo = 1

             AND cv.cli_in_excluido = 0

             AND cv.in_dashboard_alarmes_habilitado = 1

             AND ISNULL(parm.prm_ds_valor, N'true') = N'true'

            THEN CAST(1 AS BIT)

            ELSE CAST(0 AS BIT)

        END AS in_elegivel_monitoramento,

        parm.prm_ds_valor AS prm_habilita_processo,

        parm_hora.prm_ds_valor AS prm_habilita_coleta_hora_saida,

        mo.dh_ultimo_evento_origem,

        md.dh_ultimo_evento_destino,

        ISNULL(mo.qt_registros_origem, 0) AS qt_registros_origem,

        ISNULL(md.qt_registros_destino, 0) AS qt_registros_destino,

        ISNULL(mo.qt_fila_pendente, 0) AS qt_fila_pendente,

        mo.dh_fila_mais_antiga,

        ISNULL(md.qt_destino_nulos, 0) AS qt_destino_nulos,

        j.dh_ultima_execucao AS job_ultima_execucao,

        j.ds_ultima_execucao AS job_status,

        j.cd_ultima_execucao AS job_cd_status,

        j.in_possivel_travado AS job_in_travado,

        ref.dt_hoje,

        ref.hr_agora,

        DATEADD(MINUTE, -p.sla_minutos, GETDATE()) AS dh_sla_limite_processo,

        CASE

            WHEN p.in_origem_irisys_json = 1

             AND ref.hr_agora NOT BETWEEN CAST('05:00:00' AS TIME(0)) AND CAST('23:39:00' AS TIME(0))

            THEN 1

            WHEN p.tipo_regra = N'LOOKER_DIARIO'

             AND ref.hr_agora < ISNULL(p.hr_validacao, CAST('08:00:00' AS TIME(0)))

            THEN 1

            WHEN p.tipo_regra = N'PIPELINE_5MIN'

             AND p.hr_validacao IS NOT NULL

             AND ref.hr_agora < p.hr_validacao

            THEN 1

            ELSE 0

        END AS in_fora_janela_origem

    FROM dbo.tb_pbi_mon_processo AS p

    CROSS JOIN Ref AS ref

    INNER JOIN ClientesCatalogo AS cv

        ON 1 = 1

    LEFT JOIN dbo.tb_parametros AS parm WITH (NOLOCK)

        ON parm.prm_ds_categoria = N'Alertas'

       AND parm.prm_cod_cliente = cv.cli_cd_codigo_cliente

       AND parm.prm_nm_parametro = p.parametro_habilita

       AND ISNULL(parm.prm_in_ativo, 1) = 1

       AND ISNULL(parm.prm_in_excluido, 0) = 0

    LEFT JOIN dbo.tb_parametros AS parm_hora WITH (NOLOCK)

        ON parm_hora.prm_ds_categoria = N'Monitoramento Meli'

       AND parm_hora.prm_cod_cliente = cv.cli_cd_codigo_cliente

       AND parm_hora.prm_nm_parametro = N'Habilitar Coleta Hora Saida EstaÃ§Ã£o'

       AND ISNULL(parm_hora.prm_in_ativo, 1) = 1

       AND ISNULL(parm_hora.prm_in_excluido, 0) = 0

    LEFT JOIN MetricasOrigem AS mo

        ON mo.processo_codigo = p.processo_codigo

       AND mo.id_transportadora = CASE p.id_cliente_campo

            WHEN N'cli_id_logistics' THEN cv.cli_id_logistics

            WHEN N'cli_id_shopee' THEN cv.cli_id_shopee

        END

    LEFT JOIN MetricasDestino AS md

        ON md.processo_codigo = p.processo_codigo

       AND md.id_transportadora = CASE p.id_cliente_campo

            WHEN N'cli_id_logistics' THEN cv.cli_id_logistics

            WHEN N'cli_id_shopee' THEN cv.cli_id_shopee

        END

    LEFT JOIN dbo.vw_pbi_mon_job_status AS j

        ON j.nm_job = p.job_nome

    WHERE p.in_ativo = 1

      AND (

            (p.id_cliente_campo = N'cli_id_logistics' AND cv.cli_id_logistics IS NOT NULL AND cv.cli_id_logistics > 0)

         OR (p.id_cliente_campo = N'cli_id_shopee' AND cv.cli_id_shopee IS NOT NULL AND cv.cli_id_shopee > 0)

      )

),

Avaliacao AS

(

    SELECT

        b.*,

        CASE

            WHEN b.prm_habilita_processo = N'false' THEN 2

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.prm_habilita_coleta_hora_saida, N'false') <> N'true' THEN 2

            /* ML_LM_ROUTE_EVENTS: falha apenas por nulos no destino ou erro de job */

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.in_fora_janela_origem = 0

                 AND (b.job_cd_status = 0 OR b.job_in_travado = 1) THEN 1

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.in_fora_janela_origem = 0

                 AND b.qt_destino_nulos > 0 THEN 1

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.in_fora_janela_origem = 0 THEN 0

            /* ML_PROCESSAMENTO_KM_ROTAS: rotas de hoje sem registro em tb_ml_processamento_km_rotas apos 1h */

            WHEN b.processo_codigo = N'ML_PROCESSAMENTO_KM_ROTAS'

                 AND b.qt_destino_nulos > 0 THEN 1

            WHEN b.processo_codigo = N'ML_PROCESSAMENTO_KM_ROTAS' THEN 0

            /* Fluxos sem origem Irisys: respeitar janela hr_validacao */

            WHEN b.in_origem_obrigatoria = 0

                 AND b.hr_validacao IS NOT NULL

                 AND b.in_fora_janela_origem = 1 THEN 0

            /* Fluxos UPDATE sem origem Irisys: somente destino + job */

            WHEN b.in_origem_obrigatoria = 0

                 AND b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND (b.job_cd_status = 0 OR b.job_in_travado = 1) THEN 1

            WHEN b.in_origem_obrigatoria = 0

                 AND b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND b.qt_registros_destino = 0 THEN 1

            WHEN b.in_origem_obrigatoria = 0

                 AND b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND b.qt_registros_destino > 0

                 AND (b.dh_ultimo_evento_destino IS NULL

                   OR b.dh_ultimo_evento_destino < CASE WHEN b.processo_codigo = N'LOOKER_PARADAS' THEN CAST(DATEADD(DAY, -1, b.dt_hoje) AS DATETIME2) ELSE b.dh_sla_limite_processo END) THEN 1

            WHEN b.in_origem_obrigatoria = 0

                 AND b.tipo_regra = N'PIPELINE_5MIN' THEN 0

            WHEN b.tipo_regra = N'LOOKER_DIARIO' AND b.in_fora_janela_origem = 1 THEN 0

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND b.qt_registros_origem = 0 THEN 1

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND b.qt_registros_origem > 0

                 AND b.qt_registros_destino = 0 THEN 1

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND b.qt_registros_destino > 0

                 AND CAST(b.dh_ultimo_evento_destino AS DATE) < DATEADD(DAY, -CASE WHEN b.processo_codigo = N'LOOKER_PNR' THEN 1 ELSE 0 END, b.dt_hoje) THEN 1

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND b.job_cd_status = 0

                 AND CAST(b.job_ultima_execucao AS DATE) = b.dt_hoje THEN 1

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.in_fora_janela_origem = 0

                 AND b.qt_registros_origem = 0 THEN 1

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.in_fora_janela_origem = 0

                 AND b.qt_registros_origem > 0

                 AND (b.dh_ultimo_evento_origem IS NULL OR b.dh_ultimo_evento_origem < b.dh_sla_limite_processo) THEN 1

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.in_fora_janela_origem = 0

                 AND b.qt_fila_pendente > ISNULL(b.nr_tolerancia_fila, 0)

                 AND b.dh_fila_mais_antiga IS NOT NULL

                 AND b.dh_fila_mais_antiga < b.dh_sla_limite_processo THEN 1

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND b.qt_registros_destino = 0 THEN 1

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND b.qt_registros_destino > 0

                 AND (b.dh_ultimo_evento_destino IS NULL

                   OR b.dh_ultimo_evento_destino < CASE WHEN b.processo_codigo = N'LOOKER_PARADAS' THEN CAST(DATEADD(DAY, -1, b.dt_hoje) AS DATETIME2) ELSE b.dh_sla_limite_processo END) THEN 1

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.destino_regra = N'NULOS'

                 AND b.qt_destino_nulos > 0 THEN 1

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.job_in_travado = 1 THEN 1

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.job_cd_status = 0 THEN 1

            ELSE 0

        END AS cd_status,

        CASE

            WHEN b.prm_habilita_processo = N'false' THEN NULL

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.prm_habilita_coleta_hora_saida, N'false') <> N'true' THEN NULL

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.in_fora_janela_origem = 1 THEN NULL

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.job_in_travado = 1 THEN N'JOB_TRAVADO'

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.job_cd_status = 0 THEN N'JOB_ERRO'

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.qt_destino_nulos > 0 THEN N'DESTINO_CAMPOS_NULOS'

            WHEN b.processo_codigo = N'ML_PROCESSAMENTO_KM_ROTAS'

                 AND b.qt_destino_nulos > 0 THEN N'DESTINO_KM_AUSENTE'

            WHEN b.in_origem_obrigatoria = 0

                 AND b.hr_validacao IS NOT NULL

                 AND b.in_fora_janela_origem = 1 THEN NULL

            WHEN b.in_origem_obrigatoria = 0

                 AND b.job_in_travado = 1 THEN N'JOB_TRAVADO'

            WHEN b.in_origem_obrigatoria = 0

                 AND b.job_cd_status = 0 THEN N'JOB_ERRO'

            WHEN b.in_origem_obrigatoria = 0

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND b.qt_registros_destino = 0 THEN N'DESTINO_SEM_CARGA_HOJE'

            WHEN b.in_origem_obrigatoria = 0

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND b.qt_registros_destino > 0

                 AND (b.dh_ultimo_evento_destino IS NULL

                   OR b.dh_ultimo_evento_destino < CASE WHEN b.processo_codigo = N'LOOKER_PARADAS' THEN CAST(DATEADD(DAY, -1, b.dt_hoje) AS DATETIME2) ELSE b.dh_sla_limite_processo END) THEN N'DESTINO_DESATUALIZADO'

            WHEN b.tipo_regra = N'LOOKER_DIARIO' AND b.in_fora_janela_origem = 1 THEN NULL

            WHEN b.tipo_regra = N'LOOKER_DIARIO' AND b.qt_registros_origem = 0 THEN N'ORIGEM_SEM_DADOS_HOJE'

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND b.qt_registros_origem > 0

                 AND b.qt_registros_destino = 0 THEN N'DESTINO_SEM_CARGA_HOJE'

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND b.qt_registros_destino > 0

                 AND CAST(b.dh_ultimo_evento_destino AS DATE) < DATEADD(DAY, -CASE WHEN b.processo_codigo = N'LOOKER_PNR' THEN 1 ELSE 0 END, b.dt_hoje) THEN N'DESTINO_DATA_ANTIGA'

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND b.job_cd_status = 0

                 AND CAST(b.job_ultima_execucao AS DATE) = b.dt_hoje THEN N'JOB_ERRO'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.in_fora_janela_origem = 0

                 AND b.qt_registros_origem = 0 THEN N'ORIGEM_SEM_DADOS_HOJE'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.in_fora_janela_origem = 0

                 AND b.qt_registros_origem > 0

                 AND (b.dh_ultimo_evento_origem IS NULL

                   OR b.dh_ultimo_evento_origem < b.dh_sla_limite_processo) THEN N'ORIGEM_PARADA'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.in_fora_janela_origem = 0

                 AND b.qt_fila_pendente > ISNULL(b.nr_tolerancia_fila, 0)

                 AND b.dh_fila_mais_antiga IS NOT NULL

                 AND b.dh_fila_mais_antiga < b.dh_sla_limite_processo THEN N'FILA_ATRASADA'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND b.qt_registros_destino = 0 THEN N'DESTINO_SEM_CARGA_HOJE'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND b.qt_registros_destino > 0

                 AND (b.dh_ultimo_evento_destino IS NULL

                   OR b.dh_ultimo_evento_destino < CASE WHEN b.processo_codigo = N'LOOKER_PARADAS' THEN CAST(DATEADD(DAY, -1, b.dt_hoje) AS DATETIME2) ELSE b.dh_sla_limite_processo END) THEN N'DESTINO_DESATUALIZADO'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.destino_regra = N'NULOS'

                 AND b.qt_destino_nulos > 0 THEN N'DESTINO_CAMPOS_NULOS'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.job_in_travado = 1 THEN N'JOB_TRAVADO'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.job_cd_status = 0 THEN N'JOB_ERRO'

            ELSE NULL

        END AS motivo_falha,

        CASE

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.in_fora_janela_origem = 1 THEN NULL

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND (b.job_cd_status = 0 OR b.job_in_travado = 1) THEN N'JOB'

            WHEN b.processo_codigo = N'ML_LM_ROUTE_EVENTS'

                 AND b.qt_destino_nulos > 0 THEN N'DESTINO'

            WHEN b.processo_codigo = N'ML_PROCESSAMENTO_KM_ROTAS'

                 AND b.qt_destino_nulos > 0 THEN N'DESTINO'

            WHEN b.in_origem_obrigatoria = 0

                 AND b.hr_validacao IS NOT NULL

                 AND b.in_fora_janela_origem = 1 THEN NULL

            WHEN b.in_origem_obrigatoria = 0

                 AND (b.job_cd_status = 0 OR b.job_in_travado = 1) THEN N'JOB'

            WHEN b.in_origem_obrigatoria = 0

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND (b.qt_registros_destino = 0

                   OR b.dh_ultimo_evento_destino IS NULL

                   OR b.dh_ultimo_evento_destino < CASE WHEN b.processo_codigo = N'LOOKER_PARADAS' THEN CAST(DATEADD(DAY, -1, b.dt_hoje) AS DATETIME2) ELSE b.dh_sla_limite_processo END) THEN N'DESTINO'

            WHEN b.tipo_regra = N'LOOKER_DIARIO' AND b.in_fora_janela_origem = 1 THEN NULL

            WHEN b.tipo_regra = N'LOOKER_DIARIO' AND b.qt_registros_origem = 0 THEN N'ORIGEM'

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND (b.qt_registros_destino = 0

                   OR CAST(b.dh_ultimo_evento_destino AS DATE) < DATEADD(DAY, -CASE WHEN b.processo_codigo = N'LOOKER_PNR' THEN 1 ELSE 0 END, b.dt_hoje)) THEN N'DESTINO'

            WHEN b.tipo_regra = N'LOOKER_DIARIO'

                 AND b.job_cd_status = 0

                 AND CAST(b.job_ultima_execucao AS DATE) = b.dt_hoje THEN N'JOB'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.in_fora_janela_origem = 0

                 AND (b.qt_registros_origem = 0

                   OR b.dh_ultimo_evento_origem IS NULL

                   OR b.dh_ultimo_evento_origem < b.dh_sla_limite_processo) THEN N'ORIGEM'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.in_fora_janela_origem = 0

                 AND b.qt_fila_pendente > ISNULL(b.nr_tolerancia_fila, 0)

                 AND b.dh_fila_mais_antiga IS NOT NULL

                 AND b.dh_fila_mais_antiga < b.dh_sla_limite_processo THEN N'FILA'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.destino_regra IN (N'ATUALIZACAO', N'FRESHNESS')

                 AND (b.qt_registros_destino = 0

                   OR b.dh_ultimo_evento_destino IS NULL

                   OR b.dh_ultimo_evento_destino < CASE WHEN b.processo_codigo = N'LOOKER_PARADAS' THEN CAST(DATEADD(DAY, -1, b.dt_hoje) AS DATETIME2) ELSE b.dh_sla_limite_processo END) THEN N'DESTINO'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND b.destino_regra = N'NULOS'

                 AND b.qt_destino_nulos > 0 THEN N'DESTINO'

            WHEN b.tipo_regra = N'PIPELINE_5MIN'

                 AND b.processo_codigo <> N'ML_LM_ROUTE_EVENTS'

                 AND ISNULL(b.in_origem_obrigatoria, 1) = 1

                 AND (b.job_cd_status = 0 OR b.job_in_travado = 1) THEN N'JOB'

            ELSE NULL

        END AS etapa_falha

    FROM Base AS b

)

SELECT

    a.dt_hoje AS dt_referencia,

    a.cli_cd_codigo_cliente,

    a.id_transportadora,

    a.nm_transportadora,

    a.in_cliente_ativo,

    a.in_cliente_excluido,

    a.in_dashboard_alarmes_habilitado,

    a.in_processo_habilitado,

    a.in_elegivel_monitoramento,

    a.plataforma,

    a.processo_id,

    a.processo_codigo,

    a.processo_nome,

    a.tabela_destino,

    a.tipo_regra,

    a.sla_minutos,

    a.sla_label,

    a.nr_tolerancia_fila,

    a.destino_regra,

    CASE

        WHEN a.cd_status = 2 THEN NULL

        WHEN a.etapa_falha = N'ORIGEM' THEN N'Desenvolvimento'

        WHEN a.etapa_falha IN (N'FILA', N'DESTINO', N'JOB') THEN N'Dados'

        ELSE NULL

    END AS grupo_responsavel,

    a.etapa_falha,

    a.motivo_falha,

    a.cd_status,

    CASE a.cd_status

        WHEN 0 THEN N'OK'

        WHEN 1 THEN N'Em falha'

        WHEN 2 THEN N'Monitoramento desativado'

        ELSE N'Desconhecido'

    END AS ds_status,

    a.in_fora_janela_origem,

    a.dh_ultimo_evento_origem,

    a.dh_ultimo_evento_destino,

    a.qt_registros_origem,

    a.qt_registros_destino,

    a.qt_fila_pendente,

    a.qt_destino_nulos,

    a.job_nome AS nm_job,

    a.job_ultima_execucao,

    a.job_status,

    a.proc_orquestrador,

    a.proc_carga,

    REPLACE(

        REPLACE(

            REPLACE(

                REPLACE(

                    REPLACE(

                        CASE a.motivo_falha

                            WHEN N'ORIGEM_SEM_DADOS_HOJE' THEN COALESCE(a.ds_acao_origem_sem_dados, a.ds_acao_origem)

                            WHEN N'ORIGEM_PARADA' THEN COALESCE(a.ds_acao_origem_parada, a.ds_acao_origem)

                            WHEN N'FILA_ATRASADA' THEN a.ds_acao_fila

                            WHEN N'DESTINO_SEM_CARGA_HOJE' THEN COALESCE(a.ds_acao_destino_sem_carga, a.ds_acao_destino)

                            WHEN N'DESTINO_DESATUALIZADO' THEN COALESCE(a.ds_acao_destino_desatualizado, a.ds_acao_destino)

                            WHEN N'DESTINO_DATA_ANTIGA' THEN COALESCE(a.ds_acao_destino_data_antiga, a.ds_acao_destino)

                            WHEN N'DESTINO_CAMPOS_NULOS' THEN COALESCE(a.ds_acao_destino_nulos, a.ds_acao_destino)

                            WHEN N'DESTINO_KM_AUSENTE' THEN COALESCE(a.ds_acao_destino_nulos, a.ds_acao_destino)

                            WHEN N'JOB_ERRO' THEN COALESCE(a.ds_acao_job_erro, a.ds_acao_job)

                            WHEN N'JOB_TRAVADO' THEN COALESCE(a.ds_acao_job_travado, a.ds_acao_job)

                            ELSE N'Sem acao necessaria.'

                        END,

                        N'{sla_label}',

                        a.sla_label

                    ),

                    N'{dh_ultimo_evento_origem}',

                    CASE

                        WHEN a.dh_ultimo_evento_origem IS NULL THEN N'nunca'

                        WHEN CAST(a.dh_ultimo_evento_origem AS DATE) = a.dt_hoje

                            THEN CONVERT(NVARCHAR(5), a.dh_ultimo_evento_origem, 108)

                        ELSE CONVERT(NVARCHAR(11), a.dh_ultimo_evento_origem, 103)

                           + N' ' + CONVERT(NVARCHAR(5), a.dh_ultimo_evento_origem, 108)

                    END

                ),

                N'{dh_ultimo_evento_destino}',

                CASE

                    WHEN a.dh_ultimo_evento_destino IS NULL THEN N'nunca'

                    WHEN CAST(a.dh_ultimo_evento_destino AS DATE) = a.dt_hoje

                        THEN CONVERT(NVARCHAR(5), a.dh_ultimo_evento_destino, 108)

                    ELSE CONVERT(NVARCHAR(11), a.dh_ultimo_evento_destino, 103)

                       + N' ' + CONVERT(NVARCHAR(5), a.dh_ultimo_evento_destino, 108)

                END

            ),

            N'{dh_fila_mais_antiga}',

            CASE

                WHEN a.dh_fila_mais_antiga IS NULL THEN N'nunca'

                WHEN CAST(a.dh_fila_mais_antiga AS DATE) = a.dt_hoje

                    THEN CONVERT(NVARCHAR(5), a.dh_fila_mais_antiga, 108)

                ELSE CONVERT(NVARCHAR(11), a.dh_fila_mais_antiga, 103)

                   + N' ' + CONVERT(NVARCHAR(5), a.dh_fila_mais_antiga, 108)

            END

        ),

        N'{job_ultima_execucao}',

        CASE

            WHEN a.job_ultima_execucao IS NULL THEN N'nunca'

            WHEN CAST(a.job_ultima_execucao AS DATE) = a.dt_hoje

                THEN CONVERT(NVARCHAR(5), a.job_ultima_execucao, 108)

            ELSE CONVERT(NVARCHAR(11), a.job_ultima_execucao, 103)

               + N' ' + CONVERT(NVARCHAR(5), a.job_ultima_execucao, 108)

        END

    ) AS ds_acao_recomendada,

    CONCAT(

        N'Origem=', ISNULL(CONVERT(NVARCHAR(30), a.dh_ultimo_evento_origem, 120), N'NULL'),

        N'; RegOrigem=', CAST(a.qt_registros_origem AS NVARCHAR(20)),

        N'; Destino=', ISNULL(CONVERT(NVARCHAR(30), a.dh_ultimo_evento_destino, 120), N'NULL'),

        N'; RegDestino=', CAST(a.qt_registros_destino AS NVARCHAR(20)),

        N'; NulosDestino=', CAST(a.qt_destino_nulos AS NVARCHAR(20)),

        N'; Fila=', CAST(a.qt_fila_pendente AS NVARCHAR(20)),

        N'; ToleranciaFila=', CAST(a.nr_tolerancia_fila AS NVARCHAR(20)),

        N'; SLA=', a.sla_label,

        N'; Motivo=', ISNULL(a.motivo_falha, N'N/A'),

        N'; Job=', ISNULL(a.job_status, N'N/A')

    ) AS ds_evidencia

FROM Avaliacao AS a;
GO
--==========================================================================
-- 3. POS-CHECKS
--==========================================================================
BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 FROM sys.sql_modules sm
        WHERE sm.object_id = OBJECT_ID('dbo.vw_pbi_mon_alertas_processos_calc')
          AND sm.definition LIKE '%WHERE d.amb_data = r.dt_hoje%'
          AND sm.definition NOT LIKE "%N'LOOKER_PNR', N'LOOKER_AMBULANCIAS'%"
    )
        THROW 50024, 'View nao foi restaurada para a regra de hoje.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO