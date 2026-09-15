-- ============================================================
-- BASELINE: dbo.vw_pbi_mon_alertas_processos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_mon_alertas_processos]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[vw_pbi_mon_alertas_processos]
AS
SELECT
    f.id_transportadora,
    f.nm_transportadora,
    f.plataforma,
    f.processo_id,
    f.processo_codigo,
    f.processo_nome,
    f.tabela_destino,
    f.tipo_regra,
    f.sla_minutos,
    f.sla_label,
    f.nr_tolerancia_fila,
    f.destino_regra,
    f.grupo_responsavel,
    f.etapa_falha,
    f.motivo_falha,
    CAST(f.cd_status AS INT) AS cd_status,
    f.ds_status,
    CAST(ult_log.cd_status_ultimo_log AS INT) AS cd_status_log,
    CASE
        WHEN f.cd_status = 1 AND ult_log.cd_status_ultimo_log = 2 THEN 1
        ELSE 0
    END AS in_em_atendimento,
    CAST(f.in_fora_janela_origem AS INT) AS in_fora_janela_origem,
    f.dh_ultimo_evento_origem,
    f.dh_ultimo_evento_destino,
    f.qt_registros_origem,
    f.qt_registros_destino,
    f.qt_fila_pendente,
    f.qt_destino_nulos,
    f.nm_job,
    f.job_ultima_execucao,
    f.job_status,
    f.proc_orquestrador,
    f.proc_carga,
    f.ds_acao_recomendada,
    f.ds_evidencia,
    CASE
        WHEN f.cd_status = 1
         AND ult_log.cd_status_ultimo_log IN (1, 2)
            THEN log_falha.dh_evento
        ELSE NULL
    END AS dh_inicio_falha,
    CASE
        WHEN f.cd_status = 1
         AND ult_log.cd_status_ultimo_log IN (1, 2)
            THEN DATEDIFF(MINUTE, log_falha.dh_evento, SYSDATETIME())
        ELSE NULL
    END AS qt_minutos_em_falha,
    CASE
        WHEN f.cd_status = 1 AND ult_log.cd_status_ultimo_log IN (1, 2) THEN
            CASE
                WHEN DATEDIFF(MINUTE, log_falha.dh_evento, SYSDATETIME()) < 60  THEN 0
                WHEN DATEDIFF(MINUTE, log_falha.dh_evento, SYSDATETIME()) < 120 THEN 1
                ELSE 2
            END
        ELSE NULL
    END AS cd_faixa_tempo_falha,
    CASE
        WHEN f.cd_status = 1 AND ult_log.cd_status_ultimo_log IN (1, 2) THEN
            CASE
                WHEN DATEDIFF(MINUTE, log_falha.dh_evento, SYSDATETIME()) < 60  THEN N'< 1h'
                WHEN DATEDIFF(MINUTE, log_falha.dh_evento, SYSDATETIME()) < 120 THEN N'1h a 2h'
                ELSE N'>= 2h'
            END
        ELSE NULL
    END AS ds_faixa_tempo_falha,
    CASE
        WHEN f.cd_status = 1 AND ult_log.cd_status_ultimo_log = 2
            THEN COALESCE(ult_log.dh_inicio_atendimento, ult_log.dh_evento)
        ELSE NULL
    END AS dh_inicio_atendimento,
    CASE
        WHEN f.cd_status = 1 AND ult_log.cd_status_ultimo_log = 2
            THEN DATEDIFF(
                MINUTE,
                COALESCE(ult_log.dh_inicio_atendimento, ult_log.dh_evento),
                SYSDATETIME()
            )
        ELSE NULL
    END AS qt_minutos_em_atendimento,
    f.dh_atualizacao AS dh_referencia_view,
    f.cli_cd_codigo_cliente,
    f.in_cliente_ativo,
    f.in_cliente_excluido,
    f.in_dashboard_alarmes_habilitado,
    f.in_processo_habilitado,
    f.in_elegivel_monitoramento,
    f.dh_atualizacao
FROM dbo.tb_pbi_mon_alertas_fato AS f
OUTER APPLY
(
    SELECT TOP (1)
        l.log_id,
        l.dh_evento,
        l.cd_status AS cd_status_ultimo_log,
        l.dh_inicio_atendimento
    FROM dbo.tb_pbi_mon_log_alertas AS l
    WHERE l.id_transportadora = f.id_transportadora
      AND l.processo_id = f.processo_id
    ORDER BY l.log_id DESC
) AS ult_log
OUTER APPLY
(
    SELECT TOP (1)
        lf.dh_evento
    FROM dbo.tb_pbi_mon_log_alertas AS lf
    WHERE lf.id_transportadora = f.id_transportadora
      AND lf.processo_id = f.processo_id
      AND lf.cd_status = 1
      AND lf.log_id <= ult_log.log_id
      AND lf.log_id > ISNULL((
          SELECT MAX(l0.log_id)
          FROM dbo.tb_pbi_mon_log_alertas AS l0
          WHERE l0.id_transportadora = f.id_transportadora
            AND l0.processo_id = f.processo_id
            AND l0.cd_status = 0
            AND l0.log_id < ult_log.log_id
      ), 0)
    ORDER BY lf.log_id ASC
) AS log_falha
where 1=1
and f.in_cliente_ativo                  = 1
and f.in_cliente_excluido               = 0
and f.in_dashboard_alarmes_habilitado   = 1
;
GO
