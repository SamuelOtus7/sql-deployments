-- ============================================================
-- BASELINE: dbo.fn_valor_extenso
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_valor_extenso]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_valor_extenso] (@valor DECIMAL(18, 2))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @reais INT = FLOOR(@valor); -- Parte inteira
    DECLARE @centavos INT = ROUND((@valor - @reais) * 100, 0); -- Parte decimal
    DECLARE @extenso NVARCHAR(MAX) = '';

    -- Verificação para evitar retornos nulos
    IF @valor IS NULL RETURN NULL;

    -- Parte dos reais
    IF @reais > 0
    BEGIN
        SET @extenso = 
            CASE 
                WHEN @reais < 1000 THEN dbo.fn_convert_number(@reais) -- Até centenas
                WHEN @reais BETWEEN 1000 AND 1999 THEN 'MIL' -- Exatamente 1000
                WHEN @reais >= 2000 THEN dbo.fn_convert_number(FLOOR(@reais / 1000)) + ' MIL' -- Milhares maiores
            END;

        -- Adiciona o resto dos reais (depois de milhares)
        IF @reais >= 1000 AND @reais % 1000 > 0
            SET @extenso = @extenso + ' ' + dbo.fn_convert_number(@reais % 1000);

        -- Adiciona a palavra "REAIS"
        SET @extenso = @extenso + ' REAIS';
    END;

    -- Parte dos centavos
    IF @centavos > 0
        SET @extenso = @extenso + 
            CASE 
                WHEN @reais > 0 THEN ' E '
                ELSE ''
            END + 
            CASE
                WHEN @centavos = 1 THEN 'UM CENTAVO'
                ELSE dbo.fn_convert_number(@centavos) + ' CENTAVOS'
            END;

    RETURN @extenso;
END;
GO
