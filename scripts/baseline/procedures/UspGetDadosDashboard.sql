-- ============================================================
-- BASELINE: dbo.UspGetDadosDashboard
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDadosDashboard]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGetDadosDashboard]
    @DashboardId INT,   -- ID do registro na tabela tb_alarmes
    @Tipo NVARCHAR(50), -- Tipo de consulta: 'Resumo' ou 'Detalhe'
    @Tenant NVARCHAR(50) -- Valor para substituir a variável @tenant na consulta
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Execucao NVARCHAR(MAX);
        DECLARE @Consulta NVARCHAR(MAX);
		DECLARE @URLAcao NVARCHAR(MAX);

        -- Selecionar a consulta apropriada com base no tipo
       
	   SELECT 
            @Consulta = CASE
                           WHEN @Tipo = 'Resumo' THEN ConsultaQtde
                           WHEN @Tipo = 'Detalhe' THEN ConsultaDetalhamento
                           ELSE NULL
                        END,
            @URLAcao = URLAcao
        FROM tb_alarmes
        WHERE Id = @DashboardId AND Status = 1;

		SET @consulta = replace(@Consulta,';','')

        -- Verificar se a consulta foi encontrada
        IF @Consulta IS NULL
        BEGIN
            THROW 50001, 'Consulta não encontrada ou parâmetro @Tipo inválido.', 1;
        END

        -- Substituir a variável @tenant pelo valor do parâmetro @Tenant
        SET @Consulta = REPLACE(@Consulta, '@tenant', QUOTENAME(@Tenant, ''''));

		--
		SET @Execucao = 'SELECT Dados.*,REPLACE('''+@URLAcao+''',''{subdominio}'',cli_ds_sub_dominio) AS Acao
		                 FROM ('+@CONSULTA+') AS Dados
						 JOIN tb_clientes ON cli_cd_codigo_cliente = '''+@tenant+''' '

        -- Executar a consulta dinamicamente e retornar diretamente os resultados
        IF @Tipo = 'Detalhe'
        BEGIN
            EXEC sp_executesql @Execucao;
           -- SELECT CONCAT('<a href="', @URLAcao, '">Corrigir</a>') AS Corrigir;
        END
        ELSE
        BEGIN
            EXEC sp_executesql @Consulta;
        END
    END TRY
    BEGIN CATCH
        -- Tratamento de erros
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Relançar o erro capturado
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
