-- ============================================================
-- BASELINE: dbo.vw_pbi_mon_alertas_historico
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_mon_alertas_historico]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_pbi_mon_alertas_historico]
AS
WITH Ref AS
(
    SELECT
        CAST(GETDATE() AS DATE)                    AS dt_hoje,
        DATEADD(DAY, -15, CAST(GETDATE() AS DATE)) AS dt_inicio,
        DATEADD(DAY,  -1, CAST(GETDATE() AS DATE)) AS dt_fim
),
Calendario AS
(
    SELECT
        DATEADD(DAY, -n.nr_dias, r.dt_hoje) AS dt_referencia,
        n.nr_dias
    FROM Ref AS r
    CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15)) AS n(nr_dias)
),
Indicadores AS
(
    SELECT
        f.id_transportadora,
        f.nm_transportadora,
        f.cli_cd_codigo_cliente,
        f.plataforma,
        f.processo_id,
        f.processo_codigo,
        f.processo_nome,
        f.tabela_destino,
        f.tipo_regra,
        f.destino_regra,
        f.sla_label,
        f.in_cliente_ativo,
        f.in_cliente_excluido,
        f.in_dashboard_alarmes_habilitado,
        f.in_processo_habilitado,
        f.in_elegivel_monitoramento,
        p.job_nome AS nm_job,
        p.proc_orquestrador,
        p.proc_carga
    FROM dbo.tb_pbi_mon_alertas_fato AS f
    INNER JOIN dbo.tb_pbi_mon_processo AS p
        ON p.processo_id = f.processo_id
    WHERE f.dt_referencia = (SELECT MAX(f2.dt_referencia) FROM dbo.tb_pbi_mon_alertas_fato AS f2)
      AND f.in_cliente_ativo                = 1
      AND f.in_cliente_excluido             = 0
      AND f.in_dashboard_alarmes_habilitado = 1
      AND f.in_processo_habilitado          = 1
      AND f.in_elegivel_monitoramento       = 1
      AND p.in_ativo                        = 1
),
HistoricoDestino AS
(
    /* ML_ROTAS */
    SELECT
        N'ML_ROTAS'            AS processo_codigo,
        d.IdTransportadora     AS id_transportadora,
        d.DataReferencia       AS dt_referencia,
        MAX(d.DataAtualizacao) AS dh_ultimo_evento_destino,
        COUNT_BIG(*)           AS qt_registros_destino,
        CAST(0 AS BIGINT)      AS qt_destino_nulos
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_rotas AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* ML_PACOTES */
    SELECT N'ML_PACOTES', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_pacotes AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* ML_FM_ROTAS */
    SELECT N'ML_FM_ROTAS', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_fm_rotas AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* ML_FM_PARADAS */
    SELECT N'ML_FM_PARADAS', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_fm_paradas AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* ML_LH_ROTAS */
    SELECT N'ML_LH_ROTAS', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_lh_rotas AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* ML_MOTORISTAS */
    SELECT N'ML_MOTORISTAS', d.IdTransportadora, CAST(d.DataColeta AS DATE), MAX(d.DataColeta), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_motoristas AS d WITH (NOLOCK)
    WHERE CAST(d.DataColeta AS DATE) BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, CAST(d.DataColeta AS DATE)
    UNION ALL
    /* ML_LM_ROUTE_EVENTS */
    SELECT N'ML_LM_ROUTE_EVENTS', d.IdTransportadora, d.DataReferencia, MAX(d.DataHoraSaidaEstacao), COUNT_BIG(*),
        SUM(CASE WHEN d.DataHoraSaidaEstacao IS NULL AND (d.DataHoraSaidaEstacaoAusente = 0 OR d.DataHoraSaidaEstacaoAusente IS NULL) THEN 1 ELSE 0 END)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_rotas AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
      AND d.Excluido = 0
      AND d.StatusRota <> N'planned'
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* SPE_ROTAS_V5_TRIP */
    SELECT N'SPE_ROTAS_V5_TRIP', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* SPE_ROTAS_V5_FM */
    SELECT N'SPE_ROTAS_V5_FM', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* SPE_ROTAS_V5_LH */
    SELECT N'SPE_ROTAS_V5_LH', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* SPE_PACOTES_V5 */
    SELECT N'SPE_PACOTES_V5', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_spe_pacotes_v5 AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* LOOKER_RTT */
    SELECT N'LOOKER_RTT', rot.IdTransportadora, CAST(b.DataInsert AS DATE), MAX(b.DataInsert), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_bsc_rtt AS b WITH (NOLOCK)
    INNER JOIN dbo.tb_ml_rotas AS rot WITH (NOLOCK) ON rot.IdRota = b.IdRota
    WHERE CAST(b.DataInsert AS DATE) BETWEEN r.dt_inicio AND r.dt_fim
      AND rot.StatusRota <> N'planned'
      AND rot.Excluido = 0
    GROUP BY rot.IdTransportadora, CAST(b.DataInsert AS DATE)
    UNION ALL
    /* LOOKER_TREINAMENTOS */
    SELECT N'LOOKER_TREINAMENTOS', d.cd_transportadora, CAST(d.timestamp AS DATE), MAX(d.timestamp), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_looker_treinamentos_geral AS d WITH (NOLOCK)
    WHERE CAST(d.timestamp AS DATE) BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.cd_transportadora, CAST(d.timestamp AS DATE)
    UNION ALL
    /* LOOKER_AMBULANCIAS */
    SELECT N'LOOKER_AMBULANCIAS', d.amb_cd_transportadora, CAST(d.amb_data_etl AS DATE), MAX(d.amb_data_etl), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_looker_ambulancias AS d WITH (NOLOCK)
    WHERE CAST(d.amb_data_etl AS DATE) BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.amb_cd_transportadora, CAST(d.amb_data_etl AS DATE)
    UNION ALL
    /* ML_INDICADORES_ROTA */
    SELECT N'ML_INDICADORES_ROTA', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_rotas AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim AND d.Excluido = 0
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* ML_CIDADE_DISTANTE_DIA */
    SELECT N'ML_CIDADE_DISTANTE_DIA', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*),
        SUM(CASE WHEN d.CidadeDistante IS NULL OR LTRIM(RTRIM(d.CidadeDistante)) = N'' THEN 1 ELSE 0 END)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_rotas AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim AND d.Excluido = 0
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* SPE_INDICADORES_V5 */
    SELECT N'SPE_INDICADORES_V5', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* SPE_CIDADE_DISTANTE_DIA */
    SELECT N'SPE_CIDADE_DISTANTE_DIA', d.IdTransportadora, d.DataReferencia, MAX(d.DataAtualizacao), COUNT_BIG(*),
        SUM(CASE WHEN d.CidadeDistante IS NULL OR LTRIM(RTRIM(d.CidadeDistante)) = N'' THEN 1 ELSE 0 END)
    FROM Ref AS r
    CROSS JOIN dbo.tb_spe_rotas_v5 AS d WITH (NOLOCK)
    WHERE d.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.IdTransportadora, d.DataReferencia
    UNION ALL
    /* DRA_HISTORICO_ROTAS */
    SELECT N'DRA_HISTORICO_ROTAS', d.dhr_cd_cliente, d.dhr_dt_data, MAX(d.dhr_dh_coleta), COUNT_BIG(*), CAST(0 AS BIGINT)
    FROM Ref AS r
    CROSS JOIN dbo.tb_dra_historico_rotas AS d WITH (NOLOCK)
    WHERE d.dhr_dt_data BETWEEN r.dt_inicio AND r.dt_fim
    GROUP BY d.dhr_cd_cliente, d.dhr_dt_data
    UNION ALL
    /* ML_PROCESSAMENTO_KM_ROTAS */
    SELECT N'ML_PROCESSAMENTO_KM_ROTAS', rot.IdTransportadora, rot.DataReferencia, MAX(km.dateCreated), COUNT_BIG(*),
        SUM(CASE WHEN km.id IS NULL THEN 1 ELSE 0 END)
    FROM Ref AS r
    CROSS JOIN dbo.tb_ml_rotas AS rot WITH (NOLOCK)
    LEFT JOIN dbo.tb_ml_processamento_km_rotas AS km WITH (NOLOCK) ON km.idRota = rot.IdRota
    WHERE rot.DataReferencia BETWEEN r.dt_inicio AND r.dt_fim
      AND rot.Excluido = 0
      AND rot.StatusRota <> N'planned'
      AND rot.DataHoraColeta IS NOT NULL
    GROUP BY rot.IdTransportadora, rot.DataReferencia
),
Base AS
(
    SELECT
        cal.dt_referencia,
        cal.nr_dias AS nr_dias_atras,
        i.cli_cd_codigo_cliente,
        i.id_transportadora,
        i.nm_transportadora,
        i.plataforma,
        i.processo_id,
        i.processo_codigo,
        i.processo_nome,
        i.tabela_destino,
        i.tipo_regra,
        i.destino_regra,
        i.sla_label,
        i.nm_job,
        i.proc_orquestrador,
        i.proc_carga,
        i.in_cliente_ativo,
        i.in_cliente_excluido,
        i.in_dashboard_alarmes_habilitado,
        i.in_processo_habilitado,
        i.in_elegivel_monitoramento,
        h.dh_ultimo_evento_destino,
        ISNULL(h.qt_registros_destino, 0) AS qt_registros_destino,
        ISNULL(h.qt_destino_nulos, 0)     AS qt_destino_nulos
    FROM Calendario AS cal
    CROSS JOIN Indicadores AS i
    LEFT JOIN HistoricoDestino AS h
        ON  h.processo_codigo   = i.processo_codigo
        AND h.id_transportadora = i.id_transportadora
        AND h.dt_referencia     = cal.dt_referencia
),
Avaliacao AS
(
    SELECT
        b.*,
        CASE
            WHEN b.qt_registros_destino = 0 THEN N'HISTORICO_AUSENTE'
            WHEN b.destino_regra = N'NULOS' AND b.qt_destino_nulos > 0 THEN N'HISTORICO_CAMPOS_NULOS'
            ELSE NULL
        END AS motivo_falha
    FROM Base AS b
)
SELECT
    a.dt_referencia,
    a.nr_dias_atras,
    DATENAME(WEEKDAY, a.dt_referencia) AS ds_dia_semana,
    CAST(CASE WHEN DATEPART(WEEKDAY, a.dt_referencia) IN (1, 7) THEN 1 ELSE 0 END AS BIT) AS in_fim_semana,
    a.cli_cd_codigo_cliente,
    a.id_transportadora,
    a.nm_transportadora,
    a.plataforma,
    a.processo_id,
    a.processo_codigo,
    a.processo_nome,
    a.tabela_destino,
    a.tipo_regra,
    a.destino_regra,
    a.sla_label,
    a.nm_job,
    a.proc_orquestrador,
    a.proc_carga,
    a.in_cliente_ativo,
    a.in_cliente_excluido,
    a.in_dashboard_alarmes_habilitado,
    a.in_processo_habilitado,
    a.in_elegivel_monitoramento,
    a.qt_registros_destino,
    a.qt_destino_nulos,
    a.dh_ultimo_evento_destino,
    CAST(CASE WHEN a.motivo_falha = N'HISTORICO_AUSENTE' THEN 1 ELSE 0 END AS BIT) AS in_historico_ausente,
    CAST(CASE WHEN a.motivo_falha = N'HISTORICO_CAMPOS_NULOS' THEN 1 ELSE 0 END AS BIT) AS in_historico_incompleto,
    CAST(CASE WHEN a.motivo_falha IS NULL THEN 0 ELSE 1 END AS INT) AS cd_status,
    CASE a.motivo_falha
        WHEN N'HISTORICO_AUSENTE'      THEN N'Sem historico'
        WHEN N'HISTORICO_CAMPOS_NULOS' THEN N'Historico incompleto'
        ELSE N'OK'
    END AS ds_status,
    a.motivo_falha,
    CASE WHEN a.motivo_falha IS NULL THEN NULL ELSE N'DESTINO' END AS etapa_falha,
    CASE WHEN a.motivo_falha IS NULL THEN NULL ELSE N'Dados' END AS grupo_responsavel,
    CASE a.motivo_falha
        WHEN N'HISTORICO_AUSENTE' THEN
            N'Nao existe nenhum registro em ' + a.tabela_destino
          + N' para ' + CONVERT(NVARCHAR(10), a.dt_referencia, 103)
          + N'. Verificar reprocessamento da carga (' + ISNULL(a.proc_carga, ISNULL(a.nm_job, N'processo de carga')) + N').'
        WHEN N'HISTORICO_CAMPOS_NULOS' THEN
            N'Existem ' + CAST(a.qt_destino_nulos AS NVARCHAR(20)) + N' de ' + CAST(a.qt_registros_destino AS NVARCHAR(20))
          + N' registros sem o campo critico preenchido em ' + a.tabela_destino
          + N' para ' + CONVERT(NVARCHAR(10), a.dt_referencia, 103) + N'. Verificar reprocessamento do enriquecimento.'
        ELSE N'Sem acao necessaria.'
    END AS ds_acao_recomendada,
    CONCAT(
        N'Data=', CONVERT(NVARCHAR(10), a.dt_referencia, 103),
        N'; Destino=', a.tabela_destino,
        N'; RegDestino=', CAST(a.qt_registros_destino AS NVARCHAR(20)),
        N'; NulosDestino=', CAST(a.qt_destino_nulos AS NVARCHAR(20)),
        N'; UltimoEventoDestino=', ISNULL(CONVERT(NVARCHAR(30), a.dh_ultimo_evento_destino, 120), N'NULL'),
        N'; Regra=', a.destino_regra,
        N'; Motivo=', ISNULL(a.motivo_falha, N'N/A')
    ) AS ds_evidencia,
    CAST(SYSDATETIME() AS DATETIME2(0)) AS dh_referencia_view
FROM Avaliacao AS a;
GO
