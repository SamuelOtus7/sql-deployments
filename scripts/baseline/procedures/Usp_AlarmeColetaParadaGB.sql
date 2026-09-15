-- ============================================================
-- BASELINE: dbo.Usp_AlarmeColetaParadaGB
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeColetaParadaGB]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_AlarmeColetaParadaGB] as 

DECLARE @tolerancia_minutos INT = 15;

DROP TABLE IF EXISTS #aux;
CREATE TABLE #aux (
	id				int identity not null,
    Transportadora VARCHAR(30) NOT NULL,
    UltimaEscrita DATETIME NULL,
    Tipo VARCHAR(100) NOT NULL
);

--INSERT INTO #aux
--SELECT 
--    Transportadora, 
--    ISNULL(UltimaEscritaTotalizador, getdate()),
--    'Totalizador Mercado Livre' AS Tipo
--FROM 
--    vw_monitoramento_mercadolivre
--WHERE
--    DATEDIFF(MINUTE, ISNULL(UltimaEscritaTotalizador, '1900-12-31'), GETDATE()) >=  @tolerancia_minutos;

INSERT INTO #aux
SELECT 
    Transportadora, 
    ISNULL(UltimaEscritaRotas, getdate()),
    'Rotas Mercado Livre' AS Tipo
FROM 
    vw_monitoramento_mercadolivre
WHERE
    DATEDIFF(MINUTE, ISNULL(UltimaEscritaRotas, '1900-12-31'), GETDATE()) >= @tolerancia_minutos;

IF EXISTS (SELECT * FROM #aux)
BEGIN
    DECLARE @coleta VARCHAR(1000);
    DECLARE @mensagem VARCHAR(2000);

    SELECT  @coleta = SUBSTRING( 
      ( 
        SELECT CHAR(10) + Transportadora + char(10)+ char(10) AS 'data()' 
        FROM #aux 
        FOR XML PATH('') 
    ), 2 , 9999);

    SET @mensagem = '*[Coleta Parada]*' +  CHAR(10)
        + 'As Transportadoras abaixo estão a mais de ' + CAST(@tolerancia_minutos AS VARCHAR(15)) + ' minutos sem atualizar: ' +  CHAR(10) +  CHAR(10) 
        + @coleta  +  CHAR(10) +  CHAR(10)
--select @mensagem
    RAISERROR(@mensagem, 16, 1);
END;

GO
