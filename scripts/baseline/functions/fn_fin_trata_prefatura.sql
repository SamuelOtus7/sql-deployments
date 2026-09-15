-- ============================================================
-- BASELINE: dbo.fn_fin_trata_prefatura
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_fin_trata_prefatura]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 26/03/2023
-- Alter by: Gabriel Ramos
-- Alter date: 25/02/2025
-- Description:	Trata a coluna descrição vinda do pre-fatura do mercado livre
-- Alter Description: Incluida a tratativa "Verificar se @Descricao é NULL ou vazia"
--Tipos:
	--1- Veiculo
	--2- ContinuacaoVeiculo
	--3- Service Center
	--4- Range
	--5- Dia
	--6- KMs RANGE / Ciclo
-- =============================================
CREATE FUNCTION [dbo].[fn_fin_trata_prefatura]
(
    @Descricao VARCHAR(100),
    @Tipo INT
)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @retorno VARCHAR(100) = NULL;
    DECLARE @veiculo VARCHAR(100);
    DECLARE @continuacao_veiculo VARCHAR(100);
    DECLARE @inicio VARCHAR(100);
    DECLARE @cont_hifen TINYINT;
    DECLARE @posicao_caracter INT;

    -- Verificar se @Descricao é NULL ou vazia
    IF @Descricao IS NULL OR LTRIM(RTRIM(@Descricao)) = ''
    BEGIN
        RETURN NULL;
    END

   -- Veículo
    IF @Tipo = 1
    BEGIN
        SET @posicao_caracter = CHARINDEX(' - ', @Descricao);
        IF @posicao_caracter > 0
        BEGIN
            SET @veiculo = LEFT(@Descricao, @posicao_caracter - 1);
            SET @retorno = replace(@veiculo,'"','VEICULO SEM CADASTRO - PREFATURA');
        END
    END

    -- Continuação Veículo
    IF @Tipo = 2
    BEGIN
        SET @posicao_caracter = CHARINDEX(':', @Descricao);
        IF @posicao_caracter > 0
        BEGIN
            SET @inicio = LEFT(@Descricao, @posicao_caracter - 1);
            SET @cont_hifen = LEN(@inicio) - LEN(REPLACE(@inicio, '-', ''));

            IF @cont_hifen = 2
            BEGIN
                SET @veiculo = LEFT(@inicio, CHARINDEX(' - ', @inicio) - 1);
                SET @continuacao_veiculo = REPLACE(@inicio, @veiculo + ' - ', '');

                IF CHARINDEX(' - ', @continuacao_veiculo) > 0
                BEGIN
                    SET @continuacao_veiculo = LEFT(@continuacao_veiculo, CHARINDEX(' - ', @continuacao_veiculo) - 1);
                    SET @retorno = @continuacao_veiculo;
                END
            END
        END
    END

    -- Service Center
    IF @Tipo = 3
    BEGIN
        SET @posicao_caracter = CHARINDEX(':', @Descricao);
        IF @posicao_caracter > 0
        BEGIN
            SET @inicio = LTRIM(RIGHT(@Descricao, LEN(@Descricao) - @posicao_caracter));
            SET @retorno = CASE
                WHEN CHARINDEX(' ', @inicio) >= 1 THEN LEFT(@inicio, CHARINDEX(' ', @inicio) - 1)
                ELSE @inicio
            END;
        END
    END

    -- Range
    IF @Tipo = 4
    BEGIN
        SET @posicao_caracter = CHARINDEX('RANGE: ', @Descricao);
        IF @posicao_caracter > 0
        BEGIN
            SET @inicio = RIGHT(@Descricao, LEN(@Descricao) - @posicao_caracter - 6);
            SET @retorno = CASE
                WHEN CHARINDEX(' ', @inicio) >= 1 THEN LEFT(@inicio, CHARINDEX(' ', @inicio) - 1)
                ELSE @inicio
            END;
        END
    END

    -- Dia
    IF @Tipo = 5
    BEGIN
        IF @Descricao LIKE '%SATURDAY DAY ROUTE%'
            SET @retorno = 'Sábado';
        ELSE IF @Descricao LIKE '%HOLIDAY DAY ROUTE%'
            SET @retorno = 'Domingo';
    END

    -- KMs RANGE / Ciclo
    IF @Tipo = 6
    BEGIN
        SET @posicao_caracter = CHARINDEX(':', @Descricao);
        IF @posicao_caracter > 0
        BEGIN
            SET @inicio = LTRIM(RIGHT(@Descricao, LEN(@Descricao) - @posicao_caracter));
            IF CHARINDEX(' - ', @inicio) > 0
            BEGIN
                SET @inicio = LTRIM(RIGHT(@inicio, LEN(@inicio) - CHARINDEX(' - ', @inicio) - 2));
                SET @inicio = CASE
                    WHEN CHARINDEX(':', @inicio) >= 1 THEN LEFT(@inicio, CHARINDEX(':', @inicio) - 1)
                    ELSE @inicio
                END;
                SET @retorno = CASE
                    WHEN CHARINDEX(' - ', @inicio) > 0 THEN LEFT(@inicio, CHARINDEX(' - ', @inicio) - 1)
                    ELSE @inicio
                END;
            END
        END
    END

    RETURN LTRIM(RTRIM(replace(@retorno,'"','')));

END;
GO
