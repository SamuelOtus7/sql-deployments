/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqxyka
  Autor        : Devin
  Data         : 2026-10-02
  Descrição    : Remove a procedure dbo.USPTrataStagingParadasBSC e as colunas
                 adicionadas em dbo.tb_ml_bsc_paradas pelo script forward 023
                 (DataRota, DataExtracao, dimensoes de rota e motivos de
                 insucesso). ATENCAO: os dados gravados nessas colunas serao
                 perdidos ao dropar.
                 Restaura tb_ml_bsc_paradas ao estado original
                 (IdParada, IdCliente, IdRota, QuantidadeParadas).
  Forward ref  : scripts/forward/2026/10/023_forward_CU-86akqxyka_proc_load_paradas_bsc.sql
  Objetos      : dbo.USPTrataStagingParadasBSC (DROP),
                 dbo.tb_ml_bsc_paradas (ALTER TABLE DROP COLUMN)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_paradas'))
        THROW 50045, 'Tabela dbo.tb_ml_bsc_paradas nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

--==========================================================================
-- 2. DROP PROCEDURE
--==========================================================================
IF OBJECT_ID('dbo.USPTrataStagingParadasBSC', 'P') IS NOT NULL
    DROP PROCEDURE dbo.USPTrataStagingParadasBSC;
GO

--==========================================================================
-- 3. DROP COLUMNs adicionadas pelo forward
--==========================================================================
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_paradas') AND name = 'DataRota')
BEGIN
    ALTER TABLE dbo.tb_ml_bsc_paradas DROP COLUMN
        DataRota,
        DataExtracao,
        Regional,
        SVC,
        XPT,
        MLP,
        PerfilVeiculoExecutado,
        Ciclo,
        Cluster,
        IdMotorista,
        ExperienciaDriver,
        Placa,
        IdVeiculo,
        Veiculo,
        HoraInicio,
        HoraFim,
        ORH_PLAN,
        ORH_HOURS,
        KM_PLAN,
        KM_REAL,
        STEM_OUT,
        QuantidadePacotes,
        QuantidadeEntregue,
        QuantidadeDS,
        QuantidadeAtStation,
        QuantidadeInsucessos,
        InsucessoInaccessibleAddress,
        InsucessoBuyerRejected,
        InsucessoBuyerMoved,
        InsucessoBuyerAbsent,
        InsucessoBusinessClosed,
        InsucessoBlockedByKeyword,
        InsucessoBadAddress,
        InsucessoNotAttempted,
        InsucessoOutrosMotivos;
END
GO

--==========================================================================
-- 4. POS-CHECKS
--==========================================================================
BEGIN TRY
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.USPTrataStagingParadasBSC'))
        THROW 50046, 'Procedure dbo.USPTrataStagingParadasBSC nao foi removida.', 1;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_paradas') AND name = 'DataRota')
        THROW 50047, 'Colunas adicionadas nao foram removidas de tb_ml_bsc_paradas.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
