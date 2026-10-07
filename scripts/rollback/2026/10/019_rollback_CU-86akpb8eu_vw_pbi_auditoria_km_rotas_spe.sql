/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpb8eu
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Remove dbo.vw_pbi_auditoria_km_rotas_spe criada pelo forward
                 (objeto novo — não existia versão anterior para restaurar).
  Forward ref  : scripts/forward/2026/10/019_forward_CU-86akpb8eu_vw_pbi_auditoria_km_rotas_spe.sql
  Objetos      : dbo.vw_pbi_auditoria_km_rotas_spe (DROP)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF OBJECT_ID('dbo.vw_pbi_auditoria_km_rotas_spe', 'V') IS NOT NULL
    BEGIN
        DROP VIEW [dbo].[vw_pbi_auditoria_km_rotas_spe];
        PRINT 'View dbo.vw_pbi_auditoria_km_rotas_spe removida.';
    END
    ELSE
        PRINT 'View dbo.vw_pbi_auditoria_km_rotas_spe nao existia (idempotente).';

    IF EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_pbi_auditoria_km_rotas_spe'))
        THROW 50010, 'View dbo.vw_pbi_auditoria_km_rotas_spe ainda existe apos DROP.', 1;

    PRINT 'SUCESSO: Rollback de dbo.vw_pbi_auditoria_km_rotas_spe executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
