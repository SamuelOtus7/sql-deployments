/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-permissao
  Autor        : Devin (a pedido de Samuel Nogueira)
  Data         : 2026-09-28
  Descrição    : Concede permissões de servidor SOMENTE LEITURA aos logins
                 usr.eduardo.franco e usr.gustavo.tavares:
                   - VIEW SERVER STATE
                   - VIEW SERVER PERFORMANCE STATE
                   - VIEW ANY DEFINITION
                 Justificativa: observabilidade/diagnóstico (DMVs e metadados)
                 sem capacidade de escrita no nível do servidor.
                 NÃO concede (excluídas por terem escrita server-level):
                 ALTER ANY CONNECTION, ALTER ANY EVENT SESSION,
                 SQLAgentOperatorRole (msdb).
                 Nota: em PROD, usr.gustavo.tavares já possui
                 VIEW SERVER PERFORMANCE STATE — re-grant é idempotente.
  Rollback     : scripts/rollback/2026/09/011_rollback_CU-permissao_grant_server_perms_readonly.sql
  Objetos      : Permissões de servidor (server-level) sobre os logins
                 usr.eduardo.franco e usr.gustavo.tavares
  Dependências : Nenhuma. Executar no contexto do banco master.
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
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================
    GRANT VIEW SERVER STATE              TO [usr.eduardo.franco];
    GRANT VIEW SERVER PERFORMANCE STATE  TO [usr.eduardo.franco];
    GRANT VIEW ANY DEFINITION            TO [usr.eduardo.franco];

    GRANT VIEW SERVER STATE              TO [usr.gustavo.tavares];
    GRANT VIEW SERVER PERFORMANCE STATE  TO [usr.gustavo.tavares];
    GRANT VIEW ANY DEFINITION            TO [usr.gustavo.tavares];

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
              'VIEW SERVER PERFORMANCE STATE',
              'VIEW ANY DEFINITION'
          )
          AND perm.state_desc = 'GRANT'
    ) < 6
        THROW 50003, 'Pós-check falhou: as 6 permissões esperadas não foram concedidas.', 1;

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
