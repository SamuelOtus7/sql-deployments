-- ============================================================
-- BASELINE: dbo.UspAlertaJobFalha
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAlertaJobFalha]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspAlertaJobFalha]

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @jobsComFalha TABLE (
        job_id UNIQUEIDENTIFIER,
        job_name NVARCHAR(128),
        run_date INT,
        run_time INT,
        message NVARCHAR(MAX),
        data_hora_falha DATETIME
    );

    -- Captura falhas nos últimos 10 minutos, exceto o job que não deve alarmar
    INSERT INTO @jobsComFalha
    SELECT 
        j.job_id,
        j.name,
        h.run_date,
        h.run_time,
        h.message,
        DATEADD(
            SECOND,
            h.run_time % 100
            + ((h.run_time / 100) % 100) * 60
            + (h.run_time / 10000) * 3600,
            CAST(CONVERT(CHAR(8), h.run_date) AS DATETIME)
        ) AS data_hora_falha
    FROM msdb.dbo.sysjobhistory h
    JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id
    WHERE h.run_status = 0       -- falha
      AND h.step_id > 0          -- só passos (não o resumo do job)
	  AND (
    (j.name LIKE '%DriveAnalytics%' OR j.name LIKE '%Irisys%')
    AND j.name <> 'DriveAnalytics - Atualiza Usuario Irisys')  -- IGNORA este job
      AND DATEADD(
            SECOND,
            h.run_time % 100
            + ((h.run_time / 100) % 100) * 60
            + (h.run_time / 10000) * 3600,
            CAST(CONVERT(CHAR(8), h.run_date) AS DATETIME)
          ) >= DATEADD(MINUTE, -10, GETDATE());

    DECLARE @job_id UNIQUEIDENTIFIER;
    DECLARE @job_name NVARCHAR(128);
    DECLARE @data_hora_falha DATETIME;
    DECLARE @mensagem NVARCHAR(MAX);

    DECLARE c CURSOR FOR
        SELECT job_id, job_name, data_hora_falha, message
        FROM @jobsComFalha;

    OPEN c;
    FETCH NEXT FROM c INTO @job_id, @job_name, @data_hora_falha, @mensagem;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Somente alarma se não houve sucesso dentro de 5 minutos após a falha
        IF NOT EXISTS (
            SELECT 1
            FROM msdb.dbo.sysjobhistory h
            WHERE h.job_id = @job_id
              AND h.run_status = 1 -- sucesso
              AND h.step_id > 0
              AND DATEADD(
                    SECOND,
                    h.run_time % 100
                    + ((h.run_time / 100) % 100) * 60
                    + (h.run_time / 10000) * 3600,
                    CAST(CONVERT(CHAR(8), h.run_date) AS DATETIME)
                  ) BETWEEN @data_hora_falha AND DATEADD(MINUTE, 5, @data_hora_falha)
        )
        BEGIN
            RAISERROR('Job [%s] falhou e não se recuperou em 5 minutos. Erro: %s', 16, 1, @job_name, @mensagem);
        END

        FETCH NEXT FROM c INTO @job_id, @job_name, @data_hora_falha, @mensagem;
    END

    CLOSE c;
    DEALLOCATE c;
END;
GO
