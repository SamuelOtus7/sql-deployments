-- ============================================================
-- BASELINE: dbo.Usp_AlarmeConexaoFlexFrota
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeConexaoFlexFrota]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[Usp_AlarmeConexaoFlexFrota] as

DROP TABLE IF EXISTS #base;

	
		
IF (SELECT MAX(iev_dh_data_hora_evento) FROM tb_integracao_flex_eventos) <= DATEADD(DAY, -2, GETDATE())
BEGIN


    RAISERROR ('Estamos sem receber registros da API Flex Frota Há mais de 2 dias, verificar com o time de DEV/Dados a conexão',16,1);
END
ELSE
BEGIN
    PRINT 'OK';
END;
GO
