-- ============================================================
-- BASELINE: dbo.UspDetalhePagamento_bkp20250602
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspDetalhePagamento_bkp20250602]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXeC [dbo].[UspDetalhePagamento] 551, null, null

create PROCEDURE [dbo].[UspDetalhePagamento_bkp20250602] 
(
    @CodPeriodoPagamento INT,
    @codrota VARCHAR(50) = NULL,
    @avulso INT = NULL -- código espelho
)
AS
BEGIN

IF @codrota = '' SET @codrota = NULL;
    SET NOCOUNT ON;

    BEGIN TRY

        -- Se for cliente 27, executa a nova procedure e encerra
        IF EXISTS (
            SELECT 1 
            FROM tb_periodos_espelhos_pagamento
            WHERE pep_cd_periodo_pagamento = @CodPeriodoPagamento
              AND pep_cd_cliente = 27
        )
        BEGIN
            EXEC [dbo].[UPD_ESPELHO_FLIGHT] @CodPeriodoPagamento, @avulso;
            SELECT 1 AS [value];
            RETURN;
        END

        -- Processamento normal para os demais clientes
        DROP TABLE IF EXISTS #periodo_pagamento;

        SELECT 
            lst_ds_valor, 
            ROW_NUMBER() OVER (ORDER BY lst_ds_valor) AS rownum
        INTO #periodo_pagamento
        FROM tb_periodos_espelhos_pagamento AS a
        INNER JOIN tb_lista AS b ON pep_cd_cliente_transportadora = lst_cd_lista
        WHERE pep_cd_periodo_pagamento = @CodPeriodoPagamento
          AND pep_cd_cliente <> 27;

        DECLARE @maximo INT = (SELECT MAX(rownum) FROM #periodo_pagamento);
        DECLARE @min INT = 1;
        DECLARE @clientetransportadora VARCHAR(50);

        WHILE @min <= @maximo
        BEGIN
            SET @clientetransportadora = (
                SELECT lst_ds_valor 
                FROM #periodo_pagamento 
                WHERE rownum = @min
            );

			-- exec [UspAtualizaEdicoes] @CodPeriodoPagamento, @codrota; 

            SET @avulso = (CASE WHEN @avulso = 0 THEN NULL ELSE @avulso END);

            IF @clientetransportadora = 'mercado_livre'
            BEGIN
				
                EXEC UspFinGeraPagamento @CodPeriodoPagamento, @codrota, @avulso;
            END
            ELSE IF @clientetransportadora = 'shopee'
            BEGIN
                EXEC UspSpeFinGeraPagamento @CodPeriodoPagamento, @codrota, @avulso;
            END
            ELSE IF @clientetransportadora = 'Interno'
            BEGIN
                EXEC UspFinGeraEspelhoPagamentoInternos @CodPeriodoPagamento;
            END

			   -- Se for cliente 1, executa a nova procedure e encerra
        --IF EXISTS (
        --    SELECT 1 
        --    FROM tb_periodos_espelhos_pagamento
        --    WHERE pep_cd_periodo_pagamento = @CodPeriodoPagamento
        --      AND pep_cd_cliente = 1
        --)
        --BEGIN
        --EXEC [UspProcessaRegrasPagamento] @CodPeriodoPagamento;
        --END

        --    EXEC [UspFinGeraDescontoPagamento] @CodPeriodoPagamento;

            -- Etapa de aluguel (comentada)
            -- EXEC UspRecalculaApoioPercentual @CodPeriodoPagamento;

            EXEC UspFinAtualizaLancamentoManual @CodPeriodoPagamento, @codrota;
            EXEC UspFinAtualizaEspelhoConsolidado @CodPeriodoPagamento;

            SET @min = @min + 1;
        END

        SELECT 1 AS [value];

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE();
        SELECT 0 AS [value];
    END CATCH;

    SET NOCOUNT OFF;
END
GO
