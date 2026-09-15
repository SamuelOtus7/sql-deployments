-- ============================================================
-- BASELINE: dbo.UspSetMLFichaFinanceiroTransportadora
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSetMLFichaFinanceiroTransportadora]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSetMLFichaFinanceiroTransportadora]
(
    @DataReferencia DATE,
    @idrota INT,
    @CicloPM VARCHAR(MAX),
    @QuantidadePontos INT,
    @QuantidadeParadas INT,
    @QuantidadePacotes INT,
    @PacotesEntregues INT,
    @Ajudante VARCHAR(MAX),
    @AreaRisco VARCHAR(MAX),
    @TipoVeiculo VARCHAR(MAX),
    @KmColetado DECIMAL(10,2),
    @LinkMapa VARCHAR(MAX),
    @idtransportadora INT,
    @DomingoOuFeriado VARCHAR(5),
    @faixakm VARCHAR(MAX),
    @ervicecenter VARCHAR(MAX),
    @Observacao VARCHAR(255),
    @Regiao VARCHAR(255),
    @RiscoV2 VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ano INT, @Mes TINYINT, @Quinzena TINYINT, @idtransportadoraML INT;
    
    -- Início do TRY-CATCH
    BEGIN TRY 
        SET @Ano = YEAR(@DataReferencia);
        SET @Mes = MONTH(@DataReferencia);
        SET @Quinzena = CASE 
            WHEN DAY(@DataReferencia) BETWEEN 1 AND 15 THEN 1 
            ELSE 2 
        END;

        -- Busca a transportadora ML
        SET @idtransportadoraML = (
            SELECT DISTINCT cli_id_logistics 
            FROM tb_clientes 
            WHERE cli_cd_codigo_cliente = @idtransportadora 
            AND cli_cd_codigo_cliente <> 7
        );

        -- Excluir registros antigos
        DELETE FROM tb_fin_resultado_financeiro_alteracao 
        WHERE idtransportadora = @idtransportadora 
        AND idrota = @idrota;

        -- Inserir novos dados
        INSERT INTO tb_fin_resultado_financeiro_alteracao (
            DataReferencia, idrota, CicloPM, QuantidadePontos, QuantidadeParadas, QuantidadePacotes,
            PacotesEntregues, Ajudante, AreaRisco, TipoVeiculo, KmColetado, LinkMapa, idtransportadora,
            DomingoOuFeriado, faixakm, servicecenter, Observacao, Regiao, RiscoV2
        )
        VALUES (
            @DataReferencia, @idrota, @CicloPM, @QuantidadePontos, @QuantidadeParadas, @QuantidadePacotes,
            @PacotesEntregues, @Ajudante, @AreaRisco, @TipoVeiculo, @KmColetado, @LinkMapa, @idtransportadora,
            @DomingoOuFeriado, @faixakm, @ervicecenter, @Observacao, @Regiao, @RiscoV2
        );

        -- Executa outra procedure
        EXEC [dbo].[UspGeraResultadoFinanceiro] 
            @idtransportadoraML, @Ano, @Mes, @Quinzena, @idrota;

        -- Se tudo deu certo, exibe 1 (sucesso)
        SELECT 1 AS Resultado;
    END TRY
    BEGIN CATCH
        -- Em caso de erro, exibe 0 (falha)
        SELECT 0 AS Resultado;
    END CATCH;
END;
GO
