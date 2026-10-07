/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin
  Data         : 2026-09-16
  Descrição    : Cria tabelas fisicas de apoio ao dashboard de volume de coleta
                 para eliminar as queries pesadas online (window functions +
                 CHECKSUM sobre milhoes de linhas com JSON varchar(max)).
                 Banco alvo: db_Irisys_Json (mesmo banco das tabelas origem).

                 Objetos criados:
                 1. dbo.tb_dash_coleta_controle        - watermark por tabela
                 2. dbo.tb_dash_coleta_volume_minuto   - volume no grao minuto
                    (tabela, dh_minuto, transportadora, extra_valor, qtd)
                    Atende: /api/serie, /api/volume-meia-hora, /api/resumo,
                    /api/clientes, /api/extra-valores, /api/datas-extremas
                 3. dbo.tb_dash_coleta_contexto_evento - evento enxuto por
                    coleta (sem JSON; com json_hash para comparacao)
                    Atende: contexto-resumo, contexto-resumo-transportadora,
                    contexto-top, ofensores-coleta, contexto-detalhe
                 4. dbo.sp_dash_coleta_refresh - carga incremental com
                    lookback de 120 minutos (cobre registros atrasados)

                 Nota semantica: contexto nulo/vazio e gravado como '-' no
                 mart (mesmo de-para aplicado hoje pela API em contexto-top).
                 json_hash usa CHECKSUM do JSON para todas as tabelas (antes,
                 tabelas ML usavam DATALENGTH; CHECKSUM detecta mudanca de
                 conteudo com mesmo tamanho e e strictamente melhor).

  Rollback     : scripts/rollback/2026/09/005_rollback_CU-86ak71ymk.sql
  Objetos      : dbo.tb_dash_coleta_controle, dbo.tb_dash_coleta_volume_minuto,
                 dbo.tb_dash_coleta_contexto_evento, dbo.sp_dash_coleta_refresh
  Dependências : dbo.tb_dra_coleta, dbo.tb_ml_coleta_motoristas,
                 dbo.tb_ml_coleta_rotas, dbo.tb_ml_coleta_totalizador,
                 dbo.tb_ml_coleta_veiculos
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    /*==========================================================================
       1. Tabela de controle (watermark incremental por tabela origem)
       ==========================================================================*/
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_dash_coleta_controle') AND type = 'U')
    BEGIN
        CREATE TABLE dbo.tb_dash_coleta_controle (
            tabela           varchar(50)  NOT NULL,
            ultima_dh        datetime     NOT NULL,
            ultima_execucao  datetime     NOT NULL,
            CONSTRAINT PK_dash_coleta_controle PRIMARY KEY CLUSTERED (tabela)
        );
    END;

    /*==========================================================================
       2. Mart de volume no grao minuto
       ==========================================================================*/
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_dash_coleta_volume_minuto') AND type = 'U')
    BEGIN
        CREATE TABLE dbo.tb_dash_coleta_volume_minuto (
            tabela          varchar(50)   NOT NULL,
            dh_minuto       datetime      NOT NULL,
            transportadora  varchar(20)   NOT NULL,
            extra_valor     varchar(100)  NOT NULL,
            qtd             int           NOT NULL,
            CONSTRAINT PK_dash_coleta_volume_minuto
                PRIMARY KEY CLUSTERED (tabela, dh_minuto, transportadora, extra_valor)
        );

        CREATE NONCLUSTERED INDEX IX_dash_volume_transp
            ON dbo.tb_dash_coleta_volume_minuto (tabela, transportadora, dh_minuto)
            INCLUDE (extra_valor, qtd);

        CREATE NONCLUSTERED INDEX IX_dash_volume_extra
            ON dbo.tb_dash_coleta_volume_minuto (tabela, extra_valor, dh_minuto)
            INCLUDE (transportadora, qtd);
    END;

    /*==========================================================================
       3. Mart de eventos de contexto (sem JSON - guarda so o hash)
       ==========================================================================*/
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_dash_coleta_contexto_evento') AND type = 'U')
    BEGIN
        CREATE TABLE dbo.tb_dash_coleta_contexto_evento (
            tabela          varchar(50)   NOT NULL,
            tipo            varchar(100)  NOT NULL,
            contexto        varchar(60)   NOT NULL,
            transportadora  varchar(20)   NOT NULL,
            dh              datetime      NOT NULL,
            json_hash       int           NULL,
            CONSTRAINT PK_dash_coleta_contexto_evento
                PRIMARY KEY CLUSTERED (tabela, tipo, contexto, dh, transportadora)
        );

        CREATE NONCLUSTERED INDEX IX_dash_ctx_transp
            ON dbo.tb_dash_coleta_contexto_evento (tabela, transportadora, tipo, contexto, dh)
            INCLUDE (json_hash);

        CREATE NONCLUSTERED INDEX IX_dash_ctx_dh
            ON dbo.tb_dash_coleta_contexto_evento (tabela, dh)
            INCLUDE (tipo, contexto, transportadora, json_hash);
    END;

    PRINT 'SUCESSO: tabelas de apoio do dashboard criadas.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO

/*==============================================================================
   4. Procedure de refresh incremental
   ----------------------------------------------------------------------------
   Estrategia: para cada tabela origem, reprocessa a janela
   [ultima_dh - 120min, max(dh_origem)] — DELETE + INSERT no mart, o que torna
   o processo idempotente e tolerante a registros que chegam atrasados.
   A primeira execucao faz backfill completo em lotes de 7 dias para evitar
   transacoes gigantes no log.
   ============================================================================*/
CREATE OR ALTER PROCEDURE dbo.sp_dash_coleta_refresh
    @lookback_min int = 120
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @agora datetime = GETDATE();
    DECLARE @ini datetime, @fim datetime, @lote_fim datetime, @min_origem datetime;
    DECLARE @chunk_dias int = 7;

    /* Mapa das tabelas origem (whitelist fixa - nao vem de parametro externo) */
    DECLARE @mapa TABLE (
        tabela       varchar(50)  NOT NULL PRIMARY KEY,
        col_dh       sysname      NOT NULL,
        col_transp   sysname      NOT NULL,
        col_contexto sysname      NOT NULL,
        col_tipo     sysname      NULL,
        col_extra    sysname      NULL,
        col_json     sysname      NOT NULL
    );

    INSERT INTO @mapa (tabela, col_dh, col_transp, col_contexto, col_tipo, col_extra, col_json)
    VALUES
        ('tb_dra_coleta',            'dac_dh_coleta', 'dac_cd_transportadora', 'dac_ds_contexto',       'dac_ds_tipo_coleta', 'dac_ds_tipo_coleta',   'dac_ds_contexto_json'),
        ('tb_ml_coleta_motoristas',  'cmm_dh_coleta', 'cmm_cd_transportadora', 'cmm_cd_transportadora', NULL,                 NULL,                   'cmm_ds_json'),
        ('tb_ml_coleta_rotas',       'cmr_dh_coleta', 'cmr_cd_transportadora', 'cmr_cd_rota',           NULL,                 NULL,                   'cmr_ds_json'),
        ('tb_ml_coleta_totalizador', 'cmt_dh_coleta', 'cmt_cd_transportadora', 'cmt_cd_servicecenter',  NULL,                 'cmt_cd_servicecenter', 'cmt_ds_json'),
        ('tb_ml_coleta_veiculos',    'cmv_dh_coleta', 'cmv_cd_transportadora', 'cmv_cd_transportadora', NULL,                 NULL,                   'cmv_ds_json');

    /* Seed: garante linha de controle por tabela origem */
    INSERT INTO dbo.tb_dash_coleta_controle (tabela, ultima_dh, ultima_execucao)
    SELECT m.tabela, '19000101', @agora
    FROM @mapa m
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.tb_dash_coleta_controle c WHERE c.tabela = m.tabela
    );

    /* NOLOCK: dirty read e aceitavel aqui porque o mart e reprocessado a cada
       refresh (lookback 120min) — uma leitura suja e corrigida na execucao
       seguinte; o custo de lock nas tabelas online e o problema que este
       martamento veio resolver. */
    DECLARE @tabela varchar(50), @col_dh sysname, @col_transp sysname,
            @col_contexto sysname, @col_tipo sysname, @col_extra sysname, @col_json sysname;
    DECLARE @sql nvarchar(max);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT tabela, col_dh, col_transp, col_contexto, col_tipo, col_extra, col_json FROM @mapa;
    OPEN cur;
    FETCH NEXT FROM cur INTO @tabela, @col_dh, @col_transp, @col_contexto, @col_tipo, @col_extra, @col_json;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @ini = DATEADD(MINUTE, -@lookback_min, c.ultima_dh)
        FROM dbo.tb_dash_coleta_controle c WHERE c.tabela = @tabela;

        SET @sql = N'SELECT @fim_out = MAX(' + QUOTENAME(@col_dh) + N'), @min_out = MIN(' + QUOTENAME(@col_dh) + N') FROM dbo.' + QUOTENAME(@tabela) + N' WITH (NOLOCK)'; /* NOLOCK tolerado: dirty read corrigido no proximo refresh */
        EXEC sp_executesql @sql, N'@fim_out datetime OUTPUT, @min_out datetime OUTPUT', @fim_out = @fim OUTPUT, @min_out = @min_origem OUTPUT;

        /* primeira execucao: comeca do MIN da origem, nao do sentinel 1900 */
        IF @min_origem IS NOT NULL AND @ini < @min_origem
            SET @ini = @min_origem;

        IF @fim IS NOT NULL AND @ini < @fim
        BEGIN
            WHILE @ini < @fim
            BEGIN
                SET @lote_fim = DATEADD(DAY, @chunk_dias, @ini);
                IF @lote_fim >= @fim SET @lote_fim = DATEADD(SECOND, 1, @fim);

                /* ----- mart de volume (grao minuto) ----- */
                DELETE FROM dbo.tb_dash_coleta_volume_minuto
                WHERE tabela = @tabela
                  AND dh_minuto >= DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @ini), 0)
                  AND dh_minuto <  DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @lote_fim), 0);

                SET @sql = N'
                    INSERT INTO dbo.tb_dash_coleta_volume_minuto (tabela, dh_minuto, transportadora, extra_valor, qtd)
                    SELECT ''' + @tabela + ''',
                           DATEADD(MINUTE, DATEDIFF(MINUTE, 0, ' + QUOTENAME(@col_dh) + '), 0),
                           ISNULL(CAST(' + QUOTENAME(@col_transp) + ' AS varchar(20)), ''''),
                           ' + CASE WHEN @col_extra IS NULL THEN '''''' ELSE 'ISNULL(CAST(' + QUOTENAME(@col_extra) + ' AS varchar(100)), '''')' END + ',
                           COUNT(*)
                    FROM dbo.' + QUOTENAME(@tabela) + ' WITH (NOLOCK) /* NOLOCK tolerado: dirty read corrigido no proximo refresh */
                    WHERE ' + QUOTENAME(@col_dh) + ' >= @p_ini AND ' + QUOTENAME(@col_dh) + ' < @p_fim
                          AND ' + QUOTENAME(@col_dh) + ' IS NOT NULL
                    GROUP BY DATEADD(MINUTE, DATEDIFF(MINUTE, 0, ' + QUOTENAME(@col_dh) + '), 0),
                             ISNULL(CAST(' + QUOTENAME(@col_transp) + ' AS varchar(20)), ''''),
                             ' + CASE WHEN @col_extra IS NULL THEN '''''' ELSE 'ISNULL(CAST(' + QUOTENAME(@col_extra) + ' AS varchar(100)), '''')' END;
                EXEC sp_executesql @sql, N'@p_ini datetime, @p_fim datetime', @p_ini = @ini, @p_fim = @lote_fim;

                /* ----- mart de eventos de contexto ----- */
                DELETE FROM dbo.tb_dash_coleta_contexto_evento
                WHERE tabela = @tabela AND dh >= @ini AND dh < @lote_fim;

                SET @sql = N'
                    INSERT INTO dbo.tb_dash_coleta_contexto_evento (tabela, tipo, contexto, transportadora, dh, json_hash)
                    SELECT ''' + @tabela + ''',
                           ' + CASE WHEN @col_tipo IS NULL THEN '''''' ELSE 'ISNULL(CAST(' + QUOTENAME(@col_tipo) + ' AS varchar(100)), '''')' END + ',
                           ISNULL(NULLIF(CAST(' + QUOTENAME(@col_contexto) + ' AS varchar(60)), ''''), ''-''),
                           ISNULL(CAST(' + QUOTENAME(@col_transp) + ' AS varchar(20)), ''''),
                           ' + QUOTENAME(@col_dh) + ',
                           CHECKSUM(' + QUOTENAME(@col_json) + ')
                    FROM dbo.' + QUOTENAME(@tabela) + ' WITH (NOLOCK) /* NOLOCK tolerado: dirty read corrigido no proximo refresh */
                    WHERE ' + QUOTENAME(@col_dh) + ' >= @p_ini AND ' + QUOTENAME(@col_dh) + ' < @p_fim
                          AND ' + QUOTENAME(@col_dh) + ' IS NOT NULL;
                EXEC sp_executesql @sql, N'@p_ini datetime, @p_fim datetime', @p_ini = @ini, @p_fim = @lote_fim;

                SET @ini = @lote_fim;
            END;
        END;

        UPDATE dbo.tb_dash_coleta_controle
        SET ultima_dh = ISNULL(@fim, ultima_dh), ultima_execucao = @agora
        WHERE tabela = @tabela;

        SET @fim = NULL;
        SET @min_origem = NULL;
        FETCH NEXT FROM cur INTO @tabela, @col_dh, @col_transp, @col_contexto, @col_tipo, @col_extra, @col_json;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END
GO

/*==============================================================================
   5. POS-CHECK
   ============================================================================*/
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.sp_dash_coleta_refresh') AND type = 'P')
    THROW 50004, 'sp_dash_coleta_refresh nao foi criada', 1;

PRINT 'SUCESSO: sp_dash_coleta_refresh criada.';
GO
