-- ============================================================
-- BASELINE: dbo.fn_remove_acentuacao
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_remove_acentuacao]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_remove_acentuacao](
    @String VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    
    /****************************************************************************************************************/
    /** RETIRA ACENTUAÇÃO DAS VOGAIS **/
    /****************************************************************************************************************/
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@String,'á','a'),'à','a'),'â','a'),'ã','a'),'ä','a')
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(@String,'é','e'),'è','e'),'ê','e'),'ë','e')
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(@String,'í','i'),'ì','i'),'î','i'),'ï','i')
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@String,'ó','o'),'ò','o'),'ô','o'),'õ','o'),'ö','o')
    SET @String = REPLACE(REPLACE(REPLACE(REPLACE(@String,'ú','u'),'ù','u'),'û','u'),'ü','u')
    
    /****************************************************************************************************************/
    /** RETIRA ACENTUAÇÃO DAS CONSOANTES **/
    /****************************************************************************************************************/
    SET @String = REPLACE(@String,'ý','y')
    SET @String = REPLACE(@String,'ñ','n')
    SET @String = REPLACE(@String,'ç','c')
    
    RETURN (@String)

END
GO
