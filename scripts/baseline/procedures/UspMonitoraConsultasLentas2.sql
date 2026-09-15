-- ============================================================
-- BASELINE: dbo.UspMonitoraConsultasLentas2
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMonitoraConsultasLentas2]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspMonitoraConsultasLentas2]
    @TempoLimiteSegundos INT = 80  -- Padrão: 1m20s
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ListaSPIDs NVARCHAR(MAX);
    DECLARE @Qtde INT;

 
    INSERT INTO dbo.LogConsultasLentas (
        SessionId,
        TempoExecucaoSegundos,
        TextoQuery,
        Banco,
        HostName,
        LoginName,
        Status,
        StatusBloqueio,
        SpidBloqueadoPor,
        SpidsBloqueados
    )
    SELECT
        r.session_id AS SessionId,
        DATEDIFF(SECOND, r.start_time, GETDATE()) AS TempoExecucaoSegundos,
        SUBSTRING(
            t.text,
            (r.statement_start_offset / 2) + 1,
            ((CASE r.statement_end_offset
                WHEN -1 THEN DATALENGTH(t.text)
                ELSE r.statement_end_offset
              END - r.statement_start_offset) / 2) + 1
        ) AS TextoQuery,
        DB_NAME(r.database_id) AS Banco,
        s.host_name AS HostName,
        s.login_name AS LoginName,
        r.status AS Status,

        CASE 
            WHEN r.blocking_session_id IS NOT NULL 
                 AND r.blocking_session_id > 50
                 AND r.status NOT IN ('SUSPENDED') THEN 'Sendo bloqueado'
            WHEN EXISTS (
                SELECT 1 
                FROM sys.dm_exec_requests r2 
                WHERE r2.blocking_session_id = r.session_id
                      AND r2.status NOT IN ('SUSPENDED')
            ) THEN 'Bloqueando outros'
            ELSE 'Livre'
        END AS StatusBloqueio,

        CASE 
            WHEN r.blocking_session_id > 50 THEN r.blocking_session_id
            ELSE NULL
        END AS SpidBloqueadoPor,

        STUFF((
            SELECT ',' + CAST(r2.session_id AS NVARCHAR(10))
            FROM sys.dm_exec_requests r2
            WHERE r2.blocking_session_id = r.session_id
                  AND r2.status NOT IN ('SUSPENDED')
            FOR XML PATH('')
        ), 1, 1, '') AS SpidsBloqueados

    FROM sys.dm_exec_requests r
    INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
    WHERE 
        DATEDIFF(SECOND, r.start_time, GETDATE()) > @TempoLimiteSegundos
        AND r.session_id > 50  -- só pega SPIDs reais
        AND r.session_id <> @@SPID
        AND s.is_user_process = 1
        AND NOT EXISTS (
            SELECT 1 FROM dbo.LogConsultasLentas x 
            WHERE x.SessionId = r.session_id
              AND x.DataRegistro >= DATEADD(MINUTE, -5, GETDATE())
        );


    SELECT @ListaSPIDs = STRING_AGG(CONVERT(VARCHAR(10), session_id), ', ')
    FROM sys.dm_exec_requests
    WHERE 
        DATEDIFF(SECOND, start_time, GETDATE()) > @TempoLimiteSegundos
        AND session_id > 50
        AND session_id <> @@SPID;


    SET @Qtde = (
        SELECT COUNT(*) 
        FROM dbo.LogConsultasLentas 
        WHERE DataRegistro >= DATEADD(MINUTE, -1, GETDATE())
    );



END;
GO
