-- ============================================================
-- BASELINE: dbo.fn_only_numbers
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_only_numbers]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_only_numbers] (@Texto VARCHAR(MAX))
RETURNS bigint
AS
BEGIN
    WHILE PATINDEX('%[^0-9]%', @Texto) > 0
        SET @Texto = STUFF(@Texto, PATINDEX('%[^0-9]%', @Texto), 1, '');
    RETURN cast(@Texto as bigint);
END;
GO
