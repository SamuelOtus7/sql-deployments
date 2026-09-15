-- ============================================================
-- BASELINE: dbo.fn_ExtrairDataDeTexto
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_ExtrairDataDeTexto]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_ExtrairDataDeTexto] (@Texto NVARCHAR(MAX))
RETURNS DATETIME
AS
BEGIN
    DECLARE @DataTexto NVARCHAR(30);
    DECLARE @PosicaoInicio INT;

    -- Localiza o primeiro dígito (ano)
    SET @PosicaoInicio = PATINDEX('%[0-9][0-9][0-9][0-9]-%', @Texto);

    -- Extrai a parte da data/hora (formato ISO 8601)
    SET @DataTexto = SUBSTRING(@Texto, @PosicaoInicio, 25);

    -- Converte para datetime
    RETURN TRY_CAST(@DataTexto AS DATETIME);
END;

GO
