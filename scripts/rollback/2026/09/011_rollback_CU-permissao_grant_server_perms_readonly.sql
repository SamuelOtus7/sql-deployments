/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-permissao
  Autor        : Devin (a pedido de Samuel Nogueira)
  Data         : 2026-09-28
  Descrição    : Reverte o forward 011 removendo as permissões de servidor
                 VIEW SERVER STATE, VIEW SERVER PERFORMANCE STATE e
                 VIEW ANY DEFINITION dos logins usr.eduardo.franco e
                 usr.gustavo.tavares.
                 ATENÇÃO: em PROD, usr.gustavo.tavares já possuía
                 VIEW SERVER PERFORMANCE STATE ANTES do forward. Para voltar
                 ao estado anterior exato em PROD, NÃO revogar essa permissão
                 específica de usr.gustavo.tavares — comentar a linha
                 correspondente antes de executar.
  Forward ref  : scripts/forward/2026/09/011_forward_CU-permissao_grant_server_perms_readonly.sql
  Objetos      : Permissões de servidor (server-level) sobre os logins
                 usr.eduardo.franco e usr.gustavo.tavares
  ==============================================================================
  ATENÇÃO: Este script deve reverter EXATAMENTE o que o forward fez.
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr.eduardo.franco')
        THROW 50001, 'Login usr.eduardo.franco não existe no servidor.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr.gustavo.tavares')
        THROW 50002, 'Login usr.gustavo.tavares não existe no servidor.', 1;

    --==========================================================================
    -- 2. SCRIPT DE ROLLBACK
    --==========================================================================
    REVOKE VIEW SERVER STATE              FROM [usr.eduardo.franco];
    REVOKE VIEW SERVER PERFORMANCE STATE  FROM [usr.eduardo.franco];
    REVOKE VIEW ANY DEFINITION            FROM [usr.eduardo.franco];

    REVOKE VIEW SERVER STATE              FROM [usr.gustavo.tavares];
    REVOKE VIEW SERVER PERFORMANCE STATE  FROM [usr.gustavo.tavares];
    REVOKE VIEW ANY DEFINITION            FROM [usr.gustavo.tavares];

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF (
        SELECT COUNT(*)
        FROM sys.server_permissions perm
        JOIN sys.server_principals sp
            ON sp.principal_id = perm.grantee_principal_id
        WHERE sp.name IN ('usr.eduardo.franco', 'usr.gustavo.tavares')
          AND perm.permission_name IN (
              'VIEW SERVER STATE',
              'VIEW ANY DEFINITION'
          )
          AND perm.state_desc = 'GRANT'
    ) > 0
        THROW 50003, 'Pós-check falhou: ainda existem permissões concedidas pelo forward.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
