-- ============================================================
-- BASELINE: dbo.TratarCEP
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[TratarCEP]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TratarCEP] (@CEP VARCHAR(8))
RETURNS INT
AS
BEGIN
    RETURN CAST(
        CASE 
            WHEN LEN(@CEP) = 3 THEN @CEP + '00000'
            WHEN LEN(@CEP) = 4 THEN @CEP + '0000'
            WHEN LEN(@CEP) = 5 THEN @CEP + '000'
            WHEN LEN(@CEP) = 6 THEN @CEP + '00'
            WHEN LEN(@CEP) = 7 THEN @CEP + '0'
            ELSE @CEP
        END AS INT
    );
END;
GO
