-- ============================================================
-- BASELINE: dbo.UspDBColetaBloqueios
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspDBColetaBloqueios]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspDBColetaBloqueios]  as

insert into [tb_monitoramento_bloqueios]
SELECT
    r.session_id,
	wait_resource,
    s.login_name,
    s.host_name,
    s.program_name,
    DB_NAME(r.database_id) AS database_name,
    r.status,
    r.command,
    r.wait_type,
    r.wait_time,
    r.blocking_session_id,
    t.text AS executing_query,
    qp.query_plan,
	getdate() DataAtualizacao


FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) qp
WHERE 
r.status = 'suspended'
--AND r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;
GO
