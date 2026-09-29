/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin (Samuel Nogueira)
  Data         : 2026-09-30
  Descrição    : Publica os objetos de coleta/tratamento do PNR BSC:
                 (1) índice de apoio na staging dbo.tb_looker_pnr
                     (CodigoCliente, DataExtracao) — staging ~21M linhas sem
                     índice; sem ele cada execução varre a tabela inteira;
                 (2) dbo.tb_pnr_bsc — tabela tratada/normalizada alimentada a
                     partir da staging, com dedup UNIQUE (cliente, pacote);
                 (3) dbo.USPTrataStagingPNRBSC — normaliza a staging (data PT-BR,
                     BPP decimal, SVC) e faz MERGE em tb_pnr_bsc;
                 (4) parâmetro 'Habilitar PNR BSC' (Financeiro - Pagamentos)
                     para o cliente 61 (Rodoprime) — gate consumido pela
                     procedure de tratamento; sem ele a coleta não traz linhas.
                 ESCOPO: NÃO inclui USPGeraLancamentosManuaisPNRBSC nem os seeds
                 da etapa de lançamentos manuais ('Aprovação Automática PNR BSC',
                 tipo 'PNR - BSC'), conforme orientação — esta entrega cobre
                 apenas a coleta/normalização.
  Rollback     : scripts/rollback/2026/09/013_rollback_CU-86ak71ymk_pnr_bsc_objetos.sql
  Objetos      : INDEX ix_tb_looker_pnr_cliente_extracao, TABLE dbo.tb_pnr_bsc,
                 PROCEDURE dbo.USPTrataStagingPNRBSC,
                 INSERT dbo.tb_parametros ('Habilitar PNR BSC', cliente 61)
  Dependências : dbo.tb_looker_pnr, dbo.tb_parametros, dbo.tb_clientes
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_looker_pnr') AND type = 'U')
        THROW 50001, 'PRE-CHECK FALHOU: dbo.tb_looker_pnr nao existe.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.tb_clientes WHERE cli_cd_codigo_cliente = 61)
        THROW 50002, 'PRE-CHECK FALHOU: cliente 61 (Rodoprime) nao existe em tb_clientes.', 1;

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL (idempotente)
    --==========================================================================

    -- 2.1 Índice de apoio na staging
    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.tb_looker_pnr')
          AND name = N'ix_tb_looker_pnr_cliente_extracao'
    )
    CREATE NONCLUSTERED INDEX ix_tb_looker_pnr_cliente_extracao
        ON dbo.tb_looker_pnr (CodigoCliente, DataExtracao)
        WITH (ONLINE = OFF, FILLFACTOR = 90);

    -- 2.2 Tabela tratada
    IF OBJECT_ID(N'dbo.tb_pnr_bsc', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.tb_pnr_bsc
        (
              pnr_cd_pnr                INT            IDENTITY(1,1) NOT NULL PRIMARY KEY
            , pnr_cd_cliente            INT            NOT NULL
            , pnr_cd_caso               BIGINT         NULL
            , pnr_cd_claim              BIGINT         NULL
            , pnr_ds_status             VARCHAR(100)   NULL
            , pnr_ds_case_status        VARCHAR(50)    NULL
            , pnr_dh_ocorrencia         DATETIME       NULL  -- DATA parseada (PT-BR)
            , pnr_dt_extracao           DATE           NULL  -- DataExtracao do snapshot
            , pnr_cd_pacote             BIGINT         NOT NULL -- SHIPMENT
            , pnr_cd_rota_bsc           BIGINT         NULL  -- ROUTE_ID (origem BSC)
            , pnr_cd_motorista_bsc      BIGINT         NULL  -- DRIVER (origem BSC)
            , pnr_cd_veiculo_bsc        BIGINT         NULL  -- VEICULO_ID
            , pnr_ds_svc                VARCHAR(10)    NULL  -- SVC normalizado
            , pnr_ds_rep_id             VARCHAR(100)   NULL
            , pnr_ds_mlp                VARCHAR(150)   NULL
            , pnr_vl_pnr                DECIMAL(18,2)  NULL  -- BPP convertido
            , pnr_in_processado         BIT            NOT NULL DEFAULT (0)
            , pnr_cd_lancamento_manual  INT            NULL  -- vínculo com tb_lancamentos_manuais
            , pnr_dh_criacao            DATETIME       NOT NULL DEFAULT (GETDATE())
            , pnr_dh_modificacao        DATETIME       NOT NULL DEFAULT (GETDATE())
        );

        CREATE UNIQUE NONCLUSTERED INDEX ux_tb_pnr_bsc_cliente_pacote
            ON dbo.tb_pnr_bsc (pnr_cd_cliente, pnr_cd_pacote);
    END

    -- 2.3 Parâmetro de habilitação da coleta (gate da USPTrataStagingPNRBSC)
    INSERT INTO dbo.tb_parametros
    (
          prm_nm_parametro, prm_ds_parametro, prm_ds_chave, prm_ds_valor
        , prm_ds_placeholder, prm_ds_options, prm_ds_categoria, prm_ds_tipo
        , prm_in_ativo, prm_in_excluido
        , prm_cd_usuario_criacao, prm_dh_criacao
        , prm_cd_usuario_modificacao, prm_dh_modificacao
        , prm_cod_cliente
    )
    SELECT
          N'Habilitar PNR BSC'
        , N'Automatiza lançamentos manuais de PNR faturado via BSC'
        , N'Habilitar PNR BSC'
        , N'1'
        , NULL
        , N'[{"label":"Ativo","value":"1"},{"label":"Inativo","value":"0"}]'
        , N'Financeiro - Pagamentos'
        , N'select'
        , 1, 0
        , 7, GETDATE()
        , 7, GETDATE()
        , 61
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tb_parametros p
        WHERE p.prm_cod_cliente  = 61
          AND p.prm_nm_parametro = N'Habilitar PNR BSC'
          AND p.prm_ds_categoria = N'Financeiro - Pagamentos'
          AND ISNULL(p.prm_in_excluido, 0) = 0
    );

    PRINT 'SUCESSO: indice, tabela e parametro criados/verificados.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO

--==============================================================================
-- 2.4 Procedure de tratamento (CREATE OR ALTER precisa ser 1a instrucao do batch)
--==============================================================================
CREATE OR ALTER PROCEDURE [dbo].[USPTrataStagingPNRBSC]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    ;WITH limite AS
    (
        SELECT MaxExtracao = MAX(DataExtracao)
        FROM dbo.tb_looker_pnr WITH (NOLOCK)
    ),
    src AS
    (
        SELECT
              lkp.CodigoCliente
            , lkp.CASO
            , lkp.CLA_CLAIM_ID
            , lkp.STATUS
            , lkp.CASE_STATUS
            , lkp.SHIPMENT
            , lkp.ROUTE_ID
            , lkp.DRIVER
            , lkp.VEICULO_ID
            , lkp.REP_ID
            , lkp.MLP
            , lkp.DataExtracao
            /* DATA vem como texto PT-BR: '10 de set. de 2026, 07:54:03' */
            , DhOcorrencia = TRY_CAST(CONCAT(
                  TRY_CAST(SUBSTRING(lkp.DATA, CHARINDEX(',', lkp.DATA) - 4, 4) AS int), '-',
                  RIGHT('0' + CAST(CASE LOWER(REPLACE(SUBSTRING(lkp.DATA, CHARINDEX(' de ', lkp.DATA) + 4, 4), '.', ''))
                      WHEN 'jan' THEN 1 WHEN 'fev' THEN 2 WHEN 'mar' THEN 3 WHEN 'abr' THEN 4
                      WHEN 'mai' THEN 5 WHEN 'jun' THEN 6 WHEN 'jul' THEN 7 WHEN 'ago' THEN 8
                      WHEN 'set' THEN 9 WHEN 'out' THEN 10 WHEN 'nov' THEN 11 WHEN 'dez' THEN 12
                  END AS varchar(2)), 2), '-',
                  RIGHT('0' + CAST(TRY_CAST(LEFT(lkp.DATA, CHARINDEX(' de ', lkp.DATA) - 1) AS int) AS varchar(2)), 2),
                  ' ', LTRIM(RTRIM(SUBSTRING(lkp.DATA, CHARINDEX(',', lkp.DATA) + 1, 20)))) AS datetime)
            , ValorPnr = TRY_CAST(REPLACE(LTRIM(RTRIM(lkp.BPP)), ',', '.') AS DECIMAL(18, 2))
            , Svc = CASE
                  WHEN lkp.SVC IS NULL THEN NULL
                  WHEN LTRIM(RTRIM(lkp.SVC)) = '' THEN NULL
                  WHEN LOWER(LTRIM(RTRIM(lkp.SVC))) IN ('undefined', 'null', 'n/a') THEN NULL
                  ELSE LEFT(LTRIM(RTRIM(lkp.SVC)), 10)
              END
            , rn = ROW_NUMBER() OVER (
                  PARTITION BY lkp.CodigoCliente, lkp.SHIPMENT
                  ORDER BY lkp.DataExtracao DESC
                         , CASE WHEN lkp.ROUTE_ID IS NOT NULL THEN 0 ELSE 1 END
                         , TRY_CAST(REPLACE(LTRIM(RTRIM(lkp.BPP)), ',', '.') AS DECIMAL(18, 2)) DESC
              )
        FROM dbo.tb_looker_pnr lkp WITH (NOLOCK)
        INNER JOIN dbo.tb_parametros prm WITH (NOLOCK)
                ON prm.prm_cod_cliente = lkp.CodigoCliente
               AND prm.prm_ds_categoria = N'Financeiro - Pagamentos'
               AND prm.prm_nm_parametro = N'Habilitar PNR BSC'
               AND prm.prm_ds_valor = N'1'
               AND ISNULL(prm.prm_in_ativo, 0) = 1
               AND ISNULL(prm.prm_in_excluido, 0) = 0
        CROSS JOIN limite lm
        WHERE lkp.SHIPMENT IS NOT NULL
          AND lkp.DataExtracao >= DATEADD(DAY, -30, lm.MaxExtracao)
    )
    MERGE dbo.tb_pnr_bsc AS dst
    USING (SELECT * FROM src WHERE rn = 1) AS s
       ON dst.pnr_cd_cliente = s.CodigoCliente
      AND dst.pnr_cd_pacote  = s.SHIPMENT
    WHEN MATCHED AND dst.pnr_in_processado = 0
                AND ISNULL(s.DataExtracao, '1900-01-01') > ISNULL(dst.pnr_dt_extracao, '1900-01-01')
        THEN UPDATE SET
              dst.pnr_cd_caso          = s.CASO
            , dst.pnr_cd_claim         = s.CLA_CLAIM_ID
            , dst.pnr_ds_status        = LEFT(s.STATUS, 100)
            , dst.pnr_ds_case_status   = LEFT(s.CASE_STATUS, 50)
            , dst.pnr_dh_ocorrencia    = s.DhOcorrencia
            , dst.pnr_dt_extracao      = s.DataExtracao
            , dst.pnr_cd_rota_bsc      = s.ROUTE_ID
            , dst.pnr_cd_motorista_bsc = s.DRIVER
            , dst.pnr_cd_veiculo_bsc   = s.VEICULO_ID
            , dst.pnr_ds_svc           = s.Svc
            , dst.pnr_ds_rep_id        = LEFT(s.REP_ID, 100)
            , dst.pnr_ds_mlp           = LEFT(s.MLP, 150)
            , dst.pnr_vl_pnr           = s.ValorPnr
            , dst.pnr_dh_modificacao   = GETDATE()
    WHEN NOT MATCHED BY TARGET
        THEN INSERT
        (
              pnr_cd_cliente, pnr_cd_caso, pnr_cd_claim, pnr_ds_status, pnr_ds_case_status
            , pnr_dh_ocorrencia, pnr_dt_extracao, pnr_cd_pacote, pnr_cd_rota_bsc
            , pnr_cd_motorista_bsc, pnr_cd_veiculo_bsc, pnr_ds_svc, pnr_ds_rep_id
            , pnr_ds_mlp, pnr_vl_pnr
        )
        VALUES
        (
              s.CodigoCliente, s.CASO, s.CLA_CLAIM_ID, LEFT(s.STATUS, 100), LEFT(s.CASE_STATUS, 50)
            , s.DhOcorrencia, s.DataExtracao, s.SHIPMENT, s.ROUTE_ID
            , s.DRIVER, s.VEICULO_ID, s.Svc, LEFT(s.REP_ID, 100)
            , LEFT(s.MLP, 150), s.ValorPnr
        );
END
GO

--==============================================================================
-- 3. POS-CHECKS
--==============================================================================
BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID('dbo.tb_looker_pnr')
          AND name = 'ix_tb_looker_pnr_cliente_extracao'
    )
        THROW 50003, 'POS-CHECK FALHOU: indice ix_tb_looker_pnr_cliente_extracao nao criado.', 1;

    IF OBJECT_ID('dbo.tb_pnr_bsc', 'U') IS NULL
        THROW 50004, 'POS-CHECK FALHOU: dbo.tb_pnr_bsc nao criada.', 1;

    IF OBJECT_ID('dbo.USPTrataStagingPNRBSC', 'P') IS NULL
        THROW 50005, 'POS-CHECK FALHOU: dbo.USPTrataStagingPNRBSC nao criada.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.tb_parametros
        WHERE prm_cod_cliente = 61
          AND prm_nm_parametro = N'Habilitar PNR BSC'
          AND prm_ds_categoria = N'Financeiro - Pagamentos'
          AND prm_ds_valor = N'1'
          AND ISNULL(prm_in_ativo, 0) = 1
          AND ISNULL(prm_in_excluido, 0) = 0
    )
        THROW 50006, 'POS-CHECK FALHOU: parametro Habilitar PNR BSC (cliente 61) nao registrado.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
