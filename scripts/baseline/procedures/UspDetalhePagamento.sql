-- ============================================================
-- BASELINE: dbo.UspDetalhePagamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspDetalhePagamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspDetalhePagamento]   
(  
    @CodPeriodoPagamento INT,  
    @codrota VARCHAR(50) = NULL,  
    @avulso INT = NULL  
)  
AS  
BEGIN  
 
    SET NOCOUNT ON;
 
    DECLARE @HoraInicio DATETIME = GETDATE();
    DECLARE @TempoExecucao VARCHAR(100);
    DECLARE @MensagemAmigavel NVARCHAR(4000);
 
    
	SET @avulso  = CASE WHEN @avulso = 0 THEN NULL ELSE @avulso END
	SET @codrota = CASE WHEN @codrota = '-' or @codrota = '' THEN NULL ELSE @codrota END
	
	--EXEC UspAtualizaEdicoes @CodPeriodoPagamento,@codrota

    BEGIN TRY  
 
		------------------------------------------------------------
		-- REGRA FLIGHT
		------------------------------------------------------------
 
		IF EXISTS (
			SELECT 1
			FROM tb_periodos_espelhos_pagamento b
			JOIN tb_lista l ON b.pep_cd_operacao = l.lst_cd_lista
			WHERE pep_cd_periodo_pagamento = @CodPeriodoPagamento
			AND pep_cd_cliente = 27
			AND l.lst_ds_valor = 'LM'
			AND pep_cd_periodo_pagamento IN (SELECT id FROM tb_remove_periodo_fligth)
		)
		BEGIN
 
			EXEC [dbo].[UPD_ESPELHO_FLIGHT] @CodPeriodoPagamento,@avulso
 
			SET @TempoExecucao = CONVERT(VARCHAR, DATEDIFF(SECOND,@HoraInicio,GETDATE()))
 
			INSERT INTO dbo.LogProcessamentoFinanceiro
			(
				CodPeriodoPagamento,
				DataLog,
				MensagemLog,
				Severidade,
				Estado,
				TempoExecucao,
				idrota,
				avulso
			)
			VALUES
			(
				@CodPeriodoPagamento,
				GETDATE(),
				'Processamento concluído com sucesso (Cliente 27)',
				0,
				0,
				@TempoExecucao,
				@codrota,
				@avulso
			)
 
			SELECT 1 [value]
			RETURN
 
		END
 
 
		------------------------------------------------------------
		-- PREPARAÇÃO DOS DADOS
		------------------------------------------------------------
 
		DROP TABLE IF EXISTS #periodo_pagamento
 
		SELECT  
			b.lst_ds_valor,
			c.lst_ds_valor Operacao,
			a.pep_cd_cliente Cliente,
			ROW_NUMBER() OVER (ORDER BY b.lst_ds_valor,c.lst_ds_valor) rownum
			INTO #periodo_pagamento
		FROM 
			tb_periodos_espelhos_pagamento a
			JOIN tb_lista b ON a.pep_cd_cliente_transportadora = b.lst_cd_lista
			JOIN tb_lista c ON a.pep_cd_operacao = c.lst_cd_lista
		WHERE 
			pep_cd_periodo_pagamento = @CodPeriodoPagamento
			AND pep_cd_periodo_pagamento NOT IN (SELECT id FROM tb_remove_periodo_fligth)
 
 
		DECLARE @maximo INT = (SELECT MAX(rownum) FROM #periodo_pagamento)
		DECLARE @min INT = 1
 
		DECLARE @clientetransportadora VARCHAR(50)
		DECLARE @operacao VARCHAR(10)
		DECLARE @cliente INT
 
 
		------------------------------------------------------------
		-- LOOP
		------------------------------------------------------------
 
		WHILE @min <= @maximo
		BEGIN
 
			SELECT
				@clientetransportadora = lst_ds_valor,
				@operacao = Operacao,
				@cliente = Cliente
			FROM 
				#periodo_pagamento
			WHERE 
				rownum = @min
 
 
			------------------------------------------------------------
			-- MERCADO LIVRE
			------------------------------------------------------------
 
			IF @clientetransportadora = 'mercado_livre'
			BEGIN
				
				--Altera para Nulo caso o valor do campo não seja inteiro
				SET @codrota = try_cast(@codrota as int)

				------------------------------------------------------------
				-- OPERAÇÃO LM
				------------------------------------------------------------
				IF @operacao IN ('LM')
				BEGIN

					-- Cálculo V3
					IF @cliente IN (27, 73, 37, 88, 69, 66, 56, 148, 45) --Flight Cargo, Pantera Log, Transmaná, Deluna Transportes, ADO Transportadora, Hawk, Parceiro Spot, M S Simões, AC2
					BEGIN
						
						exec UspFinGeraRotasPagamentosMeliLM @CodPeriodoPagamento, @codrota, @avulso
						exec UspFinAplicaRegrasFinanceiro @CodPeriodoPagamento, @FaseExecucao = 1 --Procedure de regras antes do calculo de rotas
						exec UspFinCalculaPagamentoSaidaMeliLM @CodPeriodoPagamento, @codrota, @avulso
						exec UspFinAplicaRegrasFinanceiro @CodPeriodoPagamento, @FaseExecucao = 2 --Procedure de regras após do calculo de rotas
						exec UspFinCalculaPagamentoAdicionalMeliLM @CodPeriodoPagamento, @codrota, @avulso
						exec UspFinCalculaDescontoRotaMeliLM @CodPeriodoPagamento, @codrota, @avulso
						exec UspFinAtualizaDescontosCampanhas @CodPeriodoPagamento, @avulso
						
						--Executa uma pré consolidação do espelho para que a procedure UspFinGeraLancamentoAvulsoMeliLM seja executado com valores atualizados por rota
						exec UspFinConsolidaEspelhoMeliLM @CodPeriodoPagamento, @codrota, @avulso
						
						exec UspFinGeraLancamentoAvulsoMeliLM @CodPeriodoPagamento, @codrota, @avulso
						exec UspFinLancamentoManualMeliLM @CodPeriodoPagamento, @codrota, @avulso
						exec UspFinConsolidaEspelhoMeliLM @CodPeriodoPagamento, @codrota, @avulso

					END
					
					-- Cálculo V2
					ELSE IF @cliente IN (67,68) --Ricoo Log, Decargo Express
					BEGIN
 
						EXEC UspFinOrigemRotas @CodPeriodoPagamento,7, @codrota, @avulso
						EXEC UspFinAtualizaPagamentoSaida @CodPeriodoPagamento, @codrota, @avulso
						EXEC UpsGeraPagamentoAdicional @CodPeriodoPagamento,@codrota,7
						EXEC UspFinDescontoPagamentoSaida @CodPeriodoPagamento,@codrota
						EXEC UspFinAtualizaLancamentoManualNovo @CodPeriodoPagamento,@codrota
						EXEC UspFinAtualizaDescontosCampanhas @CodPeriodoPagamento, @avulso;
						-- Iserido por Gustavo Tavares - 11/02 -- Regra de zerar rota de acordo com a tb_veiculos
						--exec UspZeraEspelho @CodPeriodoPagamento,@codrota,7
						--EXEC UspFinAtualizaEspelhoConsolidado @CodPeriodoPagamento; 
						EXEC UspFinConsolidaEspelhoMeliLM @CodPeriodoPagamento, @codrota, @avulso
 
					END
 
					--Exceção criada para Coomap pois foram criados processos especificos do cliente
					ELSE IF @cliente = 63 AND @CodPeriodoPagamento > 2480
					BEGIN
 
						EXEC UspFinOrigemRotas @CodPeriodoPagamento,7
						EXEC UspFinAtualizaPagamentoSaidaCoomap @CodPeriodoPagamento
						EXEC UspFinAtualizaLancamentoManualNovoCoomap @CodPeriodoPagamento,@codrota
						EXEC UspFinAtualizaDescontosCampanhas @CodPeriodoPagamento, @avulso;
						EXEC UspFinAtualizaEspelhoConsolidado @CodPeriodoPagamento; 
 
					END
					
					-- Cálculo V1
					ELSE IF @cliente NOT IN (7) AND @CodPeriodoPagamento not in (3556)
					BEGIN
 
						EXEC UspFinGeraPagamento @CodPeriodoPagamento,@codrota,@avulso
						EXEC UspFinAtualizaLancamentoManual @CodPeriodoPagamento,@codrota
						EXEC UspFinAtualizaLancamentoManualDesconto @CodPeriodoPagamento
					
						--Inserido por Gabriel Ramos 03/11/2025 - Referente a task IRS | CooMap | Espelho de pagamento | Criar espelho avulso automaticamente em caso de desconto sem rota associada
						--EXEC dbo.UspFinGeraEspelhoLancamentosSemRota @CodPeriodoPagamento;
				    
						--Inserido por saulo barros em 05/11
						exec UspFinAtualizaDescontosCampanhas @CodPeriodoPagamento, @avulso;
                    
						--EXEC UspFinMLDescontoCartaoFlex @CodPeriodoPagamento;  
						EXEC UspFinAtualizaEspelhoConsolidado @CodPeriodoPagamento; 
 
					END
 
				END


				------------------------------------------------------------
				-- OPERAÇÃO LH
				------------------------------------------------------------
				ELSE IF @operacao = 'LH'
				BEGIN
 
					EXEC UspFinGeraPagamentoLH @CodPeriodoPagamento,@avulso
					EXEC UspFinAtualizaLancamentoManualLH @CodPeriodoPagamento
					EXEC UspFinConsolidaEspelhoLH @CodPeriodoPagamento, @avulso; 
 
				END

				------------------------------------------------------------
				-- OPERAÇÃO FM
				------------------------------------------------------------
				ELSE IF @operacao = 'FM'
				BEGIN
					IF @cliente NOT IN (27, 73, 37, 66, 67, 68, 69, 88, 56, 45) --REMOVENDO CLIENTES DA V2 e V3
					BEGIN
 
						EXEC UspFinGeraPagamento @CodPeriodoPagamento,@codrota,@avulso
						EXEC UspFinAtualizaLancamentoManualFM @CodPeriodoPagamento
						EXEC UspFinConsolidaEspelhoMeliLM @CodPeriodoPagamento; 
					END
					ELSE IF @cliente IN (56, 45) --FIRSTMILE V3
					BEGIN

						EXEC UspFinGeraRotasPagamentosMeliLM @CodPeriodoPagamento, @codrota, @avulso
						EXEC UspFinCalculaPagamentoSaidaMeliLM @CodPeriodoPagamento, @codrota, @avulso
						EXEC UspFinLancamentoManualMeliLM @CodPeriodoPagamento, @codrota, @avulso
						EXEC UspFinConsolidaEspelhoMeliLM @CodPeriodoPagamento, @codrota, @avulso
					END

				END
 
			END
 
 
			------------------------------------------------------------
			-- INTERNOS
			------------------------------------------------------------
 
			--ELSE IF @clientetransportadora = 'Interno'
			--BEGIN
 
			--	EXEC UspFinGeraEspelhoPagamentoInternos @CodPeriodoPagamento
			--	EXEC UspFinAtualizaDescontosCampanhas @CodPeriodoPagamento
			--	EXEC UspZeraEspelho @CodPeriodoPagamento,@codrota,7
			--	EXEC UspFinAtualizaEspelhoConsolidado @CodPeriodoPagamento
 
			--END
 
 
			------------------------------------------------------------
			-- SHOPEE
			------------------------------------------------------------
 
			ELSE IF @clientetransportadora = 'shopee'
			BEGIN
 
				EXEC UspSPEFinOrigemRotas @CodPeriodoPagamento,7
				EXEC UspSPEFinAtualizaPagamento @CodPeriodoPagamento, @codrota, @avulso;
				EXEC UspSPEFinAtualizaAdicionais @CodPeriodoPagamento, @codrota;	
				exec UspFinGeraLancamentoAvulsoShopee @CodPeriodoPagamento;
                 
				EXEC UspFinGeraEspelhoPagamentoInternos @CodPeriodoPagamento;  
				EXEC UspFinAtualizaLancamentoManual @CodPeriodoPagamento, @codrota;  
				EXEC UspFinAtualizaLancamentoManualDesconto @CodPeriodoPagamento;  
				EXEC dbo.UspFinGeraEspelhoLancamentosSemRota @CodPeriodoPagamento;

				exec UspFinAtualizaDescontosCampanhas @CodPeriodoPagamento, @avulso;
				EXEC UspFinAtualizaEspelhoConsolidado @CodPeriodoPagamento; 
                     
				exec UspFinExcluiEspelhoSemLancamento @CodPeriodoPagamento
 
			END


			------------------------------------------------------------
			-- ADMINISTRATIVO
			------------------------------------------------------------

			ELSE IF @clientetransportadora = 'Administrativo'
			BEGIN
 
				exec UspFinGeraPagamentoAdministrativo @CodPeriodoPagamento
				exec UspFinAtualizaLancamentoManualAdministrativo @CodPeriodoPagamento
				exec UspFinConsolidaEspelhoAdministrativo @CodPeriodoPagamento
 
			END


			------------------------------------------------------------
			-- CTE Line Haul Meli
			------------------------------------------------------------

			ELSE IF @clientetransportadora = 'CTE Line Haul Meli'
			BEGIN
 
				exec UspFinCalculaPagamentoCTEMeliLH @CodPeriodoPagamento
				exec UspFinAtualizaLancamentoManualCTEMeli @CodPeriodoPagamento
				exec UspFinConsolidaEspelhoAdministrativo @CodPeriodoPagamento

			END
 
 
			------------------------------------------------------------
			-- OUTROS CLIENTES
			------------------------------------------------------------
 
			ELSE IF @clientetransportadora IN ('Petlove','HL EXPRESS','Natura','Complementar','J&T Express','Imile','Anjun','Total Express','Magalog','Loggi','JMT LOG EXPRESS','HL EXPRESS','TRANSMARALE TRANSPORTES','Magalu','Dispatcher')
					AND @CodPeriodoPagamento not in (3570) 
			BEGIN
 
				EXEC UspFinAtualizaLancamentoManualOutrosClientes @CodPeriodoPagamento
				EXEC UspFinConsolidaEspelhoMeliLM @CodPeriodoPagamento
 
			END
 
 
			SET @min = @min + 1
 
		END
 
 
		SET @TempoExecucao = CONVERT(VARCHAR,DATEDIFF(SECOND,@HoraInicio,GETDATE()))
 
		INSERT INTO dbo.LogProcessamentoFinanceiro
		(
			CodPeriodoPagamento,
			DataLog,
			MensagemLog,
			Severidade,
			Estado,
			TempoExecucao,
			idrota,
			avulso
		)
		VALUES
		(
			@CodPeriodoPagamento,
			GETDATE(),
			'Processamento concluído com sucesso',
			0,
			0,
			@TempoExecucao,
			@codrota,
			@avulso
		)
 
		SELECT 1 [value]
 
 
    END TRY
 
    BEGIN CATCH
 
        DECLARE @ErrorMessage NVARCHAR(4000)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState INT
        DECLARE @ErrorNumber INT
 
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorNumber = ERROR_NUMBER()
 
 
        SET @MensagemAmigavel =
        CASE
            WHEN @ErrorNumber IN (2627,2601) THEN 'Aviso: Já existe um registro com esses dados.'
            WHEN @ErrorNumber = 547 THEN 'Aviso: Ação não permitida pois há registros relacionados.'
            WHEN @ErrorNumber = 515 THEN 'Aviso: Campo obrigatório não foi informado.'
            WHEN @ErrorNumber = 1205 THEN 'Aviso: Mais de uma execução ao mesmo tempo.'
            ELSE 'Erro inesperado durante o processamento.'
        END
 
 
        SET @TempoExecucao = CONVERT(VARCHAR,DATEDIFF(SECOND,@HoraInicio,GETDATE()))
 
 
        INSERT INTO dbo.LogProcessamentoFinanceiro
        (
            CodPeriodoPagamento,
            DataLog,
            MensagemLog,
            Severidade,
            Estado,
            TempoExecucao,
            idrota,
            avulso,
            DetalheTecnico
        )
        VALUES
        (
            @CodPeriodoPagamento,
            GETDATE(),
            @MensagemAmigavel,
            @ErrorSeverity,
            @ErrorState,
            @TempoExecucao,
            @codrota,
            @avulso,
            CONCAT(' [Detalhe técnico: ',@ErrorMessage,']')
        )
 
 
        SELECT 0 [value],@MensagemAmigavel MensagemErro
 
    END CATCH
 
    SET NOCOUNT OFF
 
END
GO
