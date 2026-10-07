/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-SEM-TASK (login de servico usr_relatorio_web)
  Autor        : Devin
  Data         : 2026-09-17
  Descrição    : Cria o login SQL de servico 'usr_relatorio_web', usado por
                 TODOS os relatorios HTML web (padrao template-relatorio-padrao).
                 Concede acesso SOMENTE LEITURA ao banco da conexao atual
                 (db_Irisys em PROD / db_IrisysDev em QAS) via role db_datareader.
                 Nenhuma permissao de escrita e concedida.
  Rollback     : scripts/rollback/2026/09/007_rollback_usr_relatorio_web.sql
  Objetos      : LOGIN usr_relatorio_web, USER usr_relatorio_web (db_datareader)
  Dependências : nenhuma
  ------------------------------------------------------------------------------
  SEGURANCA: a senha NAO e commitada. Antes de executar, substitua o placeholder
  __SET_PASSWORD__ pela senha forte gerada e armazenada no cofre da equipe.
  O script falha propositalmente se o placeholder nao for substituido.
  ==============================================================================*/

SET NOCOUNT ON;

DECLARE @Senha NVARCHAR(128) = N'__SET_PASSWORD__';

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF @Senha = N'__SET_PASSWORD__'
        THROW 50001, 'Senha nao definida: substitua __SET_PASSWORD__ antes de executar.', 1;

    IF LEN(@Senha) < 16
        THROW 50002, 'Senha fraca: use ao menos 16 caracteres.', 1;

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================

    -- 2.1 Login a nivel de servidor (idempotente)
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_relatorio_web')
    BEGIN
        DECLARE @sqlLogin NVARCHAR(MAX) =
            N'CREATE LOGIN [usr_relatorio_web] WITH PASSWORD = ' + QUOTENAME(@Senha, '''') +
            N', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF, DEFAULT_DATABASE = [' + DB_NAME() + N']';
        EXEC sp_executesql @sqlLogin;
        PRINT 'Login usr_relatorio_web criado.';
    END
    ELSE
    BEGIN
        -- Login ja existe: atualiza a senha e garante habilitado
        DECLARE @sqlAlter NVARCHAR(MAX) =
            N'ALTER LOGIN [usr_relatorio_web] WITH PASSWORD = ' + QUOTENAME(@Senha, '''') + N';' +
            N' ALTER LOGIN [usr_relatorio_web] ENABLE;';
        EXEC sp_executesql @sqlAlter;
        PRINT 'Login usr_relatorio_web ja existia - senha atualizada e login habilitado.';
    END

    -- 2.2 Usuario no banco atual (idempotente)
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'usr_relatorio_web')
    BEGIN
        CREATE USER [usr_relatorio_web] FOR LOGIN [usr_relatorio_web];
        PRINT 'Usuario usr_relatorio_web criado no banco ' + DB_NAME() + '.';
    END
    ELSE
        PRINT 'Usuario usr_relatorio_web ja existia no banco ' + DB_NAME() + '.';

    -- 2.3 Apenas leitura: db_datareader
    IF NOT EXISTS (
        SELECT 1
        FROM sys.database_role_members rm
        INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
        INNER JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
        WHERE r.name = N'db_datareader' AND u.name = N'usr_relatorio_web'
    )
    BEGIN
        ALTER ROLE [db_datareader] ADD MEMBER [usr_relatorio_web];
        PRINT 'Usuario adicionado a db_datareader.';
    END

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_relatorio_web')
        THROW 50003, 'Pos-check falhou: login usr_relatorio_web nao existe.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.database_role_members rm
        INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
        INNER JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
        WHERE r.name = N'db_datareader' AND u.name = N'usr_relatorio_web'
    )
        THROW 50004, 'Pos-check falhou: usuario sem db_datareader.', 1;

    -- Garante que nao ha role de escrita associada
    IF EXISTS (
        SELECT 1
        FROM sys.database_role_members rm
        INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
        INNER JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
        WHERE u.name = N'usr_relatorio_web'
          AND r.name IN (N'db_datawriter', N'db_ddladmin', N'db_owner', N'db_securityadmin', N'db_accessadmin')
    )
        THROW 50005, 'Pos-check falhou: usuario possui role de escrita/administracao.', 1;

    PRINT 'SUCESSO: usr_relatorio_web criado com acesso somente leitura em ' + DB_NAME() + '.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
