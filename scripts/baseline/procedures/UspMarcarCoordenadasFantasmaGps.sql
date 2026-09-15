-- ============================================================
-- BASELINE: dbo.UspMarcarCoordenadasFantasmaGps
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMarcarCoordenadasFantasmaGps]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspMarcarCoordenadasFantasmaGps]
    @DataInicio DATE,
    @DataFim DATE,
    @CdUsuario INT = NULL,
    @ResetarLote BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MinRepeticoes INT = 50;

    IF @DataInicio IS NULL OR @DataFim IS NULL
    BEGIN
        RAISERROR(N'@DataInicio e @DataFim são obrigatórios.', 16, 1);
        RETURN;
    END;

    IF @DataFim < @DataInicio
    BEGIN
        RAISERROR(N'@DataFim deve ser >= @DataInicio.', 16, 1);
        RETURN;
    END;

    IF COL_LENGTH(N'dbo.tb_registro_gps', N'rgp_in_coordenada_fantasma') IS NULL
    BEGIN
        RAISERROR(N'Coluna dbo.tb_registro_gps.rgp_in_coordenada_fantasma não existe. Execute 03_alter primeiro.', 16, 1);
        RETURN;
    END;

    DECLARE @DhIniArmazenamento DATETIME = DATEADD(hour, 3, CAST(@DataInicio AS datetime));
    DECLARE @DhFimArmazenamento DATETIME = DATEADD(hour, 3, DATEADD(day, 1, CAST(@DataFim AS datetime)));
    DECLARE @LinhasReset INT = 0;
    DECLARE @LinhasMarcadas INT = 0;

    IF @ResetarLote = 1
    BEGIN
        UPDATE g
        SET g.rgp_in_coordenada_fantasma = 0
        FROM dbo.tb_registro_gps AS g
        WHERE g.rgp_dh_data_hora >= @DhIniArmazenamento
          AND g.rgp_dh_data_hora < @DhFimArmazenamento
          AND (@CdUsuario IS NULL OR g.rgp_cd_usuario = @CdUsuario);

        SET @LinhasReset = @@ROWCOUNT;
    END;

    ;WITH base AS (
        SELECT
            g.rgp_cd_registro_gps,
            g.rgp_cd_usuario,
            CAST(DATEADD(hour, -3, g.rgp_dh_data_hora) AS date) AS DataRefOperacional,
            TRY_CAST(g.rgp_dc_latitude AS decimal(9, 6)) AS LatNorm,
            TRY_CAST(g.rgp_dc_longitude AS decimal(9, 6)) AS LonNorm
        FROM dbo.tb_registro_gps AS g
        WHERE g.rgp_dh_data_hora >= @DhIniArmazenamento
          AND g.rgp_dh_data_hora < @DhFimArmazenamento
          AND (@CdUsuario IS NULL OR g.rgp_cd_usuario = @CdUsuario)
          AND TRY_CAST(g.rgp_dc_latitude AS float) BETWEEN -90 AND 90
          AND TRY_CAST(g.rgp_dc_longitude AS float) BETWEEN -180 AND 180
    ),
    grupos_fantasma AS (
        SELECT
            b.rgp_cd_usuario,
            b.DataRefOperacional,
            b.LatNorm,
            b.LonNorm
        FROM base AS b
        WHERE b.LatNorm IS NOT NULL
          AND b.LonNorm IS NOT NULL
        GROUP BY
            b.rgp_cd_usuario,
            b.DataRefOperacional,
            b.LatNorm,
            b.LonNorm
        HAVING COUNT(*) >= @MinRepeticoes
    ),
    alvo AS (
        SELECT DISTINCT b.rgp_cd_registro_gps
        FROM base AS b
        INNER JOIN grupos_fantasma AS f
            ON f.rgp_cd_usuario = b.rgp_cd_usuario
           AND f.DataRefOperacional = b.DataRefOperacional
           AND f.LatNorm = b.LatNorm
           AND f.LonNorm = b.LonNorm
    )
    UPDATE g
    SET g.rgp_in_coordenada_fantasma = 1
    FROM dbo.tb_registro_gps AS g
    INNER JOIN alvo AS a
        ON a.rgp_cd_registro_gps = g.rgp_cd_registro_gps
    WHERE ISNULL(g.rgp_in_coordenada_fantasma, 0) = 0;

    SET @LinhasMarcadas = @@ROWCOUNT;

    SELECT
        @DataInicio AS DataInicioOperacional,
        @DataFim AS DataFimOperacional,
        @CdUsuario AS CdUsuario,
        @MinRepeticoes AS MinRepeticoes,
        @DhIniArmazenamento AS DhIniArmazenamento,
        @DhFimArmazenamento AS DhFimArmazenamento,
        @LinhasReset AS LinhasResetadas,
        @LinhasMarcadas AS LinhasMarcadasFantasma;
END;
GO
