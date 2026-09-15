-- ============================================================
-- BASELINE: dbo.fn_convert_number
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_convert_number]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_convert_number] (@number INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Inicializa o valor de retorno
    DECLARE @extenso NVARCHAR(MAX) = '';

    -- Números básicos de 1 a 19
    IF @number BETWEEN 1 AND 19
        SET @extenso = 
            CASE @number
                WHEN 1 THEN 'UM'
                WHEN 2 THEN 'DOIS'
                WHEN 3 THEN 'TRÊS'
                WHEN 4 THEN 'QUATRO'
                WHEN 5 THEN 'CINCO'
                WHEN 6 THEN 'SEIS'
                WHEN 7 THEN 'SETE'
                WHEN 8 THEN 'OITO'
                WHEN 9 THEN 'NOVE'
                WHEN 10 THEN 'DEZ'
                WHEN 11 THEN 'ONZE'
                WHEN 12 THEN 'DOZE'
                WHEN 13 THEN 'TREZE'
                WHEN 14 THEN 'QUATORZE'
                WHEN 15 THEN 'QUINZE'
                WHEN 16 THEN 'DEZESSEIS'
                WHEN 17 THEN 'DEZESSETE'
                WHEN 18 THEN 'DEZOITO'
                WHEN 19 THEN 'DEZENOVE'
            END;

    -- Números entre 20 e 99
    ELSE IF @number BETWEEN 20 AND 99
        SET @extenso = 
            CASE (FLOOR(@number / 10)) -- Obtem a dezena
                WHEN 2 THEN 'VINTE'
                WHEN 3 THEN 'TRINTA'
                WHEN 4 THEN 'QUARENTA'
                WHEN 5 THEN 'CINQUENTA'
                WHEN 6 THEN 'SESSENTA'
                WHEN 7 THEN 'SETENTA'
                WHEN 8 THEN 'OITENTA'
                WHEN 9 THEN 'NOVENTA'
            END + 
            CASE 
                WHEN @number % 10 > 0 THEN ' E ' + dbo.fn_convert_number(@number % 10)
                ELSE ''
            END;

    -- Números maiores (exemplo básico para centenas)
    ELSE IF @number BETWEEN 100 AND 999
        SET @extenso = 
            CASE (FLOOR(@number / 100)) -- Obtem a centena
                WHEN 1 THEN 'CENTO'
                WHEN 2 THEN 'DUZENTOS'
                WHEN 3 THEN 'TREZENTOS'
                WHEN 4 THEN 'QUATROCENTOS'
                WHEN 5 THEN 'QUINHENTOS'
                WHEN 6 THEN 'SEISCENTOS'
                WHEN 7 THEN 'SETECENTOS'
                WHEN 8 THEN 'OITOCENTOS'
                WHEN 9 THEN 'NOVECENTOS'
            END + 
            CASE 
                WHEN @number % 100 > 0 THEN ' E ' + dbo.fn_convert_number(@number % 100)
                ELSE ''
            END;

    RETURN @extenso;
END;
GO
