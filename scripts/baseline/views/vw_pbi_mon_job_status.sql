-- ============================================================
-- BASELINE: dbo.vw_pbi_mon_job_status
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_mon_job_status]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [dbo].[vw_pbi_mon_job_status]
AS
WITH UltimaExecucao AS
(
    SELECT
        h.job_id,
        h.run_status,
        msdb.dbo.agent_datetime(h.run_date, h.run_time) AS dh_ultima_execucao,
        ROW_NUMBER() OVER (PARTITION BY h.job_id ORDER BY h.run_date DESC, h.run_time DESC) AS rn
    FROM msdb.dbo.sysjobhistory AS h with(nolock)
    WHERE h.step_id = 0
),
Atividade AS
(
    SELECT
        ja.job_id,
        ja.run_requested_date,
        ja.start_execution_date,
        ja.stop_execution_date,
        ja.last_executed_step_id
    FROM msdb.dbo.sysjobactivity AS ja with(nolock)
    WHERE ja.session_id = (SELECT MAX(session_id) FROM msdb.dbo.sysjobactivity with(nolock))
)
SELECT
    j.name AS nm_job,
    j.enabled AS in_habilitado,
    CASE j.enabled WHEN 1 THEN N'Habilitado' ELSE N'Desabilitado' END AS ds_status_job,
    ue.dh_ultima_execucao,
    CASE ue.run_status
        WHEN 0 THEN N'Falhou'
        WHEN 1 THEN N'Sucesso'
        WHEN 2 THEN N'Retentativa'
        WHEN 3 THEN N'Cancelado'
        WHEN 4 THEN N'Em andamento'
        ELSE N'Desconhecido'
    END AS ds_ultima_execucao,
    ue.run_status AS cd_ultima_execucao,
    DATEDIFF(MINUTE, ue.dh_ultima_execucao, GETDATE()) AS qt_minutos_desde_ultima_execucao,
    CASE
        WHEN a.start_execution_date IS NOT NULL AND a.stop_execution_date IS NULL
        THEN 1 ELSE 0
    END AS in_em_execucao,
    CASE
        WHEN a.run_requested_date IS NOT NULL AND a.stop_execution_date IS NULL
             AND DATEDIFF(MINUTE, a.run_requested_date, GETDATE()) > 5
        THEN 1 ELSE 0
    END AS in_possivel_travado,
    a.run_requested_date AS dh_run_requested,
    a.start_execution_date AS dh_inicio_execucao,
    a.stop_execution_date AS dh_fim_execucao
FROM msdb.dbo.sysjobs AS j with(nolock)
LEFT JOIN UltimaExecucao AS ue
    ON ue.job_id = j.job_id
   AND ue.rn = 1
LEFT JOIN Atividade AS a
    ON a.job_id = j.job_id;
GO
