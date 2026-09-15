-- ============================================================
-- BASELINE: dbo.Usp_AlarmeCidadeDistante_GB
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeCidadeDistante_GB]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[Usp_AlarmeCidadeDistante_GB] as

DROP TABLE IF EXISTS #base;

SELECT 
    cli_ds_nome,
    dataReferencia,
    COUNT(*) AS qtd
INTO #base
FROM vw_rotas AS a
INNER JOIN tb_clientes AS b
    ON cli_id_logistics = idtransportadora
WHERE dataReferencia BETWEEN '2025-02-21' AND GETDATE()
-- AND cli_ds_nome = 'Flight Cargo'
AND CidadeDistante IS NULL
GROUP BY cli_ds_nome, dataReferencia
HAVING COUNT(*) > 0
ORDER BY 1, dataReferencia;


IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dataReferencia, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), qtd ) + CHAR(10)
    FROM #base;


    RAISERROR ('Faltando CidadeDistante para os seguintes clientes e datas:%s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;
GO
