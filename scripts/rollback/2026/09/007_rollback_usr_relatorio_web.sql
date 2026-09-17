/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-SEM-TASK (login de servico usr_relatorio_web)
  Autor        : Devin
  Data         : 2026-09-17
  Descrição    : Reverte o forward 007: remove o usuario usr_relatorio_web do
                 banco atual e dropa o login de servidor usr_relatorio_web.
                 ATENCAO: todos os relatorios HTML web param de conectar apos
                 este rollback.
  Forward ref  : scripts/forward/2026/09/007_forward_usr_relatorio_web.sql
  Objetos      : USER usr_relatorio_web, LOGIN usr_relatorio_web
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    -- Derruba sessoes ativas do login (senao o DROP LOGIN falha)
    IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_relatorio_web')
    BEGIN
        DECLARE @spid INT;
        DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT session_id FROM sys.dm_exec_sessions
            WHERE login_name = N'usr_relatorio_web';
        OPEN cur;
        FETCH NEXT FROM cur INTO @spid;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC('KILL ' + @spid);
            FETCH NEXT FROM cur INTO @spid;
        END
        CLOSE cur;
        DEALLOCATE cur;
    END

    --==========================================================================
    -- 2. SCRIPT DE ROLLBACK
    --==========================================================================

    IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'usr_relatorio_web')
    BEGIN
        DROP USER [usr_relatorio_web];
        PRINT 'Usuario usr_relatorio_web removido do banco ' + DB_NAME() + '.';
    END
    ELSE
        PRINT 'Usuario usr_relatorio_web nao existia no banco ' + DB_NAME() + '.';

    IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_relatorio_web')
    BEGIN
        DROP LOGIN [usr_relatorio_web];
        PRINT 'Login usr_relatorio_web removido do servidor.';
    END
    ELSE
        PRINT 'Login usr_relatorio_web nao existia no servidor.';

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_relatorio_web')
        THROW 50006, 'Pos-check falhou: login usr_relatorio_web ainda existe.', 1;

    IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'usr_relatorio_web')
        THROW 50007, 'Pos-check falhou: usuario usr_relatorio_web ainda existe.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
