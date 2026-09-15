-- ============================================================
-- BASELINE: dbo.fn_DocumentoValidoFormatado
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_DocumentoValidoFormatado]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_DocumentoValidoFormatado] (@Doc VARCHAR(30))
RETURNS VARCHAR(18)
AS
BEGIN
    DECLARE @DOC_LIMPO VARCHAR(14)
    DECLARE @TAM INT

    -- Remove formatação
    SET @DOC_LIMPO = REPLACE(REPLACE(REPLACE(REPLACE(@Doc, '.', ''), '-', ''), '/', ''), ' ', '')
    SET @TAM = LEN(@DOC_LIMPO)

    --------------------------------------------------
    -- CPF
    --------------------------------------------------
    IF @TAM = 11
    BEGIN
        DECLARE @SOMA INT, @RESTO INT
        DECLARE @DIG1 INT, @DIG2 INT
        DECLARE @I INT

        -- CPFs inválidos conhecidos
        IF @DOC_LIMPO IN (
            '00000000000','11111111111','22222222222','33333333333',
            '44444444444','55555555555','66666666666','77777777777',
            '88888888888','99999999999'
        ) RETURN NULL

        -- Primeiro dígito
        SET @SOMA = 0
        SET @I = 1
        WHILE @I <= 9
        BEGIN
            SET @SOMA += CAST(SUBSTRING(@DOC_LIMPO, @I, 1) AS INT) * (11 - @I)
            SET @I += 1
        END

        SET @RESTO = @SOMA % 11
        SET @DIG1 = CASE WHEN @RESTO < 2 THEN 0 ELSE 11 - @RESTO END

        -- Segundo dígito
        SET @SOMA = 0
        SET @I = 1
        WHILE @I <= 10
        BEGIN
            SET @SOMA += CAST(SUBSTRING(@DOC_LIMPO, @I, 1) AS INT) * (12 - @I)
            SET @I += 1
        END

        SET @RESTO = @SOMA % 11
        SET @DIG2 = CASE WHEN @RESTO < 2 THEN 0 ELSE 11 - @RESTO END

        IF @DIG1 = CAST(SUBSTRING(@DOC_LIMPO, 10, 1) AS INT)
           AND @DIG2 = CAST(SUBSTRING(@DOC_LIMPO, 11, 1) AS INT)
        BEGIN
            -- Retorna formatado
            RETURN 
                SUBSTRING(@DOC_LIMPO,1,3) + '.' +
                SUBSTRING(@DOC_LIMPO,4,3) + '.' +
                SUBSTRING(@DOC_LIMPO,7,3) + '-' +
                SUBSTRING(@DOC_LIMPO,10,2)
        END

        RETURN NULL
    END

    --------------------------------------------------
    -- CNPJ
    --------------------------------------------------
    IF @TAM = 14
    BEGIN
        DECLARE @SOMA2 INT, @RESTO2 INT
        DECLARE @DIG1_CNPJ INT, @DIG2_CNPJ INT

        -- CNPJs inválidos conhecidos
        IF @DOC_LIMPO IN (
            '00000000000000','11111111111111','22222222222222','33333333333333',
            '44444444444444','55555555555555','66666666666666','77777777777777',
            '88888888888888','99999999999999'
        ) RETURN NULL

        -- Primeiro dígito CNPJ
        SET @SOMA2 =
            CAST(SUBSTRING(@DOC_LIMPO,1,1) AS INT) * 5 +
            CAST(SUBSTRING(@DOC_LIMPO,2,1) AS INT) * 4 +
            CAST(SUBSTRING(@DOC_LIMPO,3,1) AS INT) * 3 +
            CAST(SUBSTRING(@DOC_LIMPO,4,1) AS INT) * 2 +
            CAST(SUBSTRING(@DOC_LIMPO,5,1) AS INT) * 9 +
            CAST(SUBSTRING(@DOC_LIMPO,6,1) AS INT) * 8 +
            CAST(SUBSTRING(@DOC_LIMPO,7,1) AS INT) * 7 +
            CAST(SUBSTRING(@DOC_LIMPO,8,1) AS INT) * 6 +
            CAST(SUBSTRING(@DOC_LIMPO,9,1) AS INT) * 5 +
            CAST(SUBSTRING(@DOC_LIMPO,10,1) AS INT) * 4 +
            CAST(SUBSTRING(@DOC_LIMPO,11,1) AS INT) * 3 +
            CAST(SUBSTRING(@DOC_LIMPO,12,1) AS INT) * 2

        SET @RESTO2 = @SOMA2 % 11
        SET @DIG1_CNPJ = CASE WHEN @RESTO2 < 2 THEN 0 ELSE 11 - @RESTO2 END

        -- Segundo dígito CNPJ
        SET @SOMA2 =
            CAST(SUBSTRING(@DOC_LIMPO,1,1) AS INT) * 6 +
            CAST(SUBSTRING(@DOC_LIMPO,2,1) AS INT) * 5 +
            CAST(SUBSTRING(@DOC_LIMPO,3,1) AS INT) * 4 +
            CAST(SUBSTRING(@DOC_LIMPO,4,1) AS INT) * 3 +
            CAST(SUBSTRING(@DOC_LIMPO,5,1) AS INT) * 2 +
            CAST(SUBSTRING(@DOC_LIMPO,6,1) AS INT) * 9 +
            CAST(SUBSTRING(@DOC_LIMPO,7,1) AS INT) * 8 +
            CAST(SUBSTRING(@DOC_LIMPO,8,1) AS INT) * 7 +
            CAST(SUBSTRING(@DOC_LIMPO,9,1) AS INT) * 6 +
            CAST(SUBSTRING(@DOC_LIMPO,10,1) AS INT) * 5 +
            CAST(SUBSTRING(@DOC_LIMPO,11,1) AS INT) * 4 +
            CAST(SUBSTRING(@DOC_LIMPO,12,1) AS INT) * 3 +
            CAST(@DIG1_CNPJ AS INT) * 2

        SET @RESTO2 = @SOMA2 % 11
        SET @DIG2_CNPJ = CASE WHEN @RESTO2 < 2 THEN 0 ELSE 11 - @RESTO2 END

        IF @DIG1_CNPJ = CAST(SUBSTRING(@DOC_LIMPO,13,1) AS INT)
           AND @DIG2_CNPJ = CAST(SUBSTRING(@DOC_LIMPO,14,1) AS INT)
        BEGIN
            -- Retorna formatado
            RETURN 
                SUBSTRING(@DOC_LIMPO,1,2) + '.' +
                SUBSTRING(@DOC_LIMPO,3,3) + '.' +
                SUBSTRING(@DOC_LIMPO,6,3) + '/' +
                SUBSTRING(@DOC_LIMPO,9,4) + '-' +
                SUBSTRING(@DOC_LIMPO,13,2)
        END

        RETURN NULL
    END

    RETURN NULL
END
GO
