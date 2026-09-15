-- ============================================================
-- BASELINE: dbo.UspGetDadosPedagioByRouteApp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDadosPedagioByRouteApp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGetDadosPedagioByRouteApp]
(
    @CodMotorista INT,         -- Código do motorista
    @CodCliente INT,           -- Código de cliente
    @Tipo TINYINT,             -- 1 para Código do Usuário, 2 para Matrícula
    @IdRota VARCHAR(50) = ''   -- Código da Rota (opcional)
)
AS
BEGIN
    DECLARE @CodUsuario INT
    DECLARE @Matricula VARCHAR(10)    
    DECLARE @NomeUsuario VARCHAR(150)

    -- PRÉ-CONSULTA PARA OBTER OS DADOS DO MOTORISTA
    SELECT 
        @CodUsuario = mot.mot_cd_usuario,
        @Matricula = mot.mot_cd_matricula,
        @NomeUsuario = mot.mot_nm_motorista
    FROM tb_motorista AS mot         
    WHERE 
        ((@Tipo = 1 AND mot.mot_cd_usuario = @CodMotorista) 
        OR 
        (@Tipo = 2 AND mot.mot_cd_matricula = @CodMotorista))        
        AND mot.mot_cd_status = 1
        AND mot.mot_cd_cliente = @CodCliente

    -- Verificação especial para código de motorista 9525
    IF @CodMotorista = 9525
        SET @CodMotorista = 6687

    -- Ajustar Matricula se Tipo = 1
    IF @Tipo = 1
        SET @Matricula = CAST(@CodUsuario AS VARCHAR(10))

    -- Tabela temporária para armazenar os resultados
    CREATE TABLE #return
    (
        Rota VARCHAR(30),
        Base VARCHAR(30),
        CodUsuario INT,
        Matricula VARCHAR(10),
        Nome VARCHAR(150),
        Placa VARCHAR(10),
        Dispacher VARCHAR(150),
        Data DATE
    )

    -- BLOCO 1: BUSCA NA TABELA tb_ml_rotas
    INSERT INTO #return
    SELECT TOP 1
        CAST(IdRota AS VARCHAR) AS Rota,
        ServiceCenter AS Base,
        @CodUsuario AS CodUsuario,
        @Matricula AS Matricula,
        @NomeUsuario AS Nome,
        rotas.Placa AS Placa,
        '' AS Dispacher,
        rotas.DataReferencia AS Data
    FROM tb_ml_rotas AS rotas
    INNER JOIN tb_clientes AS clientes 
        ON rotas.IdTransportadora = clientes.cli_id_logistics
    WHERE 
        (rotas.DataReferencia = CAST(GETDATE() AS DATE) OR 
        (rotas.IdRota = @IdRota AND @IdRota <> ''))
        AND rotas.Excluido = 0
        AND rotas.NomeMotorista = @NomeUsuario
        AND rotas.UsuarioDA = @CodUsuario

    -- BLOCO 2: SE NÃO ENCONTROU NA PRIMEIRA, BUSCA NA TABELA tb_spe_rotas_v5
    IF NOT EXISTS (SELECT Rota FROM #return)
    BEGIN
        INSERT INTO #return
        SELECT TOP 1
            CodigoRota AS Rota,
            stations.NomeStation AS Base,
            @CodUsuario AS CodUsuario,
            @Matricula AS Matricula,
            @NomeUsuario AS Nome,
            rotas.placa AS Placa,
            '' AS Dispacher,
            rotas.DataReferencia AS Data
        FROM tb_spe_rotas_v5 AS rotas
        INNER JOIN tb_spe_motoristas AS drivers 
            ON rotas.IdMotorista = drivers.IdMotorista
        INNER JOIN tb_spe_station AS stations 
            ON rotas.IdStation = stations.IdStation
        INNER JOIN tb_clientes AS clientes 
            ON rotas.IdTransportadora = clientes.cli_id_logistics
        WHERE 
            (rotas.DataReferencia = CAST(GETDATE() AS DATE) OR 
            (rotas.CodigoRota = @IdRota AND @IdRota <> ''))
            AND rotas.Excluido = 0
            AND ISNULL(drivers.NomeMotorista, '') = ISNULL(@NomeUsuario, '')
            AND rotas.UsuarioIrisys = @CodUsuario
    END

    -- BLOCO 3: SE AINDA NÃO ENCONTROU, RETORNA DADOS BÁSICOS
    IF NOT EXISTS (SELECT Rota FROM #return)
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
            CAST(GETDATE() AS DATE) AS Data
    END

    -- RETORNO CONDICIONAL BASEADO NO @Tipo
    IF @Tipo = 1
    BEGIN
        SELECT Rota, Base, NULL AS CodUsuario, Matricula, Nome, Placa, Dispacher, Data FROM #return
    END
    ELSE
    BEGIN
        SELECT Rota, Base, CodUsuario, Matricula, Nome, Placa, Dispacher, Data FROM #return
    END

    -- Limpando tabela temporária
    DROP TABLE #return
END
GO
