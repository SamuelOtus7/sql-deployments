-- ============================================================
-- BASELINE: dbo.ExcelSerialToDate
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[ExcelSerialToDate]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ExcelSerialToDate] (@Serial INT)
RETURNS DATE
AS
BEGIN
    -- Ajuste do bug do Excel (29/02/1900 inexistente)
    RETURN DATEADD(DAY, @Serial - 2, '19000101');
END;
GO
