-- ============================================================
-- BASELINE: dbo.UspProcessaRegrasPagamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspProcessaRegrasPagamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspProcessaRegrasPagamento]
    @codperiodo INT

AS

------- Criado por: Gabriel Ramos
------- Data: 2025-02-20
------- Objetivo : Atender a demanda > ||ALC / Financeiro / Criar regra para pagar apenas metade do valor da rota Rental||


BEGIN

--    -- Cria a tabela temporária para armazenar os cálculos
    IF OBJECT_ID('tempdb..#Pagamentos') IS NOT NULL
        DROP TABLE #Pagamentos;

    CREATE TABLE #Pagamentos (
        ppr_cd_periodo INT,
        ppr_cd_rota VARCHAR (50),
        ppr_nome_motorista VARCHAR(255),
        ppr_data_referencia DATE,
        ppr_ds_ciclo VARCHAR(10),
        ppr_base_principal VARCHAR(10),
        ppr_ds_tipo_veiculo VARCHAR(255),
        ppr_vl_base DECIMAL(10,2),
        ppr_vl_desconto DECIMAL(10,2)
    );

    -- Insere os dados na tabela temporária considerando apenas veículos Rental
    INSERT INTO #Pagamentos
    SELECT 
        ppr_cd_periodo,
        ppr_cd_rota,
        ppr_nome_motorista,
        ppr_data_referencia,
        ppr_ds_ciclo,
        ppr_base_principal,
        ppr_ds_tipo_veiculo,
        ppr_vl_base,
        0 AS ppr_vl_desconto
    FROM tb_pgto_periodo_rota
    WHERE ppr_cd_periodo = @codperiodo
    AND ppr_ds_tipo_veiculo in ('MELIONE VUC', 'RENTAL UTILITÁRIO COM AJUDANTE', 'BULK - VAN_HR EQUIPE ÚNICA POOL', 
'UTILITÁRIOS', 'FROTA FIXA LARGE MASTER', 'LARGE VAN ELETRICA J750', 'VUC DEDICADO COM AJUDANTE', 'VAN ELÉTRICA JV', 'UTILITÁRIO ELÉTRICO BYD');



-- Aplica regra de pagamento apenas se houver mais de duas rotas no mesmo dia
    WITH CTE AS (
        SELECT 
            ppr_cd_periodo,
            ppr_cd_rota,
            ppr_nome_motorista,
            ppr_data_referencia,
            ppr_ds_ciclo,
            ppr_base_principal,
            ROW_NUMBER() OVER (PARTITION BY ppr_nome_motorista, ppr_data_referencia ORDER BY cast(ppr_cd_rota as int)) AS RotaNumero
        FROM #Pagamentos
    )
   	UPDATE P
    SET 
        P.ppr_vl_base = CASE 
            WHEN C.RotaNumero = 1 THEN P.ppr_vl_base 
            WHEN C.RotaNumero >= 2 AND P.ppr_base_principal IN ('SMG1', 'SMG8', 'SSP12', 'SES1', 'SMG14') THEN P.ppr_vl_base
            WHEN C.RotaNumero >= 2 AND P.ppr_base_principal = 'BARUERI' AND P.ppr_ds_ciclo = 'AM' THEN P.ppr_vl_base
            WHEN C.RotaNumero >= 2 AND P.ppr_base_principal = 'BARUERI' AND P.ppr_ds_ciclo = 'PM' THEN P.ppr_vl_base / 2
            WHEN C.RotaNumero >= 2 THEN P.ppr_vl_base / 2
			ELSE P.ppr_vl_base
        END
    FROM #Pagamentos P
    INNER JOIN CTE C
    ON P.ppr_cd_rota = C.ppr_cd_rota
    AND P.ppr_nome_motorista = C.ppr_nome_motorista
    AND P.ppr_data_referencia = C.ppr_data_referencia;
  
--    -- Atualiza a tabela principal com os valores corrigidos
    UPDATE T
    SET
        T.ppr_vl_base = P.ppr_vl_base
   FROM tb_pgto_periodo_rota T
    INNER JOIN #Pagamentos P
    ON T.ppr_cd_rota = P.ppr_cd_rota
    AND T.ppr_nome_motorista = P.ppr_nome_motorista
    AND T.ppr_data_referencia = P.ppr_data_referencia
	AND T.ppr_cd_periodo = P.ppr_cd_periodo;


	UPDATE tb_pgto_periodo_rota
	SET 
		ppr_vl_total =
	ISNULL(ppr_vl_base, 0) +
	ISNULL(ppr_vl_paradas, 0) +
    ISNULL(ppr_vl_recarga, 0) +
    ISNULL(ppr_vl_bonus, 0) +
    ISNULL(ppr_vl_ajudante, 0) +
    ISNULL(ppr_vl_risco, 0) +
    ISNULL(ppr_vl_dom_fer, 0) +
    ISNULL(ppr_vl_lancamentos, 0) +
	ISNULL(ppr_bfm_vl_adicional_ajudante, 0)  
WHERE ppr_cd_periodo = @codperiodo;
 
 
UPDATE a
SET 
	mtn_vl_nfs = total
 FROM tb_pag_espelhos a
INNER JOIN (
SELECt SUM(ppr_vl_total) AS total, ppr_cd_pgto_espelho
	FROM tb_pgto_periodo_rota AS a
WHERE  
ppr_cd_periodo = @codperiodo
GROUP BY ppr_cd_pgto_espelho
) AS b
ON a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho;

   DROP TABLE #Pagamentos;
END;


GO
