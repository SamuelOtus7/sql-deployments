-- ============================================================
-- BASELINE: dbo.vw_Jobs_Rodando_30Min
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_Jobs_Rodando_30Min]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_Jobs_Rodando_30Min]
AS
SELECT 
    j.name AS NomeJob,
    ja.start_execution_date AS InicioExecucao,
    DATEDIFF(MINUTE, ja.start_execution_date, GETDATE()) AS MinutosRodando,
    s.step_name AS EtapaAtual
FROM msdb.dbo.sysjobactivity ja with(nolock)
JOIN msdb.dbo.sysjobs j  with(nolock)
    ON ja.job_id = j.job_id
LEFT JOIN msdb.dbo.sysjobsteps s  with(nolock)
    ON j.job_id = s.job_id 
    AND ja.last_executed_step_id = s.step_id
WHERE 
    ja.start_execution_date IS NOT NULL
    AND ja.stop_execution_date IS NULL
    AND DATEDIFF(MINUTE, ja.start_execution_date, GETDATE()) > 30;
GO
