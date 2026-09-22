/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-SEM-TASK (dimensoes dos relatorios web)
  Autor        : Devin
  Data         : 2026-09-22
  Descrição    : Remove as views de dimensao dos relatorios web criadas pelo
                 forward 008 (vw_dim_base, vw_dim_cidade_ibge). Nao toca em
                 tabelas/dados — apenas DROP VIEW. Nenhum relatorio usa estas
                 views ate a integracao do backend ser publicada.
  Forward ref  : scripts/forward/2026/09/008_forward_dim_relatorios_web.sql
  Objetos      : VIEW dbo.vw_dim_base, VIEW dbo.vw_dim_cidade_ibge
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.vw_dim_base') AND type = 'V')
    BEGIN
        DROP VIEW dbo.vw_dim_base;
        PRINT 'vw_dim_base removida.';
    END;

    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.vw_dim_cidade_ibge') AND type = 'V')
    BEGIN
        DROP VIEW dbo.vw_dim_cidade_ibge;
        PRINT 'vw_dim_cidade_ibge removida.';
    END;

    -- POS-CHECK
    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.vw_dim_base')        AND type = 'V')
        THROW 50009, 'vw_dim_base ainda existe', 1;
    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.vw_dim_cidade_ibge') AND type = 'V')
        THROW 50009, 'vw_dim_cidade_ibge ainda existe', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
