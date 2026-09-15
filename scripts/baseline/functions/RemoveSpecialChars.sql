-- ============================================================
-- BASELINE: dbo.RemoveSpecialChars
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[RemoveSpecialChars]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[RemoveSpecialChars] (@Input NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(MAX) = ''
    DECLARE @Index INT = 1
    DECLARE @Char CHAR(1)

    WHILE @Index <= LEN(@Input)
    BEGIN
        SET @Char = SUBSTRING(@Input, @Index, 1)
        -- Mantém apenas letras, números e espaços
        IF @Char LIKE '[A-Za-z0-9 ]'
            SET @Result += @Char
        SET @Index += 1
    END

    RETURN @Result
END
GO
