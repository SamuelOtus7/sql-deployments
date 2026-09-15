-- ============================================================
-- BASELINE: dbo.UspMonitoraConsultasLentas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMonitoraConsultasLentas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[UspMonitoraConsultasLentas]
    @TempoLimiteSegundos INT = 80  -- 1 minuto e 20 segundos
AS
BEGIN
    SET NOCOUNT ON;


    INSERT INTO dbo.LogConsultasLentas (SessionId, TempoExecucaoSegundos, TextoQuery, Banco, HostName, LoginName, Status)
    SELECT
        r.session_id,
        DATEDIFF(SECOND, r.start_time, GETDATE()) AS TempoExecucaoSegundos,
        SUBSTRING(
            t.text,
            (r.statement_start_offset / 2) + 1,
            ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(t.text) ELSE r.statement_end_offset END - r.statement_start_offset) / 2) + 1
        ) AS TextoQuery,
        DB_NAME(r.database_id) AS Banco,
        s.host_name,
        s.login_name,
        r.status
    FROM sys.dm_exec_requests r
    INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
    WHERE DATEDIFF(SECOND, r.start_time, GETDATE()) > @TempoLimiteSegundos
      AND r.session_id <> @@SPID;

    DECLARE @Qtde INT = (SELECT COUNT(*) FROM dbo.LogConsultasLentas WHERE DataRegistro >= DATEADD(MINUTE, -1, GETDATE()));

    IF @Qtde > 0
    BEGIN
        RAISERROR (
            N'?? Foram detectadas %d consultas executando há mais de %d segundos. 
             Verifique os detalhes em: SELECT * FROM dbo.LogConsultasLentas ORDER BY DataRegistro DESC;',
            16, 1, @Qtde, @TempoLimiteSegundos
        );
    END
    ELSE
    BEGIN
        PRINT 'Nenhuma consulta acima do tempo limite detectada.';
    END
END;
GO
