-- ============================================================
-- BASELINE: dbo.DecodeJWT
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[DecodeJWT]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 2. Criação da função para decodificar JWT
CREATE   FUNCTION [dbo].[DecodeJWT] (@jwt NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
    WITH TokenParts AS (
        SELECT 
            CHARINDEX('.', @jwt) AS FirstDot,
            CHARINDEX('.', @jwt, CHARINDEX('.', @jwt) + 1) AS SecondDot
    )
    SELECT 
        dbo.DecodeBase64Url(SUBSTRING(@jwt, 1, FirstDot - 1)) AS HeaderJSON,
        dbo.DecodeBase64Url(SUBSTRING(@jwt, FirstDot + 1, SecondDot - FirstDot - 1)) AS PayloadJSON
    FROM TokenParts
)
GO
