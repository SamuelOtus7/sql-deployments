-- ============================================================
-- BASELINE: dbo.UspConfigureTemporalTable
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspConfigureTemporalTable]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   Procedure : dbo.UspConfigureTemporalTable
   Objetivo  : Tornar uma tabela existente SYSTEM_VERSIONED TEMPORAL criando/ajustando
               automaticamente a tabela de histórico (sem IDENTITY, colunas iguais,
               mesma nulabilidade, sem defaults/PK).

   Uso:
       EXEC dbo.UspConfigureTemporalTable 
            @schema = 'dbo',
            @table  = 'tb_motorista',
            @hist   = 'tb_motorista_hist',
            @usarHorarioLocal = 1;  -- 1 = GETDATE(); 0 = SYSUTCDATETIME()

   Observações:
   - Idempotente: pode rodar várias vezes.
   - SQL Server 2017+ (usa STRING_AGG apenas em pequenos pontos; o grosso é cursor para evitar erros de sintaxe).
   - Se a history tiver qualquer divergência (IDENTITY, colunas faltando/sobrando), ela é dropada e recriada.
   ============================================================ */
CREATE   PROCEDURE [dbo].[UspConfigureTemporalTable]
(
    @schema           SYSNAME = N'dbo',
    @table            SYSNAME,
    @hist             SYSNAME = NULL,   -- se NULL: <tabela>_hist
    @usarHorarioLocal BIT    = 0        -- 0 = SYSUTCDATETIME(); 1 = GETDATE()
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @hist IS NULL SET @hist = @table + N'_hist';

    DECLARE @tblFull  NVARCHAR(300) = N'[' + @schema + N'].[' + @table + N']';
    DECLARE @histFull NVARCHAR(300) = N'[' + @schema + N'].[' + @hist  + N']';

    DECLARE @baseId INT = OBJECT_ID(@schema + '.' + @table, 'U');
    IF @baseId IS NULL
    BEGIN
        RAISERROR('Tabela base %s.%s não existe.', 16, 1, @schema, @table);
        RETURN;
    END

    DECLARE @histId INT = OBJECT_ID(@schema + '.' + @hist, 'U');

    BEGIN TRY
        BEGIN TRAN;

        /* 0) Desligar versionamento se já estiver ligado */
        IF EXISTS (SELECT 1 FROM sys.tables WHERE object_id = @baseId AND temporal_type = 2)
        BEGIN
            EXEC(N'ALTER TABLE ' + @tblFull + N' SET (SYSTEM_VERSIONING = OFF);');
        END

        /* 1) Criar ValidFrom/ValidTo + PERIOD em um único ALTER quando ambos não existem */
        IF COL_LENGTH(@schema + '.' + @table, 'ValidFrom') IS NULL
           AND COL_LENGTH(@schema + '.' + @table, 'ValidTo')   IS NULL
        BEGIN
            DECLARE @defaultInicio NVARCHAR(40) = CASE WHEN @usarHorarioLocal = 1 THEN N'GETDATE()' ELSE N'SYSUTCDATETIME()' END;

            EXEC(N'ALTER TABLE ' + @tblFull + N'
                  ADD  ValidFrom datetime2(7) GENERATED ALWAYS AS ROW START NOT NULL DEFAULT ' + @defaultInicio + N',
                       ValidTo   datetime2(7) GENERATED ALWAYS AS ROW END   NOT NULL DEFAULT CONVERT(datetime2(7), ''9999-12-31 23:59:59.9999999''),
                       PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);');
        END
        ELSE
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM sys.periods p JOIN sys.tables t ON p.object_id = t.object_id
                WHERE t.object_id = @baseId
            )
            BEGIN
                EXEC(N'ALTER TABLE ' + @tblFull + N' ADD PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);');
            END
        END

        /* 2) Verificar se history existente é válida */
        SET @histId = OBJECT_ID(@schema + '.' + @hist, 'U');
        IF @histId IS NOT NULL
        BEGIN
            IF EXISTS (SELECT name FROM sys.columns WHERE object_id = @baseId
                       EXCEPT SELECT name FROM sys.columns WHERE object_id = @histId)
               OR EXISTS (SELECT name FROM sys.columns WHERE object_id = @histId
                          EXCEPT SELECT name FROM sys.columns WHERE object_id = @baseId)
               OR EXISTS (SELECT 1 FROM sys.columns WHERE object_id = @histId AND is_identity = 1)
            BEGIN
                EXEC(N'DROP TABLE ' + @histFull + N';');
                SET @histId = NULL;
            END
        END

        /* 3) Criar history se necessária (sem IDENTITY) */
        IF @histId IS NULL
        BEGIN
            DECLARE @cols NVARCHAR(MAX) = N'';

            DECLARE @cName SYSNAME,
                    @tName SYSNAME,
                    @maxlen INT,
                    @prec   INT,
                    @scale  INT,
                    @isId   BIT,
                    @colId  INT;

            DECLARE cur_cols CURSOR FAST_FORWARD FOR
                SELECT  c.name, t.name, c.max_length, c.precision, c.scale, c.is_identity, c.column_id
                FROM sys.columns c
                JOIN sys.types t ON c.user_type_id = t.user_type_id
                WHERE c.object_id = @baseId
                ORDER BY c.column_id;

            OPEN cur_cols;
            FETCH NEXT FROM cur_cols INTO @cName, @tName, @maxlen, @prec, @scale, @isId, @colId;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @typeStr NVARCHAR(200);
                IF @tName IN ('char','varchar','binary','varbinary')
                    SET @typeStr = @tName + '(' + CASE WHEN @maxlen = -1 THEN 'MAX' ELSE CAST(@maxlen AS VARCHAR(10)) END + ')';
                ELSE IF @tName IN ('nchar','nvarchar')
                    SET @typeStr = @tName + '(' + CASE WHEN @maxlen = -1 THEN 'MAX' ELSE CAST(@maxlen/2 AS VARCHAR(10)) END + ')';
                ELSE IF @tName IN ('decimal','numeric')
                    SET @typeStr = @tName + '(' + CAST(@prec AS VARCHAR(10)) + ',' + CAST(@scale AS VARCHAR(10)) + ')';
                ELSE IF @tName IN ('datetime2','datetimeoffset','time')
                    SET @typeStr = @tName + '(' + CAST(@scale AS VARCHAR(10)) + ')';
                ELSE
                    SET @typeStr = @tName;

                IF @isId = 1
                    SET @cols += 'CAST([' + @cName + '] AS ' + @typeStr + ') AS [' + @cName + '],'+CHAR(10);
                ELSE
                    SET @cols += '[' + @cName + '],'+CHAR(10);

                FETCH NEXT FROM cur_cols INTO @cName, @tName, @maxlen, @prec, @scale, @isId, @colId;
            END

            CLOSE cur_cols;
            DEALLOCATE cur_cols;

            -- remove última vírgula
            IF RIGHT(@cols,2) = ','+CHAR(10) SET @cols = LEFT(@cols, LEN(@cols)-2);

            EXEC(N'SELECT TOP(0) ' + @cols + ' INTO ' + @histFull + ' FROM ' + @tblFull + ';');

            /* Remover DEFAULTs e PK herdados */
            DECLARE @dropDefaults NVARCHAR(MAX) = (
                SELECT STRING_AGG('ALTER TABLE ' + @histFull + ' DROP CONSTRAINT ['+dc.name+'];', CHAR(10))
                FROM sys.default_constraints dc
                WHERE dc.parent_object_id = OBJECT_ID(@schema + '.' + @hist)
            );
            IF @dropDefaults IS NOT NULL EXEC(@dropDefaults);

            DECLARE @pk SYSNAME = (
                SELECT kc.name FROM sys.key_constraints kc
                WHERE kc.parent_object_id = OBJECT_ID(@schema + '.' + @hist)
                  AND kc.type = 'PK'
            );
            IF @pk IS NOT NULL EXEC(N'ALTER TABLE ' + @histFull + ' DROP CONSTRAINT [' + @pk + N'];');

            SET @histId = OBJECT_ID(@schema + '.' + @hist, 'U');
        END

        /* 3.1) Ajustar NULL/NOT NULL */
        IF @histId IS NOT NULL
        BEGIN
            DECLARE @fixCmd NVARCHAR(MAX) = N'';

            DECLARE @bName SYSNAME,
                    @bNullable BIT,
                    @hNullable BIT,
                    @bTName SYSNAME,
                    @bMaxLen INT,
                    @bPrec INT,
                    @bScale INT,
                    @bColId INT;

            DECLARE cur_null CURSOR FAST_FORWARD FOR
                SELECT  b.name, b.is_nullable, h.is_nullable AS hnull,
                        b.TypeName, b.max_length, b.precision, b.scale, b.column_id
                FROM (
                    SELECT c.name, c.is_nullable, t.name AS TypeName, c.max_length, c.precision, c.scale, c.column_id
                    FROM sys.columns c
                    JOIN sys.types t ON c.user_type_id = t.user_type_id
                    WHERE c.object_id = @baseId
                ) AS b
                JOIN (
                    SELECT c.name, c.is_nullable
                    FROM sys.columns c
                    WHERE c.object_id = @histId
                ) AS h ON b.name = h.name
                WHERE b.is_nullable <> h.is_nullable
                ORDER BY b.column_id;

            OPEN cur_null;
            FETCH NEXT FROM cur_null INTO @bName, @bNullable, @hNullable, @bTName, @bMaxLen, @bPrec, @bScale, @bColId;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @typeStr2 NVARCHAR(200);
                IF @bTName IN ('char','varchar','binary','varbinary')
                    SET @typeStr2 = @bTName + '(' + CASE WHEN @bMaxLen = -1 THEN 'MAX' ELSE CAST(@bMaxLen AS VARCHAR(10)) END + ')';
                ELSE IF @bTName IN ('nchar','nvarchar')
                    SET @typeStr2 = @bTName + '(' + CASE WHEN @bMaxLen = -1 THEN 'MAX' ELSE CAST(@bMaxLen/2 AS VARCHAR(10)) END + ')';
                ELSE IF @bTName IN ('decimal','numeric')
                    SET @typeStr2 = @bTName + '(' + CAST(@bPrec AS VARCHAR(10)) + ',' + CAST(@bScale AS VARCHAR(10)) + ')';
                ELSE IF @bTName IN ('datetime2','datetimeoffset','time')
                    SET @typeStr2 = @bTName + '(' + CAST(@bScale AS VARCHAR(10)) + ')';
                ELSE
                    SET @typeStr2 = @bTName;

                SET @fixCmd += 'ALTER TABLE ' + @histFull + ' ALTER COLUMN [' + @bName + '] ' +
                               @typeStr2 + CASE WHEN @bNullable = 1 THEN ' NULL;' ELSE ' NOT NULL;' END + CHAR(10);

                FETCH NEXT FROM cur_null INTO @bName, @bNullable, @hNullable, @bTName, @bMaxLen, @bPrec, @bScale, @bColId;
            END

            CLOSE cur_null;
            DEALLOCATE cur_null;

            IF @fixCmd <> N'' EXEC(@fixCmd);
        END

        /* 4) Ligar versionamento */
        EXEC(N'ALTER TABLE ' + @tblFull + N' SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = ' + @histFull + N'));');

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
        RETURN;
    END CATCH
END
GO
