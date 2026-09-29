/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin (Samuel Nogueira)
  Data         : 2026-09-29
  Descrição    : Registra o processo de coleta diária PNR BSC (Looker) em
                 dbo.tb_pbi_mon_processo, para que vw_pbi_mon_alertas_processos
                 monitore se a coleta está sendo atualizada diariamente.
                 Origem : dbo.tb_looker_pnr (staging da coleta Looker, colunas
                 DataExtracao/CodigoCliente).
                 Destino: dbo.tb_pnr_bsc (tabela tratada, freshness por
                 pnr_dh_criacao, data de negócio pnr_dh_ocorrencia).
                 Habilitação por cliente segue o parâmetro 'Habilitar PNR BSC'
                 (tb_parametros, categoria 'Financeiro - Pagamentos').
  Rollback     : scripts/rollback/2026/09/011_rollback_CU-86ak71ymk.sql
  Objetos      : INSERT em dbo.tb_pbi_mon_processo (processo_codigo LOOKER_PNR)
  Dependências : tb_looker_pnr, tb_pnr_bsc, USPTrataStagingPNRBSC,
                 vw_pbi_mon_alertas_processos (consome tb_pbi_mon_processo)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_pnr_bsc') AND type = 'U')
        THROW 50001, 'PRE-CHECK FALHOU: dbo.tb_pnr_bsc nao existe.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_looker_pnr') AND type = 'U')
        THROW 50002, 'PRE-CHECK FALHOU: dbo.tb_looker_pnr nao existe.', 1;

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL (idempotente)
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1 FROM dbo.tb_pbi_mon_processo
        WHERE processo_codigo = 'LOOKER_PNR'
    )
    BEGIN
        INSERT INTO dbo.tb_pbi_mon_processo
        (
              processo_codigo
            , processo_nome
            , tabela_destino
            , plataforma
            , proc_orquestrador
            , proc_carga
            , origem_banco
            , origem_tabela
            , origem_filtro
            , origem_col_data
            , origem_col_transportadora
            , origem_col_freshness
            , origem_col_processado
            , tipo_regra
            , in_origem_irisys_json
            , destino_col_data
            , destino_col_transportadora
            , destino_col_freshness
            , destino_col_etl
            , nr_lag_dias_negocio
            , hr_validacao
            , id_cliente_campo
            , sla_minutos
            , parametro_habilita
            , in_ativo
            , ds_acao_origem
            , ds_acao_destino
            , ds_acao_job
            , sla_label
            , destino_regra
            , nr_tolerancia_fila
            , in_origem_obrigatoria
            , in_acao_habilitada
        )
        VALUES
        (
              'LOOKER_PNR'                                  -- processo_codigo
            , N'Looker PNR / BSC'                           -- processo_nome
            , 'tb_pnr_bsc'                                  -- tabela_destino
            , 'Looker'                                      -- plataforma
            , NULL                                          -- proc_orquestrador
            , 'USPTrataStagingPNRBSC'                       -- proc_carga
            , 'dbo'                                         -- origem_banco
            , 'tb_looker_pnr'                               -- origem_tabela
            , NULL                                          -- origem_filtro
            , 'DataExtracao'                                -- origem_col_data
            , 'CodigoCliente'                               -- origem_col_transportadora
            , 'DataExtracao'                                -- origem_col_freshness
            , NULL                                          -- origem_col_processado
            , 'LOOKER_DIARIO'                               -- tipo_regra
            , 0                                             -- in_origem_irisys_json
            , 'pnr_dh_ocorrencia'                           -- destino_col_data
            , 'pnr_cd_cliente'                              -- destino_col_transportadora
            , 'pnr_dh_criacao'                              -- destino_col_freshness
            , 'pnr_dh_criacao'                              -- destino_col_etl
            , 2                                             -- nr_lag_dias_negocio
            , '08:00'                                       -- hr_validacao
            , 'cli_id_logistics'                            -- id_cliente_campo
            , 5                                             -- sla_minutos
            , N'Habilitar PNR BSC'                          -- parametro_habilita
            , 1                                             -- in_ativo
            , N'A coleta de dados nao trouxe registros de hoje.'  -- ds_acao_origem
            , N'Os dados de hoje ainda nao foram carregados.'     -- ds_acao_destino
            , N'O processo automatico nao concluiu com sucesso hoje.' -- ds_acao_job
            , N'5 minutos'                                  -- sla_label
            , 'FRESHNESS'                                   -- destino_regra
            , 0                                             -- nr_tolerancia_fila
            , 1                                             -- in_origem_obrigatoria
            , 0                                             -- in_acao_habilitada
        );
    END

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1 FROM dbo.tb_pbi_mon_processo
        WHERE processo_codigo = 'LOOKER_PNR' AND in_ativo = 1
    )
        THROW 50003, 'POS-CHECK FALHOU: processo LOOKER_PNR nao registrado/ativo.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    -- Re-raise para que a aplicação capture
    THROW;
END CATCH;
GO
