-- ============================================================
-- BASELINE: dbo.UspGetDadosPedagioByRouteAppV3Multiple-blk-29052026
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDadosPedagioByRouteAppV3Multiple-blk-29052026]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGetDadosPedagioByRouteAppV3Multiple-blk-29052026]
--CREATE   PROCEDURE [dbo].[UspGetDadosPedagioByRouteAppV3Multiple]
(
    @CodMotorista INT,         -- Código do motorista
    @CodCliente INT,           -- Código do cliente
    @Tipo TINYINT,             -- 1 para Código do Usuário, 2 para Matrícula
    @IdRota VARCHAR(50) = '',  -- Código da Rota (opcional)
    @DataRota DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CodUsuario INT;
    DECLARE @Matricula VARCHAR(10);    
    DECLARE @NomeUsuario VARCHAR(150);

    -- PRÉ-CONSULTA PARA OBTER OS DADOS DO MOTORISTA
    SELECT 
	    @CodUsuario = mot.mot_cd_usuario,
	    @Matricula = mot.mot_cd_matricula,
	    @NomeUsuario = mot.mot_nm_motorista
	FROM dbo.tb_motorista AS mot         
	WHERE 
	    mot.mot_cd_usuario = @CodMotorista
	    AND mot.mot_cd_status = 1
	    AND mot.mot_cd_cliente = @CodCliente;

    -- Verificação especial para código de motorista 9525
    IF @CodMotorista = 9525
        SET @CodMotorista = 6687;

    -- Ajustar Matricula se Tipo = 1
    IF @Tipo = 1
        SET @Matricula = CAST(@CodUsuario AS VARCHAR(10));

    -- Tabela temporária para armazenar os resultados
    CREATE TABLE #return
    (
        Rota VARCHAR(50),
        Base VARCHAR(30),
        CodUsuario INT,
        Matricula VARCHAR(10),
        Nome VARCHAR(150),
        Placa VARCHAR(15),
        Dispacher VARCHAR(150),
        Data DATE
    );

    -- BLOCO 1: BUSCA NA TABELA tb_ml_rotas
    INSERT INTO #return (Rota, Base, CodUsuario, Matricula, Nome, Placa, Dispacher, Data)
    SELECT
        CAST(rotas.IdRota AS VARCHAR(50)) AS Rota,
        CAST(rotas.ServiceCenter AS VARCHAR(30)) AS Base,
        @CodUsuario AS CodUsuario,
        @Matricula AS Matricula,
        @NomeUsuario AS Nome,
        CONVERT(VARCHAR(15), CASE 
            WHEN LEN(LTRIM(RTRIM(ISNULL(rotas.Placa, '')))) > 15 
            THEN SUBSTRING(LTRIM(RTRIM(ISNULL(rotas.Placa, ''))), 1, 15)
            ELSE LTRIM(RTRIM(ISNULL(rotas.Placa, '')))
        END) AS Placa,
        CAST('' AS VARCHAR(150)) AS Dispacher,
        rotas.DataReferencia AS Data
    FROM dbo.tb_ml_rotas AS rotas
    INNER JOIN dbo.tb_clientes AS clientes 
        ON rotas.IdTransportadora = clientes.cli_id_logistics
    WHERE 
        rotas.Excluido = 0
        AND rotas.NomeMotorista = @NomeUsuario
        AND (
           (@Tipo = 1 AND rotas.UsuarioDA = @CodUsuario)
        OR (@Tipo = 2 AND rotas.UsuarioDA = @Matricula)
        )
        AND (
            -- Se @IdRota foi informado, busca por rota
            (@IdRota <> '' AND rotas.IdRota = @IdRota)
            OR
            -- Se @DataRota foi informado, busca por data
            (@DataRota IS NOT NULL AND rotas.DataReferencia = @DataRota)
            OR
            -- Se ambos foram informados, busca por ambos
            (@IdRota <> '' AND @DataRota IS NOT NULL AND rotas.IdRota = @IdRota AND rotas.DataReferencia = @DataRota)
        );

    -- BLOCO 2: SE NÃO ENCONTROU NA PRIMEIRA, BUSCA NA TABELA tb_spe_rotas_v5
    IF NOT EXISTS (SELECT 1 FROM #return)
    BEGIN
        INSERT INTO #return (Rota, Base, CodUsuario, Matricula, Nome, Placa, Dispacher, Data)
        SELECT
            CAST(rotas.CodigoRota AS VARCHAR(50)) AS Rota,
            CAST(stations.NomeStation AS VARCHAR(30)) AS Base,
            @CodUsuario AS CodUsuario,
            @Matricula AS Matricula,
            @NomeUsuario AS Nome,
            CONVERT(VARCHAR(15), CASE 
                WHEN LEN(LTRIM(RTRIM(ISNULL(rotas.placa, '')))) > 15 
                THEN SUBSTRING(LTRIM(RTRIM(ISNULL(rotas.placa, ''))), 1, 15)
                ELSE LTRIM(RTRIM(ISNULL(rotas.placa, '')))
            END) AS Placa,
            CAST('' AS VARCHAR(150)) AS Dispacher,
            rotas.DataReferencia AS Data
        FROM dbo.tb_spe_rotas_v5 AS rotas
        INNER JOIN dbo.tb_spe_motoristas AS drivers 
            ON rotas.IdMotorista = drivers.IdMotorista
        INNER JOIN dbo.tb_spe_station AS stations 
            ON rotas.IdStation = stations.IdStation
        INNER JOIN dbo.tb_clientes AS clientes 
            ON rotas.IdTransportadora = clientes.cli_id_logistics
        WHERE 
            rotas.Excluido = 0
            AND ISNULL(drivers.NomeMotorista, '') = ISNULL(@NomeUsuario, '')            
		    AND (
		           (@Tipo = 1 AND rotas.UsuarioIrisys = @CodUsuario)
		        OR (@Tipo = 2 AND rotas.UsuarioIrisys = @Matricula)
		    )
            AND (
                -- Se @IdRota foi informado, busca por rota
                (@IdRota <> '' AND rotas.CodigoRota = @IdRota)
                OR
                -- Se @DataRota foi informado, busca por data
             (@DataRota IS NOT NULL AND rotas.DataReferencia = @DataRota)
                OR
                -- Se ambos foram informados, busca por ambos
                (@IdRota <> '' AND @DataRota IS NOT NULL AND rotas.CodigoRota = @IdRota AND rotas.DataReferencia = @DataRota)
            );
    END

    -- BLOCO 3: SE AINDA NÃO ENCONTROU, RETORNA DADOS BÁSICOS
    IF NOT EXISTS (SELECT 1 FROM #return)
    BEGIN
        INSERT INTO #return (Rota, Base, CodUsuario, Matricula, Nome, Placa, Dispacher, Data)
        SELECT 
            NULL AS Rota,
            NULL AS Base,
            @CodUsuario AS CodUsuario,
            @Matricula AS Matricula,
            @NomeUsuario AS Nome,
            CAST('' AS VARCHAR(15)) AS Placa,
            CAST('' AS VARCHAR(150)) AS Dispacher,
            @DataRota AS Data;
    END

    -- RETORNO CONDICIONAL BASEADO NO @Tipo
    IF @Tipo = 2
    BEGIN
        SELECT Rota, Base, NULL AS CodUsuario, Matricula, Nome, Placa, Dispacher, Data FROM #return;
    END
    ELSE
    BEGIN
        SELECT Rota, Base, CodUsuario, Matricula, Nome, Placa, Dispacher, Data FROM #return;
    END

    -- Limpando tabela temporária
    DROP TABLE #return;

    SET NOCOUNT OFF;
END










--Old-12-12-2025
--CREATE   PROCEDURE [dbo].[UspGetDadosPedagioByRouteAppV3]
--(
--    @CodMotorista INT,         -- Código do motorista
--    @CodCliente INT,           -- Código do cliente
--    @Tipo TINYINT,             -- 1 para Código do Usuário, 2 para Matrícula
--    @IdRota VARCHAR(50) = '',  -- Código da Rota (opcional)
--    @DataRota DATE = NULL
--)
--AS
--BEGIN
--    SET NOCOUNT ON;
--
--    DECLARE @CodUsuario INT;
--    DECLARE @Matricula VARCHAR(10);    
--    DECLARE @NomeUsuario VARCHAR(150);
--
--    -- PRÉ-CONSULTA PARA OBTER OS DADOS DO MOTORISTA
--    SELECT 
--	    @CodUsuario = mot.mot_cd_usuario,
--	    @Matricula = mot.mot_cd_matricula,
--	    @NomeUsuario = mot.mot_nm_motorista
--	FROM dbo.tb_motorista AS mot         
--	WHERE 
--	    mot.mot_cd_usuario = @CodMotorista
--	    AND mot.mot_cd_status = 1
--	    AND mot.mot_cd_cliente = @CodCliente;
--
--    -- Verificação especial para código de motorista 9525
--    IF @CodMotorista = 9525
--        SET @CodMotorista = 6687;
--
--    -- Ajustar Matricula se Tipo = 1
--    IF @Tipo = 1
--        SET @Matricula = CAST(@CodUsuario AS VARCHAR(10));
--
--    -- Tabela temporária para armazenar os resultados
--    CREATE TABLE #return
--    (
--        Rota VARCHAR(50),
--        Base VARCHAR(30),
--        CodUsuario INT,
--        Matricula VARCHAR(10),
--        Nome VARCHAR(150),
--        Placa VARCHAR(10),
--        Dispacher VARCHAR(150),
--        Data DATE
--    );
--
--    -- BLOCO 1: BUSCA NA TABELA tb_ml_rotas
--    INSERT INTO #return
--    SELECT
--        CAST(rotas.IdRota AS VARCHAR(50)) AS Rota,
--        rotas.ServiceCenter AS Base,
--        @CodUsuario AS CodUsuario,
--        @Matricula AS Matricula,
--        @NomeUsuario AS Nome,
--        rotas.Placa AS Placa,
--        '' AS Dispacher,
--        rotas.DataReferencia AS Data
--    FROM dbo.tb_ml_rotas AS rotas
--    INNER JOIN dbo.tb_clientes AS clientes 
--        ON rotas.IdTransportadora = clientes.cli_id_logistics
--    WHERE 
--        rotas.Excluido = 0
--        AND rotas.NomeMotorista = @NomeUsuario
--        AND (
--           (@Tipo = 1 AND rotas.UsuarioDA = @CodUsuario)
--        OR (@Tipo = 2 AND rotas.UsuarioDA = @Matricula)
--        )
--        AND (
--            -- Se @IdRota foi informado, busca por rota
--            (@IdRota <> '' AND rotas.IdRota = @IdRota)
--            OR
--            -- Se @DataRota foi informado, busca por data
--            (@DataRota IS NOT NULL AND rotas.DataReferencia = @DataRota)
--            OR
--            -- Se ambos foram informados, busca por ambos
--            (@IdRota <> '' AND @DataRota IS NOT NULL AND rotas.IdRota = @IdRota AND rotas.DataReferencia = @DataRota)
--        );
--
--    -- BLOCO 2: SE NÃO ENCONTROU NA PRIMEIRA, BUSCA NA TABELA tb_spe_rotas_v5
--    IF NOT EXISTS (SELECT 1 FROM #return)
--    BEGIN
--        INSERT INTO #return
--        SELECT
--            rotas.CodigoRota AS Rota,
--            stations.NomeStation AS Base,
--            @CodUsuario AS CodUsuario,
--            @Matricula AS Matricula,
--            @NomeUsuario AS Nome,
--            rotas.placa AS Placa,
--            '' AS Dispacher,
--            rotas.DataReferencia AS Data
--        FROM dbo.tb_spe_rotas_v5 AS rotas
--        INNER JOIN dbo.tb_spe_motoristas AS drivers 
--            ON rotas.IdMotorista = drivers.IdMotorista
--        INNER JOIN dbo.tb_spe_station AS stations 
--            ON rotas.IdStation = stations.IdStation
--        INNER JOIN dbo.tb_clientes AS clientes 
--            ON rotas.IdTransportadora = clientes.cli_id_logistics
--        WHERE 
--            rotas.Excluido = 0
--            AND ISNULL(drivers.NomeMotorista, '') = ISNULL(@NomeUsuario, '')            
--		    AND (
--		           (@Tipo = 1 AND rotas.UsuarioIrisys = @CodUsuario)
--		        OR (@Tipo = 2 AND rotas.UsuarioIrisys = @Matricula)
--		    )
--            AND (
--                -- Se @IdRota foi informado, busca por rota
--                (@IdRota <> '' AND rotas.CodigoRota = @IdRota)
--                OR
--                -- Se @DataRota foi informado, busca por data
--             (@DataRota IS NOT NULL AND rotas.DataReferencia = @DataRota)
--                OR
--                -- Se ambos foram informados, busca por ambos
--                (@IdRota <> '' AND @DataRota IS NOT NULL AND rotas.CodigoRota = @IdRota AND rotas.DataReferencia = @DataRota)
--            );
--    END
--
--    -- BLOCO 3: SE AINDA NÃO ENCONTROU, RETORNA DADOS BÁSICOS
--    IF NOT EXISTS (SELECT 1 FROM #return)
--    BEGIN
--        INSERT INTO #return
--        SELECT 
--            NULL AS Rota,
--            NULL AS Base,
--            @CodUsuario AS CodUsuario,
--            @Matricula AS Matricula,
--            @NomeUsuario AS Nome,
--            '' AS Placa,
--            '' AS Dispacher,
--            @DataRota AS Data;
--    END
--
--    -- RETORNO CONDICIONAL BASEADO NO @Tipo
--    IF @Tipo = 2
--    BEGIN
--        SELECT Rota, Base, NULL AS CodUsuario, Matricula, Nome, Placa, Dispacher, Data FROM #return;
--    END
--    ELSE
--    BEGIN
--        SELECT Rota, Base, CodUsuario, Matricula, Nome, Placa, Dispacher, Data FROM #return;
--    END
--
--    -- Limpando tabela temporária
--    DROP TABLE #return;
--
--    SET NOCOUNT OFF;
--END
GO
