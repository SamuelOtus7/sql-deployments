/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-08
  Descricao    : Persiste os TOTAIS IMPRESSOS da pre-fatura ML que hoje so existem
                 como linhas-texto no dump bruto (tb_fin_prefatura_upload:
                 rotulo em Produto, valor em Column8) e NAO derivam das linhas
                 itemizadas de tb_fin_prefatura. Motivacao: a "Subtotal da
                 pre-fatura" impressa no portal difere do itemizado (glosa ML -
                 ex.: prefatura 6893666, COOMAP 202608Q2, glosa R$ 4.446,99) e
                 nenhuma tabela estruturada armazenava esse numero.

                 1) Cria dbo.tb_fin_prefatura_totais (1 linha por
                    IdTransportadora+Ano+Mes+Quinzena) com:
                    - totais do portal: SubtotalPrefatura, TotalPrefatura,
                      PenLost, PenPnr, PenNotVisited, TotalPenalidades,
                      AdicionaisPortal, TotalComCTE
                    - totais itemizados: SubtotalServicos/SubtotalAdicionais
                      (SUM de tb_fin_prefatura.Total / VLParada)
                    - GlosaPrefatura = SubtotalServicos - SubtotalPrefatura
                      (coluna computada persistida)
                 2) Backfill: parseia TODO o historico de tb_fin_prefatura_upload
                    (rotulos 'Subtotal da pr?-fatura', 'Total pr?-fatura',
                    'Total adicionais', 'Total penalidades', 'Subtotal Lost
                    Packages Penalty', 'Subtotal pnr:penalty', 'Subtotal Vehicle
                    Daily Not Visited', 'Total com CTE'; header detectado por
                    Periodo '20??Q_' + IDPrefatura numerico).
                 3) Cria dbo.vw_fin_prefatura_totais (totais + cliente +
                    rotulo de periodo 'YYYYMMQn').
  Rollback     : scripts/rollback/2026/10/038_rollback_CU-86ahpqmf9_prefatura_totais.sql
  Objetos      : dbo.tb_fin_prefatura_totais (CREATE TABLE + INSERT backfill),
                 dbo.vw_fin_prefatura_totais (CREATE VIEW)
  Dependencias : fonte: dbo.tb_fin_prefatura_upload, dbo.tb_fin_prefatura,
                 dbo.tb_clientes; consumidor: relatorio dre-prefatura
                 (relatorios-web), DRE/prefatura
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fin_prefatura_totais'))
        THROW 50001, 'Tabela dbo.tb_fin_prefatura_totais ja existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fin_prefatura_upload'))
        THROW 50002, 'Tabela fonte dbo.tb_fin_prefatura_upload nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fin_prefatura'))
        THROW 50003, 'Tabela fonte dbo.tb_fin_prefatura nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. SCRIPT PRINCIPAL - 2.1 Tabela de totais da pre-fatura
--============================================================================
BEGIN TRY
    CREATE TABLE dbo.tb_fin_prefatura_totais
    (
        IdTransportadora   int            NOT NULL,  -- = tb_clientes.cli_id_logistics
        Ano                int            NOT NULL,
        Mes                tinyint        NOT NULL,
        Quinzena           tinyint        NOT NULL,
        IDPrefatura        varchar(50)    NULL,      -- id da pre-fatura no portal ML (header do upload)
        -- Totais impressos no portal (dump do CSV)
        SubtotalPrefatura  decimal(18,2)  NULL,      -- "Subtotal da pre-fatura" (servicos - glosa ML)
        TotalPrefatura     decimal(18,2)  NULL,      -- "Total pre-fatura"
        AdicionaisPortal   decimal(18,2)  NULL,      -- "Total adicionais"
        PenLost            decimal(18,2)  NULL,      -- "Subtotal Lost Packages Penalty" (negativo)
        PenPnr             decimal(18,2)  NULL,      -- "Subtotal pnr:penalty" (negativo)
        PenNotVisited      decimal(18,2)  NULL,      -- "Subtotal Vehicle Daily Not Visited" (negativo)
        TotalPenalidades   decimal(18,2)  NULL,      -- "Total penalidades" (negativo)
        TotalComCTE        decimal(18,2)  NULL,      -- "Total com CTE"
        -- Totais itemizados (recomputados de tb_fin_prefatura)
        SubtotalServicos   decimal(18,2)  NULL,      -- SUM(Total)   = "Subtotal de servicos"
        SubtotalAdicionais decimal(18,2)  NULL,      -- SUM(VLParada)
        -- Diferenca portal x itemizado (glosa ML). NULL quando sem CSV subido
        GlosaPrefatura     AS (CONVERT(decimal(18,2), SubtotalServicos - SubtotalPrefatura)) PERSISTED,
        DataCarga          datetime       NOT NULL
            CONSTRAINT DF_tb_fin_prefatura_totais_DataCarga DEFAULT SYSDATETIME(),
        CONSTRAINT PK_tb_fin_prefatura_totais PRIMARY KEY CLUSTERED
            (IdTransportadora ASC, Ano ASC, Mes ASC, Quinzena ASC)
    );

    PRINT 'Tabela dbo.tb_fin_prefatura_totais criada.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (create table): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2.2 Backfill - parseia rotulos do dump CSV em tb_fin_prefatura_upload
--============================================================================
BEGIN TRY
    ;WITH TotaisCsv AS
    (
        SELECT
            u.IdTransportadora,
            u.Ano,
            u.Mes,
            u.Quinzena,
            SUM(CASE WHEN u.Produto LIKE 'Subtotal da pr%fatura%'                THEN v.Val END) AS SubtotalPrefatura,
            SUM(CASE WHEN u.Produto LIKE 'Total pr%fatura%'                      THEN v.Val END) AS TotalPrefatura,
            SUM(CASE WHEN u.Produto LIKE 'Total adicionais%'                     THEN v.Val END) AS AdicionaisPortal,
            SUM(CASE WHEN u.Produto LIKE '%Subtotal%' AND u.Produto LIKE '%Lost Packages%' THEN v.Val END) AS PenLost,
            SUM(CASE WHEN u.Produto LIKE '%Subtotal%' AND u.Produto LIKE '%pnr%'          THEN v.Val END) AS PenPnr,
            SUM(CASE WHEN u.Produto LIKE '%Subtotal%' AND u.Produto LIKE '%Not Visited%'    THEN v.Val END) AS PenNotVisited,
            SUM(CASE WHEN u.Produto LIKE 'Total penalidades%'                    THEN v.Val END) AS TotalPenalidades,
            SUM(CASE WHEN u.Produto LIKE 'Total com CTE%'                        THEN v.Val END) AS TotalComCTE
        FROM dbo.tb_fin_prefatura_upload u WITH (NOLOCK)
        CROSS APPLY
        (
            SELECT TRY_CAST(
                       REPLACE(REPLACE(REPLACE(u.Column8, '+', ''), ' ', ''), 'R$', '')
                       AS decimal(18,2)) AS Val
        ) v
        WHERE u.Column8 IS NOT NULL
          AND u.Column8 <> ''
        GROUP BY u.IdTransportadora, u.Ano, u.Mes, u.Quinzena
    ),
    Cabecalho AS
    (
        -- linha-header do upload: Periodo '20??Q_' + IDPrefatura numerico
        SELECT IdTransportadora, Ano, Mes, Quinzena,
               MAX(IDPrefatura) AS IDPrefatura
        FROM dbo.tb_fin_prefatura_upload WITH (NOLOCK)
        WHERE Periodo LIKE '20%Q_'
          AND IDPrefatura IS NOT NULL
          AND IDPrefatura NOT LIKE '%[A-Z]%'          -- exclui placas das linhas de detalhe
          AND TRY_CAST(IDPrefatura AS bigint) IS NOT NULL
        GROUP BY IdTransportadora, Ano, Mes, Quinzena
    ),
    Itemizado AS
    (
        SELECT IdTransportadora, Ano, Mes, Quinzena,
               SUM(CONVERT(decimal(18,2), Total))    AS SubtotalServicos,
               SUM(CONVERT(decimal(18,2), VLParada)) AS SubtotalAdicionais
        FROM dbo.tb_fin_prefatura WITH (NOLOCK)
        GROUP BY IdTransportadora, Ano, Mes, Quinzena
    )
    INSERT INTO dbo.tb_fin_prefatura_totais
        (IdTransportadora, Ano, Mes, Quinzena, IDPrefatura,
         SubtotalPrefatura, TotalPrefatura, AdicionaisPortal,
         PenLost, PenPnr, PenNotVisited, TotalPenalidades, TotalComCTE,
         SubtotalServicos, SubtotalAdicionais)
    SELECT
        COALESCE(t.IdTransportadora, p.IdTransportadora),
        COALESCE(t.Ano, p.Ano),
        COALESCE(t.Mes, p.Mes),
        COALESCE(t.Quinzena, p.Quinzena),
        c.IDPrefatura,
        t.SubtotalPrefatura,
        t.TotalPrefatura,
        t.AdicionaisPortal,
        t.PenLost,
        t.PenPnr,
        t.PenNotVisited,
        t.TotalPenalidades,
        t.TotalComCTE,
        p.SubtotalServicos,
        p.SubtotalAdicionais
    FROM TotaisCsv t
    FULL OUTER JOIN Itemizado p
        ON  p.IdTransportadora = t.IdTransportadora
        AND p.Ano              = t.Ano
        AND p.Mes              = t.Mes
        AND p.Quinzena         = t.Quinzena
    LEFT JOIN Cabecalho c
        ON  c.IdTransportadora = COALESCE(t.IdTransportadora, p.IdTransportadora)
        AND c.Ano              = COALESCE(t.Ano, p.Ano)
        AND c.Mes              = COALESCE(t.Mes, p.Mes)
        AND c.Quinzena         = COALESCE(t.Quinzena, p.Quinzena);

    PRINT 'Backfill concluido: ' + CAST(@@ROWCOUNT AS varchar) + ' periodos inseridos.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (backfill): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2.3 View de consumo - totais + cliente + rotulo de periodo
--============================================================================
BEGIN TRY
    EXEC('
    CREATE VIEW dbo.vw_fin_prefatura_totais AS
    SELECT
        t.IdTransportadora,
        c.cli_cd_codigo_cliente AS CodCliente,
        c.cli_ds_nome           AS Cliente,
        t.Ano,
        t.Mes,
        t.Quinzena,
        CONCAT(t.Ano, RIGHT(''0'' + CONVERT(varchar(2), t.Mes), 2), ''Q'', t.Quinzena) AS PeriodoML,
        t.IDPrefatura,
        t.SubtotalServicos,
        t.SubtotalAdicionais,
        t.SubtotalPrefatura,
        t.GlosaPrefatura,
        t.AdicionaisPortal,
        t.PenLost,
        t.PenPnr,
        t.PenNotVisited,
        t.TotalPenalidades,
        t.TotalPrefatura,
        t.TotalComCTE,
        t.DataCarga
    FROM dbo.tb_fin_prefatura_totais t
    LEFT JOIN dbo.tb_clientes c WITH (NOLOCK)
        ON c.cli_id_logistics = t.IdTransportadora
    ');

    PRINT 'View dbo.vw_fin_prefatura_totais criada.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (create view): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 3. POS-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fin_prefatura_totais'))
        THROW 50011, 'Pos-check: tabela nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_fin_prefatura_totais'))
        THROW 50012, 'Pos-check: view nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.tb_fin_prefatura_totais WITH (NOLOCK))
        THROW 50013, 'Pos-check: backfill nao inseriu linhas.', 1;

    DECLARE @n INT = (SELECT COUNT(*) FROM dbo.tb_fin_prefatura_totais WITH (NOLOCK));
    PRINT 'Pos-check OK: ' + CAST(@n AS varchar) + ' linhas em tb_fin_prefatura_totais.';
    PRINT 'SUCESSO: Script executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pos-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
