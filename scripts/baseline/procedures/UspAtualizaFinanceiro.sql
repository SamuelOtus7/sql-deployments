-- ============================================================
-- BASELINE: dbo.UspAtualizaFinanceiro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaFinanceiro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspAtualizaFinanceiro]
(
	@EmpresaID INT = null
	,@ano INT = null
	,@mes INT = null
	,@quinzena INT = null

) as



DECLARE @ErrorMessage NVARCHAR(4000);

-- Declarar variáveis para ano, mês e quinzena

	set @ano = isnull(@ano, YEAR(GETDATE()));
	set @mes = isnull(@mes,CASE WHEN DAY(GETDATE()) <= 3 THEN MONTH(EOMONTH(GETDATE(), -1)) ELSE MONTH(GETDATE()) END);
	set @quinzena = isnull(@quinzena,CASE WHEN DAY(GETDATE()) >= 3 AND DAY(GETDATE()) <= 18 THEN 1 ELSE 2 END);


-- Declarar um cursor para percorrer as linhas
DECLARE cursorEmpresas CURSOR FOR

select 
	cli_id_logistics as EmpresaID
    
 from tb_clientes
where cli_in_ativo = 1
and (cli_id_logistics = @EmpresaID or @EmpresaID is null)
and cli_id_logistics not in (1930706223,834780814)
and cli_id_logistics > 1
--and cli_cd_codigo_cliente  not in (34)
--and cli_id_logistics = 2087146923

	
OPEN cursorEmpresas;

-- Variável para armazenar o ID da empresa atual
FETCH NEXT FROM cursorEmpresas INTO @EmpresaID;

-- Loop para executar as procedimentos para cada empresa
WHILE @@FETCH_STATUS = 0
BEGIN


		print(@EmpresaID)
	-- begin try
        -- Executar os procedimentos desejados para a empresa atual
	    EXEC UspGeraResultadoFinanceiro @EmpresaID, @ano, @mes, @quinzena;
         EXEC UspGeraPagamentoMotorista @EmpresaID, @ano, @mes, @quinzena;

		-- if @EmpresaID in (2087146923) 
		-- 	begin
		-- 		exec UspProcessaRegrasPagamentoMotorista @EmpresaID, @ano, @mes, @quinzena,1
		-- 	end ;

		 --EXEC UspCalculaDescontosMotoristas @EmpresaID, @ano, @mes, @quinzena;
		-- EXEC UspCalculaLancamentosManuais @EmpresaID, @ano, @mes, @quinzena;
         EXEC UspFinanceiroEnviaParaAprovacao @EmpresaID, @ano, @mes, @quinzena;
		
		EXEC UspFinanceiroAtualizaIndicadores @EmpresaID, @ano, @mes, @quinzena, 2;

		-- Adicione outras chamadas de procedimentos aqui, se necessário



        -- Inserir a mensagem de erro na tabela ErroLog

        --INSERT INTO ErroLog (EmpresaID, MensagemErro, DataErro)
        --VALUES (@EmpresaID, @ErrorMessage, GETDATE());

		--end try
		--begin catch
		--end catch

    -- Avançar para a próxima empresa
    FETCH NEXT FROM cursorEmpresas INTO @EmpresaID;
END;

-- Fechar o cursor
CLOSE cursorEmpresas;
DEALLOCATE cursorEmpresas;
GO
