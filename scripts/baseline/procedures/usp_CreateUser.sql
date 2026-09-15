-- ============================================================
-- BASELINE: dbo.usp_CreateUser
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_CreateUser]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_CreateUser]
    @LoginName NVARCHAR(100),          -- Nome do login (ex: dominio\usuario ou usuarioSQL)
    @Password NVARCHAR(100) = NULL,    -- Senha (somente para SQL Authentication)
    @DefaultDB NVARCHAR(100) = 'master', -- Banco padrão do login
    @AuthType NVARCHAR(10) = 'SQL',       -- 'SQL' ou 'WINDOWS'
    @DatabaseName NVARCHAR(100) = NULL,   -- Banco onde o usuário será criado
    @Roles NVARCHAR(200) = 'db_datareader,db_datawriter', -- Pode ser múltiplos roles separados por vírgula
    @ForcePasswordChange BIT = 1          -- 1 = forçar alteração de senha no primeiro login
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    IF @DatabaseName IS NULL
        SET @DatabaseName = DB_NAME();  -- Banco atual por padrão

    PRINT '--- Criando login no servidor, se necessário ---';

    -- Cria login, se não existir
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName)
    BEGIN
        IF @AuthType = 'SQL'
        BEGIN
            IF @Password IS NULL
                THROW 50000, 'Senha obrigatória para login SQL.', 1;

            SET @SQL = 'CREATE LOGIN [' + @LoginName + '] WITH PASSWORD = N''' + @Password + '''';

            IF @ForcePasswordChange = 1
                SET @SQL += ' MUST_CHANGE';

            SET @SQL += ', CHECK_POLICY = ON, CHECK_EXPIRATION = ON, DEFAULT_DATABASE = [' + @DefaultDB + '];';
        END
        ELSE IF @AuthType = 'WINDOWS'
        BEGIN
            SET @SQL = 'CREATE LOGIN [' + @LoginName + '] FROM WINDOWS WITH DEFAULT_DATABASE=[' + @DefaultDB + '];';
        END

        EXEC(@SQL);
        PRINT 'Login criado com sucesso.';
    END
    ELSE
        PRINT 'Login já existe.';

    -- Se for sysadmin, adiciona direto ao server role
    IF CHARINDEX('sysadmin', @Roles) > 0
    BEGIN
        PRINT '--- Adicionando login ao role sysadmin ---';
        SET @SQL = 'ALTER SERVER ROLE sysadmin ADD MEMBER [' + @LoginName + '];';
        EXEC(@SQL);
        PRINT 'Login adicionado ao sysadmin com sucesso.';
    END

    -- Criar usuário no banco e adicionar roles
    PRINT '--- Criando usuário no banco, se necessário ---';
    SET @SQL = '
    USE [' + @DatabaseName + '];
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N''' + @LoginName + ''')
    BEGIN
        CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + '];
    END';

    EXEC(@SQL);

    -- Adicionar o usuário aos roles especificados
    DECLARE @Role NVARCHAR(50);
    DECLARE @RoleCursor CURSOR;
    SET @RoleCursor = CURSOR FOR
        SELECT value FROM STRING_SPLIT(@Roles, ',');
    OPEN @RoleCursor;
    FETCH NEXT FROM @RoleCursor INTO @Role;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = 'ALTER ROLE [' + @Role + '] ADD MEMBER [' + @LoginName + '];';
        BEGIN TRY
            EXEC(@SQL);
        END TRY
        BEGIN CATCH
            PRINT 'Falha ao adicionar ao role ' + @Role + ': ' + ERROR_MESSAGE();
        END CATCH
        FETCH NEXT FROM @RoleCursor INTO @Role;
    END
    CLOSE @RoleCursor;
    DEALLOCATE @RoleCursor;

    PRINT 'Usuário configurado com sucesso.';
END
GO
