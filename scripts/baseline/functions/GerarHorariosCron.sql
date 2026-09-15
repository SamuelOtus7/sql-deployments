-- ============================================================
-- BASELINE: dbo.GerarHorariosCron
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[GerarHorariosCron]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GerarHorariosCron] (
    @cron VARCHAR(50),
    @data DATE
)
RETURNS @horarios TABLE (
    horario DATETIME
)
AS
BEGIN
    DECLARE @minInit INT = 0,
            @minStep INT = 60,
            @hourInit INT = 0,
            @hourEnd INT = 23,
            @hourStep INT = 1;

    IF @cron IS NULL RETURN;

    -- Parse básico
    -- Exemplo: '0/30 9-21 * * *'
    IF @cron LIKE '0/%'
    BEGIN
        -- Minuto inicial + step
        SET @minStep = TRY_CAST(SUBSTRING(@cron, 3, CHARINDEX(' ', @cron) - 3) AS INT);
    END
    ELSE IF @cron LIKE '0 %'
    BEGIN
        SET @minStep = 60;
    END

    -- Hora inicial, final e passo
    DECLARE @horaPart VARCHAR(20) = LTRIM(RTRIM(SUBSTRING(@cron, CHARINDEX(' ', @cron) + 1, LEN(@cron))));
    SET @horaPart = LEFT(@horaPart, CHARINDEX(' ', @horaPart) - 1);

    IF @horaPart LIKE '%-%/%'
    BEGIN
        SET @hourInit = TRY_CAST(LEFT(@horaPart, CHARINDEX('-', @horaPart) - 1) AS INT);
        SET @hourEnd = TRY_CAST(SUBSTRING(@horaPart, CHARINDEX('-', @horaPart) + 1, CHARINDEX('/', @horaPart) - CHARINDEX('-', @horaPart) - 1) AS INT);
        SET @hourStep = TRY_CAST(RIGHT(@horaPart, LEN(@horaPart) - CHARINDEX('/', @horaPart)) AS INT);
    END
    ELSE IF @horaPart LIKE '%-%'
    BEGIN
        SET @hourInit = TRY_CAST(LEFT(@horaPart, CHARINDEX('-', @horaPart) - 1) AS INT);
        SET @hourEnd = TRY_CAST(RIGHT(@horaPart, LEN(@horaPart) - CHARINDEX('-', @horaPart)) AS INT);
        SET @hourStep = 1;
    END
    ELSE
    BEGIN
        SET @hourInit = TRY_CAST(@horaPart AS INT);
        SET @hourEnd = @hourInit;
    END

    DECLARE @h INT = @hourInit;
    WHILE @h <= @hourEnd
    BEGIN
        DECLARE @m INT = 0;
        WHILE @m < 60
        BEGIN
            IF (@m % @minStep = 0)
            BEGIN
                INSERT INTO @horarios (horario)
                VALUES (DATEADD(MINUTE, @m, DATEADD(HOUR, @h, CAST(@data AS DATETIME))))
            END
            SET @m += @minStep;
        END
        SET @h += @hourStep;
    END

    RETURN;
END
GO
