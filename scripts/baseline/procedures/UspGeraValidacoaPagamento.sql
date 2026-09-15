-- ============================================================
-- BASELINE: dbo.UspGeraValidacoaPagamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraValidacoaPagamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraValidacoaPagamento] as 

-- Tabela temporária para armazenar os períodos por cliente
IF OBJECT_ID('tempdb..#periodos_clientes') IS NOT NULL DROP TABLE #periodos_clientes;

SELECT 
    pgp_cd_cliente,
    MAX(pgp_cd_periodo) AS ultimo_periodo
INTO #periodos_clientes
FROM tb_pgto_periodo
where pgp_in_ativo =1
and pgp_cd_cliente <> 11
GROUP BY pgp_cd_cliente;

-- Cursor para percorrer cliente por cliente com seu respectivo período
DECLARE @cliente INT, @periodo INT;

DECLARE c CURSOR FOR
SELECT pgp_cd_cliente, ultimo_periodo
FROM #periodos_clientes;

OPEN c;
FETCH NEXT FROM c INTO @cliente, @periodo;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Processando Cliente: ' + CAST(@cliente AS VARCHAR) + ' | Período: ' + CAST(@periodo AS VARCHAR);

    -- Aqui você chama a procedure ajustada para gravar na tabela nova
    EXEC UspFinGeraPagamento_Validacao @periodo

    FETCH NEXT FROM c INTO @cliente, @periodo;
END;

CLOSE c;
DEALLOCATE c;

DROP TABLE #periodos_clientes;


SELECT 
   
    p.ppr_cd_periodo,
	count(*) qtd ,
    -- Valores da produção
    sum(p.ppr_vl_total)  AS vl_total_producao,
    sum(n.ppr_vl_total)  AS vl_total_novo,

    -- Diferença total
    sum(ABS(p.ppr_vl_total - n.ppr_vl_total)) AS diff_total,
	
    -- Diagnóstico de colunas diferentes
    RTRIM(
        CASE WHEN ABS(ISNULL(p.ppr_vl_base, 0) - ISNULL(n.ppr_vl_base, 0)) > 0.01 THEN 'ppr_vl_base, ' ELSE '' END +
        CASE WHEN ABS(ISNULL(p.ppr_vl_bonus, 0) - ISNULL(n.ppr_vl_bonus, 0)) > 0.01 THEN 'ppr_vl_bonus, ' ELSE '' END +
        --CASE WHEN ABS(ISNULL(p.ppr_vl_adicional, 0) - ISNULL(n.ppr_vl_adicional, 0)) > 0.01 THEN 'ppr_vl_adicional, ' ELSE '' END +
        CASE WHEN ABS(ISNULL(p.ppr_vl_aluguel, 0) - ISNULL(n.ppr_vl_aluguel, 0)) > 0.01 THEN 'ppr_vl_aluguel, ' ELSE '' END +
        --CASE WHEN ABS(ISNULL(p.ppr_vl_assiduidade, 0) - ISNULL(n.ppr_vl_assiduidade, 0)) > 0.01 THEN 'ppr_vl_assiduidade, ' ELSE '' END +
        CASE WHEN ABS(ISNULL(p.ppr_vl_desconto, 0) - ISNULL(n.ppr_vl_desconto, 0)) > 0.01 THEN 'ppr_vl_desconto, ' ELSE '' END
    ) AS colunas_diferentes

FROM tb_pgto_periodo_rota p
JOIN tb_pgto_periodo_rota_validacao n 
  ON p.ppr_cd_rota = n.ppr_cd_rota
  and p.ppr_cd_periodo = n.ppr_cd_periodo
--WHERE 
    --p.ppr_cd_periodo = 499
	--and ABS(ISNULL(p.ppr_vl_total, 0) - ISNULL(n.ppr_vl_total, 0)) > 0.01
	 
	 group by     
    p.ppr_cd_periodo,
	  RTRIM(
        CASE WHEN ABS(ISNULL(p.ppr_vl_base, 0) - ISNULL(n.ppr_vl_base, 0)) > 0.01 THEN 'ppr_vl_base, ' ELSE '' END +
        CASE WHEN ABS(ISNULL(p.ppr_vl_bonus, 0) - ISNULL(n.ppr_vl_bonus, 0)) > 0.01 THEN 'ppr_vl_bonus, ' ELSE '' END +
        --CASE WHEN ABS(ISNULL(p.ppr_vl_adicional, 0) - ISNULL(n.ppr_vl_adicional, 0)) > 0.01 THEN 'ppr_vl_adicional, ' ELSE '' END +
        CASE WHEN ABS(ISNULL(p.ppr_vl_aluguel, 0) - ISNULL(n.ppr_vl_aluguel, 0)) > 0.01 THEN 'ppr_vl_aluguel, ' ELSE '' END +
        --CASE WHEN ABS(ISNULL(p.ppr_vl_assiduidade, 0) - ISNULL(n.ppr_vl_assiduidade, 0)) > 0.01 THEN 'ppr_vl_assiduidade, ' ELSE '' END +
        CASE WHEN ABS(ISNULL(p.ppr_vl_desconto, 0) - ISNULL(n.ppr_vl_desconto, 0)) > 0.01 THEN 'ppr_vl_desconto, ' ELSE '' END
    )


--toda alteracao que precisa ser feita no processo de pagamento, precisa ser feita antes na UspFinGeraPagamento_Validacao
--dentro dentra porcedure as tabelas referente ao pagamento estao replicadas com _validacao no final
--executa a procedure UspFinGeraPagamento_Validacao, depois executa a procedure UspGeraValidacoaPagamento, nesta procedure ira recalcular o ultimo espelho de cada transportadora
--depois executara uma query para comparar se gerou diferenca nos calculos para transportadoras indevidas
GO
