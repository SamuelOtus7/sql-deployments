-- ============================================================
-- BASELINE: dbo.USP_cria_index_daily
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USP_cria_index_daily]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_cria_index_daily] as

DECLARE @DataAtual DATE = CAST(GETDATE() AS DATE); -- Data do dia atual (formato estático 'YYYY-MM-DD')

BEGIN TRY
    -- Verificar se o índice existe antes de tentar removê-lo
    IF EXISTS (
        SELECT 1 
        FROM sys.indexes 
        WHERE name = 'idx_ml_rotas_dia_atual_1' 
        AND object_id = OBJECT_ID('dbo.tb_ml_rotas')
    )
    BEGIN
        PRINT 'Índice existente. Removendo...';
        DROP INDEX idx_ml_rotas_dia_atual_1 ON dbo.tb_ml_rotas;
    END
    ELSE
    BEGIN
        PRINT 'Índice não encontrado. Continuando...';
    END;

    -- Criar o índice diretamente
    PRINT 'Criando índice: idx_ml_rotas_dia_atual_1';

    DECLARE @CreateIndexSQL NVARCHAR(MAX);

    SET @CreateIndexSQL = '
    CREATE NONCLUSTERED INDEX idx_ml_rotas_dia_atual_1 ON dbo.tb_ml_rotas
    (
        Id ASC,
        IdRota ASC,
        DataReferencia ASC
    )
    INCLUDE (
        DataHoraColeta, DataColeta, ServiceCenter, OrigemSaida, TipoOrigemSaida, Tipo, TipoRota, StatusRota,
        SubStatusRota, TipoEntrega, IdTransportadora, DataHoraInicio, DataHoraFim, TotalPacotes,
        PacotesEntregues, PacotesNaoEntregue, PacotesPendentes, PacotesEntreguesForaAreaEntrega,
        PacotesTransferidos, PacotesRecebidos, TotalSacas, QuantidadeAmbulancia, StatusPrazo, NomeMotorista,
        NivelExperienciaMotorista, MotoristaArriscado, QuantidadeReclamacoesMotorista, TaxaDeContatoMotorista,
        IdNivelMotorista, NivelMotorista, QuantidadePacotesTransportados, PercentualEntregasBemSucedidas,
        PercentualEntregasSemRelamacaoes, PossuiAjudante, TipoVeiculo, Placa, TempoPlanejadoMinutos,
        PercentualProgresso, KmTotal, TempoEmRota, TempoChegadaAreaEntrega, TempoAreaEntrega,
        TempoRetornoCentroDistribuicao, TempoInativo, DataAtualizacao, Excluido, QuantidadePontos,
        QuantidadeParadas, DataUltimaAtualizacaoPacote, DataPrimeiraEntrega, LinkMapa, StatusPrimeiraEntrega,
        StatusSegundaEntrega, QuantidadeReclamacoes, KmColetado, DataUltimaEntrega, KmColetadoApp,
        LinkMapaApp, KmColetadoGeo, LinkMapaGeo, Cidades, CidadeReferencia, Ambulancia,
        OrigemSaidaAmbulancia, KmMotorista, DataCriacao, LinkAppInterno, UsouAPP, UsuarioDA, Apuracao,
        QuantidadeApontamento, FaixaPrimeiroUltimoPacote, QuantidadeReclamacoesClaims, StatusReclamacoes,
        QuantidadeReclamacoesAbertas, QuantidadeReclamacoesFechadas, IdTrevo, CidadeDistante, KmMapaPacote,
        LinkPacote
    ) 
    WHERE DataReferencia >= ''' + CONVERT(VARCHAR(10), @DataAtual, 120) + '''
    WITH (
        PAD_INDEX = OFF, DATA_COMPRESSION = PAGE, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
        DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON,
        OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
    ) ON [PRIMARY];
    ';

    EXEC sp_executesql @CreateIndexSQL;

    PRINT 'Índice criado com sucesso!';
END TRY
BEGIN CATCH
    PRINT 'Erro ao criar ou remover índice.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
