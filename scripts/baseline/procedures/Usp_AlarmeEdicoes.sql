-- ============================================================
-- BASELINE: dbo.Usp_AlarmeEdicoes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeEdicoes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[Usp_AlarmeEdicoes] as

DROP TABLE IF EXISTS #base;

SELECT 
    a.CLI_DS_NOME,
    a.DATALOG AS InicioJanela,
    DATEADD(MINUTE, 60, a.DATALOG) AS FimJanela,
    COUNT(*) AS QtdEdicoes
    into #base
FROM vw_LogProcessamentoFinanceiro a
JOIN vw_LogProcessamentoFinanceiro b
    ON a.CLI_DS_NOME = b.CLI_DS_NOME
   AND b.DATALOG BETWEEN a.DATALOG AND DATEADD(MINUTE, 60, a.DATALOG)
WHERE a.identificador <> 'GERAL'
  AND b.identificador <> 'GERAL'
  AND CAST(a.DATALOG AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY a.CLI_DS_NOME, a.DATALOG
HAVING COUNT(*) > 30
ORDER BY a.CLI_DS_NOME, a.DATALOG;

IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), InicioJanela, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), QtdEdicoes ) + CHAR(10)
    FROM #base;


    RAISERROR ('Ocorreram mais de 30 alterações no intervalo determinado para os casos abaixo: %s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;
GO
