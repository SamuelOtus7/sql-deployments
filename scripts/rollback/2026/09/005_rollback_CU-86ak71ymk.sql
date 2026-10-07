/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin
  Data         : 2026-09-16
  Descrição    : Remove as tabelas de apoio do dashboard de volume de coleta e
                 a procedure de refresh criadas pelo forward 005.
                 Banco alvo: db_Irisys_Json.
  Forward ref  : scripts/forward/2026/09/005_forward_CU-86ak71ymk.sql
  Objetos      : dbo.sp_dash_coleta_refresh, dbo.tb_dash_coleta_contexto_evento,
                 dbo.tb_dash_coleta_volume_minuto, dbo.tb_dash_coleta_controle
  ==============================================================================
  ATENÇÃO: executar primeiro o rollback 006 (job) se o job existir.
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.sp_dash_coleta_refresh') AND type = 'P')
        DROP PROCEDURE dbo.sp_dash_coleta_refresh;

    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_dash_coleta_contexto_evento') AND type = 'U')
        DROP TABLE dbo.tb_dash_coleta_contexto_evento;

    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_dash_coleta_volume_minuto') AND type = 'U')
        DROP TABLE dbo.tb_dash_coleta_volume_minuto;

    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_dash_coleta_controle') AND type = 'U')
        DROP TABLE dbo.tb_dash_coleta_controle;

    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.sp_dash_coleta_refresh'))
        THROW 50010, 'Rollback falhou: sp_dash_coleta_refresh ainda existe', 1;
    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_dash_coleta_contexto_evento'))
        THROW 50011, 'Rollback falhou: tb_dash_coleta_contexto_evento ainda existe', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO
