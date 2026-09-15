-- ============================================================
-- BASELINE: dbo.UspSPE_AlarmePacotesSemEscrever
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPE_AlarmePacotesSemEscrever]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[UspSPE_AlarmePacotesSemEscrever] as 

DECLARE @dataref DATE = GETDATE(),
        @QTDref INT = 1,
        @QTDParada INT;

DROP TABLE IF EXISTS #tabela;

SELECT 
    cli_ds_nome,
    IdTransportadora,
    DATEDIFF(MINUTE, MAX(DataHoraColeta), GETDATE()) AS MinutosSemEscrever
INTO #tabela
FROM tb_spe_pacotes_v5 AS a WITH (ROWLOCK, READPAST, UPDLOCK)
LEFT JOIN tb_clientes AS b
    ON IdTransportadora = cli_id_shopee
WHERE 
    DataReferencia >= getdate()
    AND cli_in_ativo = 1
    AND cli_ds_nome NOT IN ('Otus7', 'Pralog', 'Torres Transportes', 'Eco Express', 'Avista', 'ALC Transportes', 'Flashlog')
GROUP BY cli_ds_nome, IdTransportadora;

-- Verifica se há algum cliente sem escrita há mais de 15 minutos
SELECT @QTDParada = COUNT(*)
FROM #tabela
WHERE MinutosSemEscrever > 15;

-- Se houver pelo menos 1, gera mensagem geral
IF @QTDParada >= @QTDref
BEGIN
    DECLARE @mensagem VARCHAR(2000);

    SET @mensagem = 'SPE - Estamos há mais de 15 minutos sem escrita na tabela tb_spe_pacotes_v5.';

    RAISERROR(@mensagem, 16, 1);
END;


/*
IF @QTDParada >= @QTDref
BEGIN
    DECLARE @coleta VARCHAR(1000);
    DECLARE @mensagem VARCHAR(2000) = '';
    DECLARE @texto VARCHAR(2000);
	DECLARE @msg NVARCHAR(MAX) = 'Os cleintes abaixo estao sem escrever dados de rotas a mais de 15 minutos na tb_spe_pacotes_v5: ';
    

	SELECT @mensagem = @msg + COALESCE(@mensagem + CHAR(10), '') + ' ' + cli_ds_nome 
    FROM #tabela
	where MinutosSemEscrever > 10;

    RAISERROR(@mensagem , 16, 1);
END;

*/
GO
