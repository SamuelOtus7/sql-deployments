/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-09
  Descricao    : Gestao de periodos DRE — mesma logica da tb_pgto_periodo
                 (periodo de pagamento dos espelhos), agora para a fato DRE.
                 1) Recria tb_fin_dre_processamento como tabela de periodos:
                    IdProcessamento identity, Quinzena (0 = mes inteiro),
                    fluxo GERANDO->GERADO (Real) | GERANDO->SIMULACAO->
                    PROCESSADO (Orcado). Tabela estava vazia no deploy 039.
                 2) sp_fin_dre_gerar_periodo: cria/regera o periodo — visao
                    Realizado executa sp_fin_dre_carga; visao Orcado copia a
                    fatia Realizado -> CodVisao=2 (simulacao editavel).
                 3) sp_fin_dre_periodo_status: transicoes SIMULACAO<->PROCESSADO.
                 4) Trigger de auditoria trg_aud_dre_processamento.
                 5) GRANT EXECUTE para usr_relatorio_web (guardado).
  Rollback     : scripts/rollback/2026/10/040_rollback_CU-86ahpqmf9_dre_processamento.sql
  Objetos      : tb_fin_dre_processamento (recriada), sp_fin_dre_gerar_periodo,
                 sp_fin_dre_periodo_status, trg_aud_dre_processamento
  Dependencias : deploy 039 (tb_fato_dre, sp_fin_dre_carga, tb_dim_visao,
                 tb_aud_dre), tb_dim_dre_indicador/conta RB-SUBT (commit cf984a6)
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tb_fato_dre')
        THROW 50001, 'tb_fato_dre nao existe — aplique o deploy 039 primeiro.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_fin_dre_carga')
        THROW 50002, 'sp_fin_dre_carga nao existe — aplique o deploy 039 primeiro.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tb_dim_visao')
        THROW 50003, 'tb_dim_visao nao existe — aplique o deploy 039 primeiro.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tb_aud_dre')
        THROW 50004, 'tb_aud_dre nao existe — aplique o deploy 039 primeiro.', 1;
    IF EXISTS (SELECT 1 FROM dbo.tb_fin_dre_processamento)
        THROW 50005, 'tb_fin_dre_processamento tem dados — faca backup antes de recriar.', 1;
    PRINT 'Pre-checks OK';
END TRY
BEGIN CATCH
    PRINT 'ERRO NO PRE-CHECK: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. TABELA DE PERIODOS DRE (recria — tabela vazia no 039)
--    Gerencia um periodo por Empresa x AnoMes x Quinzena x Visao.
--    Quinzena = 0 representa "mes inteiro" (evita NULL na unique key).
--============================================================================
DROP TABLE dbo.tb_fin_dre_processamento;
GO

CREATE TABLE dbo.tb_fin_dre_processamento (
    IdProcessamento bigint       IDENTITY(1,1) NOT NULL,
    CodCliente      int          NOT NULL,
    Ano             int          NOT NULL,
    Mes             tinyint      NOT NULL,
    Quinzena        tinyint      NOT NULL CONSTRAINT DF_dre_proc_quinzena DEFAULT 0,
    CodVisao        smallint     NOT NULL,
    Status          varchar(20)  NOT NULL,  -- GERANDO | GERADO | SIMULACAO | PROCESSADO | ERRO
    DhGeracao       datetime     NOT NULL CONSTRAINT DF_dre_proc_geracao DEFAULT SYSDATETIME(),
    DhProcessado    datetime     NULL,
    UsuarioApp      varchar(100) NULL,
    Erro            varchar(2000) NULL,
    CONSTRAINT PK_dre_processamento PRIMARY KEY (IdProcessamento),
    CONSTRAINT UQ_dre_processamento UNIQUE (CodCliente, Ano, Mes, Quinzena, CodVisao),
    CONSTRAINT FK_dre_proc_visao FOREIGN KEY (CodVisao) REFERENCES dbo.tb_dim_visao (CodVisao),
    CONSTRAINT CK_dre_proc_quinzena CHECK (Quinzena IN (0, 1, 2)),
    CONSTRAINT CK_dre_proc_status CHECK (Status IN ('GERANDO','GERADO','SIMULACAO','PROCESSADO','ERRO'))
);
GO

--============================================================================
-- 3. PROC: gera/regera o periodo na fato conforme a visao escolhida
--    Visao 1 (Realizado) -> sp_fin_dre_carga (recalcula das fontes)
--    Visao 2 (Orcado)    -> copia da fatia Realizado (simulacao editavel)
--============================================================================
EXEC('
CREATE PROCEDURE dbo.sp_fin_dre_gerar_periodo
    @CodCliente int,
    @Ano        int,
    @Mes        tinyint,
    @Quinzena   tinyint  = 0,    -- 0 = mes inteiro
    @CodVisao   smallint = 1,
    @UsuarioApp varchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dhIni datetime = SYSDATETIME();
    DECLARE @IdProcessamento bigint;
    DECLARE @qt int = 0;
    DECLARE @QuinzenaCarga tinyint = NULLIF(@Quinzena, 0);

    IF NOT EXISTS (SELECT 1 FROM dbo.tb_dim_visao
                   WHERE CodVisao = @CodVisao AND InAtivo = 1)
        THROW 50200, ''Visao inexistente ou inativa.'', 1;

    -------------------------------------------------------------
    -- Upsert do periodo de processamento (chave natural unica)
    -------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM dbo.tb_fin_dre_processamento
               WHERE CodCliente = @CodCliente AND Ano = @Ano AND Mes = @Mes
                 AND Quinzena = @Quinzena AND CodVisao = @CodVisao)
        UPDATE dbo.tb_fin_dre_processamento
        SET Status = ''GERANDO'', DhGeracao = @dhIni,
            DhProcessado = NULL, UsuarioApp = @UsuarioApp, Erro = NULL
        WHERE CodCliente = @CodCliente AND Ano = @Ano AND Mes = @Mes
          AND Quinzena = @Quinzena AND CodVisao = @CodVisao;
    ELSE
        INSERT INTO dbo.tb_fin_dre_processamento
            (CodCliente, Ano, Mes, Quinzena, CodVisao, Status, UsuarioApp)
        VALUES (@CodCliente, @Ano, @Mes, @Quinzena, @CodVisao, ''GERANDO'', @UsuarioApp);

    SELECT @IdProcessamento = IdProcessamento
    FROM dbo.tb_fin_dre_processamento
    WHERE CodCliente = @CodCliente AND Ano = @Ano AND Mes = @Mes
      AND Quinzena = @Quinzena AND CodVisao = @CodVisao;

    BEGIN TRY
        -------------------------------------------------------------
        -- Visao REALIZADO: recalcula das fontes via proc de carga
        -------------------------------------------------------------
        IF @CodVisao = 1
        BEGIN
            EXEC dbo.sp_fin_dre_carga
                @CodCliente = @CodCliente, @Ano = @Ano, @Mes = @Mes,
                @Quinzena   = @QuinzenaCarga;

            UPDATE dbo.tb_fin_dre_processamento
            SET Status = ''GERADO'', DhProcessado = SYSDATETIME()
            WHERE IdProcessamento = @IdProcessamento;
        END
        -------------------------------------------------------------
        -- Visao ORCADO: copia a fatia Realizado (ponto de partida da
        -- simulacao; edicoes posteriores sao auditadas pelo trigger)
        -------------------------------------------------------------
        ELSE IF @CodVisao = 2
        BEGIN
            BEGIN TRAN;

            DELETE FROM dbo.tb_fato_dre
            WHERE CodCliente = @CodCliente AND Ano = @Ano AND Mes = @Mes
              AND CodVisao = 2
              AND (@Quinzena = 0 OR Quinzena = @Quinzena);

            INSERT INTO dbo.tb_fato_dre
                (SkData, Data, Ano, Mes, Quinzena, CodCliente, IdTransportadora,
                 CodMarketplace, CodBase, CodContaContabil, SkIndicador,
                 CodOrigem, CodVisao, IdReferencia, IdTransacao, Valor)
            SELECT
                SkData, Data, Ano, Mes, Quinzena, CodCliente, IdTransportadora,
                CodMarketplace, CodBase, CodContaContabil, SkIndicador,
                CodOrigem, 2, IdReferencia, IdTransacao, Valor
            FROM dbo.tb_fato_dre WITH (NOLOCK)
            WHERE CodCliente = @CodCliente AND Ano = @Ano AND Mes = @Mes
              AND CodVisao = 1
              AND (@Quinzena = 0 OR Quinzena = @Quinzena);
            SET @qt = @@ROWCOUNT;

            COMMIT TRAN;

            UPDATE dbo.tb_fin_dre_processamento
            SET Status = ''SIMULACAO'', DhProcessado = NULL,
                Erro = NULL
            WHERE IdProcessamento = @IdProcessamento;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        UPDATE dbo.tb_fin_dre_processamento
        SET Status = ''ERRO'', Erro = ERROR_MESSAGE()
        WHERE IdProcessamento = @IdProcessamento;
        THROW;
    END CATCH

    SELECT @IdProcessamento AS IdProcessamento, @qt AS QtLinhasCopiadas;
END
');
GO

--============================================================================
-- 4. PROC: transicao de status do periodo (congela/reabre simulacao)
--    SIMULACAO -> PROCESSADO | PROCESSADO -> SIMULACAO
--============================================================================
EXEC('
CREATE PROCEDURE dbo.sp_fin_dre_periodo_status
    @IdProcessamento bigint,
    @NovoStatus      varchar(20),
    @UsuarioApp      varchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @atual varchar(20);
    SELECT @atual = Status FROM dbo.tb_fin_dre_processamento
    WHERE IdProcessamento = @IdProcessamento;

    IF @atual IS NULL
        THROW 50201, ''Periodo de processamento nao encontrado.'', 1;

    IF NOT (@atual = ''SIMULACAO''  AND @NovoStatus = ''PROCESSADO'')
       AND NOT (@atual = ''PROCESSADO'' AND @NovoStatus = ''SIMULACAO'')
        THROW 50202, ''Transicao invalida: permitido SIMULACAO<->PROCESSADO.'', 1;

    UPDATE dbo.tb_fin_dre_processamento
    SET Status = @NovoStatus,
        DhProcessado = CASE WHEN @NovoStatus = ''PROCESSADO'' THEN SYSDATETIME() ELSE NULL END,
        UsuarioApp = @UsuarioApp
    WHERE IdProcessamento = @IdProcessamento;
END
');
GO

--============================================================================
-- 5. AUDITORIA do processamento
--============================================================================
EXEC('
CREATE TRIGGER dbo.trg_aud_dre_processamento ON dbo.tb_fin_dre_processamento
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_aud_dre (Tabela, Operacao, ChaveRegistro, ValorAntigo, ValorNovo)
    SELECT ''tb_fin_dre_processamento'',
           CASE WHEN i.IdProcessamento IS NOT NULL AND d.IdProcessamento IS NOT NULL THEN ''U''
                WHEN i.IdProcessamento IS NOT NULL THEN ''I'' ELSE ''D'' END,
           CONVERT(varchar(200), COALESCE(i.IdProcessamento, d.IdProcessamento)),
           (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted i FULL JOIN deleted d ON i.IdProcessamento = d.IdProcessamento;
END
');
GO

--============================================================================
-- 6. GRANTS (guardado — so aplica se o usuario existir)
--============================================================================
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_relatorio_web')
BEGIN
    GRANT EXECUTE ON dbo.sp_fin_dre_gerar_periodo  TO usr_relatorio_web;
    GRANT EXECUTE ON dbo.sp_fin_dre_periodo_status TO usr_relatorio_web;
END
GO

PRINT 'Deploy 040 concluido: gestao de periodos DRE (Real/Orcado).';
GO
