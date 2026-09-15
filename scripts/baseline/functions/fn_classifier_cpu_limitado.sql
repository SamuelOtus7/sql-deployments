-- ============================================================
-- BASELINE: dbo.fn_classifier_cpu_limitado
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_classifier_cpu_limitado]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_classifier_cpu_limitado]()
RETURNS SYSNAME
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grupo SYSNAME;

    IF SUSER_NAME() = 'usr.mdo.guilherme.ferreira'
        SET @grupo = 'grupo_cpu_limitado';
    ELSE
        SET @grupo = 'default'; -- Ou outro grupo padrão

    RETURN @grupo;
END;
GO
