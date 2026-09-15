-- ============================================================
-- BASELINE: dbo.UspGetDadosDashboard_teste
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDadosDashboard_teste]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspGetDadosDashboard_teste]
    @DashboardId INT,          -- ID do registro na tabela tb_alarmes
    @Tipo NVARCHAR(50),        -- Tipo de consulta: 'Resumo' ou 'Detalhe'
    @Tenant NVARCHAR(50)       -- Valor para substituir a variável @tenant na consulta
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Execucao NVARCHAR(MAX);
        DECLARE @Consulta NVARCHAR(MAX);
        DECLARE @URLAcao NVARCHAR(MAX);

        -- Selecionar a consulta apropriada com base no tipo
        SELECT @Consulta = CASE
                                WHEN @Tipo = 'Resumo' THEN ConsultaQtde
                                WHEN @Tipo = 'Detalhe' THEN ConsultaDetalhamento
                                ELSE NULL
                            END,
               @URLAcao = URLAcao
        FROM tb_alarmes
        WHERE Id = @DashboardId AND Status = 1;

        SET @Consulta = REPLACE(@Consulta, ';', '')

        -- Verificar se a consulta foi encontrada
        IF @Consulta IS NULL
        BEGIN
            THROW 50001, 'Consulta não encontrada ou parâmetro @Tipo inválido.', 1;
        END

        -- Substituir a variável @tenant pelo valor do parâmetro @Tenant
        SET @Consulta = REPLACE(@Consulta, '@tenant', QUOTENAME(@Tenant, ''''));

        -- Montar a execução da consulta dinamicamente
        SET @Execucao = 'SELECT Dados.*, REPLACE(''' + @URLAcao + ''',''{subdominio}'',cli_ds_sub_dominio) AS Acao
                         FROM (' + @Consulta + ') AS Dados
                         JOIN tb_clientes ON cli_cd_codigo_cliente = ''' + @Tenant + ''' '

        -- Executar a consulta dinamicamente e retornar diretamente os resultados
        IF @Tipo = 'Detalhe'
        BEGIN
            EXEC sp_executesql @Execucao;
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

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        -- Relançar o erro capturado
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
