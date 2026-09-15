-- ============================================================
-- BASELINE: dbo.fncClassifica_ResourceGovernor
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fncClassifica_ResourceGovernor]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fncClassifica_ResourceGovernor]() 
RETURNS SYSNAME 
WITH SCHEMABINDING 
AS 
BEGIN 
        
    DECLARE @grp_name AS SYSNAME, @Usuario VARCHAR(200) = SUSER_NAME()
    
    IF (@Usuario in ('usr.mdo.guilherme.ferreira')) 
        SET @grp_name = 'GrupoClientesExternos'
    
    RETURN @grp_name 
 
END 
GO
