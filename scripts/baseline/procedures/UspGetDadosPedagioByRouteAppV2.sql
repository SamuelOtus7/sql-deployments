-- ============================================================
-- BASELINE: dbo.UspGetDadosPedagioByRouteAppV2
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDadosPedagioByRouteAppV2]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    UspGetDadosPedagioByRouteAppV2
    - Busca rota para pedágio no app (ML -> SPE -> fallback motorista).
    - Filtro por data: DataReferencia = @DataRota OU CAST(DataHoraSaidaEstacao AS DATE) = @DataRota.
    - @IdRota: API envia NULL quando vazio; normalizado para NULL no início da procedure.
    Exemplo (SSMS):
    EXEC dbo.UspGetDadosPedagioByRouteAppV2 7692164, 69, 1, NULL, '2026-05-27';
*/
CREATE   PROCEDURE [dbo].[UspGetDadosPedagioByRouteAppV2]
(
    @CodMotorista INT,
    @CodCliente INT,
    @Tipo TINYINT,
    @IdRota VARCHAR(50) = NULL,
    @DataRota DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CodUsuario INT;
    DECLARE @Matricula VARCHAR(10);
    DECLARE @NomeUsuario VARCHAR(150);
    SET @IdRota = NULLIF(LTRIM(RTRIM(ISNULL(@IdRota, ''))), '');
    SELECT
        @CodUsuario = mot.mot_cd_usuario,
        @Matricula = mot.mot_cd_matricula,
        @NomeUsuario = mot.mot_nm_motorista
    FROM dbo.tb_motorista AS mot
    WHERE mot.mot_cd_usuario = @CodMotorista
      AND mot.mot_cd_status = 1
      AND mot.mot_cd_cliente = @CodCliente;
    IF @CodMotorista = 9525
        SET @CodMotorista = 6687;
    IF @Tipo = 1
        SET @Matricula = CAST(@CodUsuario AS VARCHAR(10));
    CREATE TABLE #return
    (
        Rota VARCHAR(50),
        Base VARCHAR(30),
        CodUsuario INT,
        Matricula VARCHAR(10),
        Nome VARCHAR(150),
        Placa VARCHAR(10),
        Dispacher VARCHAR(150),
        Data DATE
    );
    -- BLOCO 1: tb_ml_rotas
    INSERT INTO #return
    SELECT TOP 1
        CAST(rotas.IdRota AS VARCHAR(50)) AS Rota,
        rotas.ServiceCenter AS Base,
        @CodUsuario AS CodUsuario,
        @Matricula AS Matricula,
        @NomeUsuario AS Nome,
        LEFT(REPLACE(UPPER(LTRIM(RTRIM(rotas.Placa))), 'SDD-', ''), 10) AS Placa,
        '' AS Dispacher,
        CASE
            WHEN rotas.DataReferencia = @DataRota THEN CAST(rotas.DataReferencia AS DATE)
            WHEN @DataRota IS NOT NULL THEN @DataRota
            ELSE CAST(rotas.DataReferencia AS DATE)
        END AS Data
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
            (
                @DataRota IS NOT NULL
                AND (
                    rotas.DataReferencia = @DataRota
                    OR (
                        rotas.DataHoraSaidaEstacao IS NOT NULL
                        AND CAST(rotas.DataHoraSaidaEstacao AS DATE) = @DataRota
                    )
                )
            )
            OR (
                @IdRota IS NOT NULL
                AND CAST(rotas.IdRota AS VARCHAR(50)) = @IdRota
            )
        )
    ORDER BY
        CASE WHEN rotas.DataReferencia = @DataRota THEN 0 ELSE 1 END,
        rotas.DataHoraSaidaEstacao DESC;
    -- BLOCO 2: tb_spe_rotas_v5
    IF NOT EXISTS (SELECT 1 FROM #return)
    BEGIN
        INSERT INTO #return
        SELECT TOP 1
            rotas.CodigoRota AS Rota,
            stations.NomeStation AS Base,
            @CodUsuario AS CodUsuario,
            @Matricula AS Matricula,
            @NomeUsuario AS Nome,
            LEFT(REPLACE(UPPER(LTRIM(RTRIM(rotas.Placa))), 'SDD-', ''), 10) AS Placa,
            '' AS Dispacher,
            CASE
                WHEN rotas.DataReferencia = @DataRota THEN CAST(rotas.DataReferencia AS DATE)
                WHEN @DataRota IS NOT NULL THEN @DataRota
                ELSE CAST(rotas.DataReferencia AS DATE)
            END AS Data
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
                (
                    @DataRota IS NOT NULL
                    AND (
                        rotas.DataReferencia = @DataRota
                        OR (
                            rotas.DataHoraInicio IS NOT NULL
                            AND CAST(rotas.DataHoraInicio AS DATE) = @DataRota
                        )
                    )
                )
                OR (
                    @IdRota IS NOT NULL
                    AND rotas.CodigoRota = @IdRota
                )
            )
        ORDER BY
            CASE WHEN rotas.DataReferencia = @DataRota THEN 0 ELSE 1 END,
            rotas.DataHoraInicio DESC;
    END;
    -- BLOCO 3: fallback motorista
    IF NOT EXISTS (SELECT 1 FROM #return)
    BEGIN
        INSERT INTO #return
        SELECT
            NULL AS Rota,
            NULL AS Base,
            @CodUsuario AS CodUsuario,
            @Matricula AS Matricula,
            @NomeUsuario AS Nome,
            '' AS Placa,
            '' AS Dispacher,
            @DataRota AS Data;
    END;
    IF @Tipo = 2
    BEGIN
        SELECT Rota, Base, NULL AS CodUsuario, Matricula, Nome, Placa, Dispacher, Data
        FROM #return;
    END
    ELSE
    BEGIN
        SELECT Rota, Base, CodUsuario, Matricula, Nome, Placa, Dispacher, Data
        FROM #return;
    END;
    DROP TABLE #return;
    SET NOCOUNT OFF;
END;





-- blk 17-08-2026
--CREATE   PROCEDURE [dbo].[UspGetDadosPedagioByRouteAppV2]
--
--(
--
--    @CodMotorista INT,
--
--    @CodCliente INT,
--
--    @Tipo TINYINT,
--
--    @IdRota VARCHAR(50) = NULL,
--
--    @DataRota DATE = NULL
--
--)
--
--AS
--
--BEGIN
--
--    SET NOCOUNT ON;
--
--
--
--    DECLARE @CodUsuario INT;
--
--    DECLARE @Matricula VARCHAR(10);
--
--    DECLARE @NomeUsuario VARCHAR(150);
--
--
--
--    SET @IdRota = NULLIF(LTRIM(RTRIM(ISNULL(@IdRota, ''))), '');
--
--
--
--    SELECT
--
--        @CodUsuario = mot.mot_cd_usuario,
--
--        @Matricula = mot.mot_cd_matricula,
--
--        @NomeUsuario = mot.mot_nm_motorista
--
--    FROM dbo.tb_motorista AS mot
--
--    WHERE mot.mot_cd_usuario = @CodMotorista
--
--      AND mot.mot_cd_status = 1
--
--      AND mot.mot_cd_cliente = @CodCliente;
--
--
--
--    IF @CodMotorista = 9525
--
--        SET @CodMotorista = 6687;
--
--
--
--    IF @Tipo = 1
--
--        SET @Matricula = CAST(@CodUsuario AS VARCHAR(10));
--
--
--
--    CREATE TABLE #return
--
--    (
--
--        Rota VARCHAR(50),
--
--        Base VARCHAR(30),
--
--        CodUsuario INT,
--
--        Matricula VARCHAR(10),
--
--        Nome VARCHAR(150),
--
--        Placa VARCHAR(10),
--
--        Dispacher VARCHAR(150),
--
--        Data DATE
--
--    );
--
--
--
--    -- BLOCO 1: tb_ml_rotas
--
--    INSERT INTO #return
--
--    SELECT TOP 1
--
--        CAST(rotas.IdRota AS VARCHAR(50)) AS Rota,
--
--        rotas.ServiceCenter AS Base,
--
--        @CodUsuario AS CodUsuario,
--
--        @Matricula AS Matricula,
--
--        @NomeUsuario AS Nome,
--
--        LEFT(REPLACE(UPPER(LTRIM(RTRIM(rotas.Placa))), '-', ''), 10) AS Placa,
--
--        '' AS Dispacher,
--
--        CASE
--
--            WHEN rotas.DataReferencia = @DataRota THEN CAST(rotas.DataReferencia AS DATE)
--
--            WHEN @DataRota IS NOT NULL THEN @DataRota
--
--            ELSE CAST(rotas.DataReferencia AS DATE)
--
--        END AS Data
--
--    FROM dbo.tb_ml_rotas AS rotas
--
--    INNER JOIN dbo.tb_clientes AS clientes
--
--        ON rotas.IdTransportadora = clientes.cli_id_logistics
--
--    WHERE
--
--        rotas.Excluido = 0
--
--        AND rotas.NomeMotorista = @NomeUsuario
--
--        AND (
--
--            (@Tipo = 1 AND rotas.UsuarioDA = @CodUsuario)
--
--            OR (@Tipo = 2 AND rotas.UsuarioDA = @Matricula)
--
--        )
--
--        AND (
--
--            (
--
--                @DataRota IS NOT NULL
--
--                AND (
--
--                    rotas.DataReferencia = @DataRota
--
--                    OR (
--
--                        rotas.DataHoraSaidaEstacao IS NOT NULL
--
--                        AND CAST(rotas.DataHoraSaidaEstacao AS DATE) = @DataRota
--
--                    )
--
--                )
--
--            )
--
--            OR (
--
--                @IdRota IS NOT NULL
--
--                AND CAST(rotas.IdRota AS VARCHAR(50)) = @IdRota
--
--            )
--
--        )
--
--    ORDER BY
--
--        CASE WHEN rotas.DataReferencia = @DataRota THEN 0 ELSE 1 END,
--
--        rotas.DataHoraSaidaEstacao DESC;
--
--
--
--    -- BLOCO 2: tb_spe_rotas_v5
--
--    IF NOT EXISTS (SELECT 1 FROM #return)
--
--    BEGIN
--
--        INSERT INTO #return
--
--        SELECT TOP 1
--
--            rotas.CodigoRota AS Rota,
--
--            stations.NomeStation AS Base,
--
--            @CodUsuario AS CodUsuario,
--
--            @Matricula AS Matricula,
--
--            @NomeUsuario AS Nome,
--
--            LEFT(REPLACE(UPPER(LTRIM(RTRIM(rotas.Placa))), '-', ''), 10) AS Placa,
--
--            '' AS Dispacher,
--
--            CASE
--
--                WHEN rotas.DataReferencia = @DataRota THEN CAST(rotas.DataReferencia AS DATE)
--
--                WHEN @DataRota IS NOT NULL THEN @DataRota
--
--                ELSE CAST(rotas.DataReferencia AS DATE)
--
--            END AS Data
--
--        FROM dbo.tb_spe_rotas_v5 AS rotas
--
--        INNER JOIN dbo.tb_spe_motoristas AS drivers
--
--            ON rotas.IdMotorista = drivers.IdMotorista
--
--        INNER JOIN dbo.tb_spe_station AS stations
--
--            ON rotas.IdStation = stations.IdStation
--
--        INNER JOIN dbo.tb_clientes AS clientes
--
--            ON rotas.IdTransportadora = clientes.cli_id_logistics
--
--        WHERE
--
--            rotas.Excluido = 0
--
--            AND ISNULL(drivers.NomeMotorista, '') = ISNULL(@NomeUsuario, '')
--
--            AND (
--
--                (@Tipo = 1 AND rotas.UsuarioIrisys = @CodUsuario)
--
--                OR (@Tipo = 2 AND rotas.UsuarioIrisys = @Matricula)
--
--            )
--
--            AND (
--
--                (
--
--                    @DataRota IS NOT NULL
--
--                    AND (
--
--                        rotas.DataReferencia = @DataRota
--
--                        OR (
--
--                            rotas.DataHoraInicio IS NOT NULL
--
--                            AND CAST(rotas.DataHoraInicio AS DATE) = @DataRota
--
--                        )
--
--                    )
--
--                )
--
--                OR (
--
--                    @IdRota IS NOT NULL
--
--                    AND rotas.CodigoRota = @IdRota
--
--                )
--
--            )
--
--        ORDER BY
--
--            CASE WHEN rotas.DataReferencia = @DataRota THEN 0 ELSE 1 END,
--
--            rotas.DataHoraInicio DESC;
--
--    END;
--
--
--
--    -- BLOCO 3: fallback motorista
--
--    IF NOT EXISTS (SELECT 1 FROM #return)
--
--    BEGIN
--
--        INSERT INTO #return
--
--        SELECT
--
--            NULL AS Rota,
--
--            NULL AS Base,
--
--            @CodUsuario AS CodUsuario,
--
--            @Matricula AS Matricula,
--
--            @NomeUsuario AS Nome,
--
--            '' AS Placa,
--
--            '' AS Dispacher,
--
--            @DataRota AS Data;
--
--    END;
--
--
--
--    IF @Tipo = 2
--
--    BEGIN
--
--        SELECT Rota, Base, NULL AS CodUsuario, Matricula, Nome, Placa, Dispacher, Data
--
--        FROM #return;
--
--    END
--
--    ELSE
--
--    BEGIN
--
--        SELECT Rota, Base, CodUsuario, Matricula, Nome, Placa, Dispacher, Data
--
--        FROM #return;
--
--    END;
--
--
--
--    DROP TABLE #return;
--
--
--
--    SET NOCOUNT OFF;
--
--END;


--CREATE PROCEDURE [dbo].[UspGetDadosPedagioByRouteAppV2]
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
--    SELECT TOP 1
--        CAST(rotas.IdRota AS VARCHAR(50)) AS Rota,
--        rotas.ServiceCenter AS Base,
--        @CodUsuario AS CodUsuario,
--        @Matricula AS Matricula,
--        @NomeUsuario AS Nome,
--        LEFT(REPLACE(UPPER(LTRIM(RTRIM(rotas.Placa))), '-', ''), 10) AS Placa,
--        '' AS Dispacher,
--        rotas.DataReferencia AS Data
--    FROM dbo.tb_ml_rotas AS rotas
--    INNER JOIN dbo.tb_clientes AS clientes 
--        ON rotas.IdTransportadora = clientes.cli_id_logistics
--    WHERE 
--        (
--            (rotas.DataReferencia = @DataRota)
--            OR             
--            (rotas.IdRota = @IdRota AND @IdRota <> '')
--        )
--        AND rotas.Excluido = 0
--        AND rotas.NomeMotorista = @NomeUsuario
--        AND (
--           (@Tipo = 1 AND rotas.UsuarioDA = @CodUsuario)
--        OR (@Tipo = 2 AND rotas.UsuarioDA = @Matricula)
--    );
--
--    -- BLOCO 2: SE NÃO ENCONTROU NA PRIMEIRA, BUSCA NA TABELA tb_spe_rotas_v5
--    IF NOT EXISTS (SELECT 1 FROM #return)
--    BEGIN
--        INSERT INTO #return
--        SELECT TOP 1
--            rotas.CodigoRota AS Rota,
--            stations.NomeStation AS Base,
--            @CodUsuario AS CodUsuario,
--            @Matricula AS Matricula,
--            @NomeUsuario AS Nome,
--            LEFT(REPLACE(UPPER(LTRIM(RTRIM(rotas.Placa))), '-', ''), 10) AS Placa,
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
--            (
--                (rotas.DataReferencia = @DataRota)
--                OR                 
--                (rotas.CodigoRota = @IdRota AND @IdRota <> '')
--            )
--            AND rotas.Excluido = 0
--            AND ISNULL(drivers.NomeMotorista, '') = ISNULL(@NomeUsuario, '')            
--		    AND (
--		           (@Tipo = 1 AND rotas.UsuarioIrisys = @CodUsuario)
--		        OR (@Tipo = 2 AND rotas.UsuarioIrisys = @Matricula)
--		    );
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
