-- ============================================================
-- BASELINE: dbo.fc_ExtrairNumeros
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fc_ExtrairNumeros]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fc_ExtrairNumeros] (@texto NVARCHAR(MAX))
RETURNS BIGINT
AS
BEGIN
    DECLARE @numeros NVARCHAR(MAX) = ''
    DECLARE @i INT = 1
    DECLARE @len INT = LEN(@texto)
    DECLARE @char CHAR(1)

    WHILE @i <= @len
    BEGIN
        SET @char = SUBSTRING(@texto, @i, 1)
        IF @char LIKE '[0-9]'
            SET @numeros = @numeros + @char
        SET @i = @i + 1
    END

    RETURN TRY_CAST(@numeros AS BIGINT)
END
GO
