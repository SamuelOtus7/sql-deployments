/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin (Samuel Nogueira)
  Data         : 2026-09-30
  Descrição    : Registra o processo LOOKER_PARADAS em dbo.tb_pbi_mon_processo
                 para monitorar a coleta diária de dbo.tb_ml_bsc_paradas.
                 Investigação: nenhuma procedure/job do SQL Server grava essa
                 tabela — ela é alimentada por coletor externo BSC (mesma família
                 de tb_ml_bsc_rtt). Por isso o processo é destino-only
                 (in_origem_obrigatoria = 0, sem origem_tabela): a view de
                 cálculo avalia apenas o destino, com janela a partir de
                 hr_validacao (08:00) — padrão já suportado para
                 tipo_regra PIPELINE_5MIN.
                 Destino: ramo hardcoded na view (forward 016) faz join
                 tb_ml_bsc_paradas -> tb_ml_rotas (a tabela não tem coluna de
                 data; freshness e cliente veem da rota: IdTransportadora ->
                 cli_id_logistics, janela DataReferencia >= D-1).
                 Habilitação por cliente segue o parâmetro 'Km RTT'
                 (categoria 'Alertas') — mesma régua dos demais processos BSC.
  Rollback     : scripts/rollback/2026/09/015_rollback_CU-86ak71ymk_monitor_bsc_paradas.sql
  Objetos      : INSERT em dbo.tb_pbi_mon_processo (processo_codigo LOOKER_PARADAS)
  Dependências : tb_ml_bsc_paradas, tb_ml_rotas,
                 vw_pbi_mon_alertas_processos_calc (ramo no forward 016)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_paradas') AND type = 'U')
        THROW 50001, 'PRE-CHECK FALHOU: dbo.tb_ml_bsc_paradas nao existe.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_ml_rotas') AND type = 'U')
        THROW 50002, 'PRE-CHECK FALHOU: dbo.tb_ml_rotas nao existe.', 1;

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL (idempotente)
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1 FROM dbo.tb_pbi_mon_processo
        WHERE processo_codigo = 'LOOKER_PARADAS'
    )
    BEGIN
        INSERT INTO dbo.tb_pbi_mon_processo
        (
              processo_codigo
            , processo_nome
            , tabela_destino
            , plataforma
            , tipo_regra
            , in_origem_irisys_json
            , nr_lag_dias_negocio
            , hr_validacao
            , id_cliente_campo
            , sla_minutos
            , parametro_habilita
            , in_ativo
            , ds_acao_destino
            , ds_acao_job
            , sla_label
            , destino_regra
            , nr_tolerancia_fila
            , ds_acao_destino_sem_carga
            , ds_acao_destino_desatualizado
            , in_origem_obrigatoria
            , in_acao_habilitada
        )
        VALUES
        (
              'LOOKER_PARADAS'                              -- processo_codigo
            , N'Looker Paradas / BSC'                       -- processo_nome
            , 'tb_ml_bsc_paradas'                           -- tabela_destino
            , 'Looker'                                      -- plataforma
            , 'PIPELINE_5MIN'                               -- tipo_regra
            , 0                                             -- in_origem_irisys_json
            , 1                                             -- nr_lag_dias_negocio (janela D-1)
            , '08:00'                                       -- hr_validacao
            , 'cli_id_logistics'                            -- id_cliente_campo
            , 1440                                          -- sla_minutos (24h)
            , N'Km RTT'                                     -- parametro_habilita
            , 1                                             -- in_ativo
            , N'Os dados de destino nao foram atualizados desde {dh_ultimo_evento_destino} (limite: {sla_label}).' -- ds_acao_destino
            , N'O processo automatico nao concluiu com sucesso.'  -- ds_acao_job
            , N'24 horas'                                   -- sla_label
            , 'FRESHNESS'                                   -- destino_regra
            , 0                                             -- nr_tolerancia_fila
            , N'Os dados de hoje ainda nao foram carregados em tb_ml_bsc_paradas.'  -- ds_acao_destino_sem_carga
            , N'Os dados de destino nao foram atualizados desde {dh_ultimo_evento_destino} (limite: {sla_label}).' -- ds_acao_destino_desatualizado
            , 0                                             -- in_origem_obrigatoria (coletor externo)
            , 0                                             -- in_acao_habilitada
        );
    END

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1 FROM dbo.tb_pbi_mon_processo
        WHERE processo_codigo = 'LOOKER_PARADAS' AND in_ativo = 1
    )
        THROW 50003, 'POS-CHECK FALHOU: processo LOOKER_PARADAS nao registrado/ativo.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
