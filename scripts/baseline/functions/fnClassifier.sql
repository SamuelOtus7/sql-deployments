-- ============================================================
-- BASELINE: dbo.fnClassifier
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fnClassifier]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnClassifier]()
RETURNS SYSNAME
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @group_name SYSNAME;

    IF SUSER_NAME() = 'usr.ls.imediato'
        SET @group_name = 'wg_usr_imediato';
    ELSE
        SET @group_name = 'default';

    RETURN @group_name;
END;
GO
