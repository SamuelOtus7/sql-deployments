-- ============================================================
-- BASELINE: dbo.usp_analise_rotas_km_baixo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_analise_rotas_km_baixo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[usp_analise_rotas_km_baixo]
    @DataInicio        date        = NULL,
    @DataFim           date        = NULL,
    @IdTransportadora  varchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpa os dados do intervalo/transportadora selecionados
    IF @DataInicio IS NULL AND @DataFim IS NULL AND @IdTransportadora IS NULL
    BEGIN
        TRUNCATE TABLE [dbo].[tb_analise_rotas_km_baixo];
    END;
    ELSE
    BEGIN
        DELETE FROM [dbo].[tb_analise_rotas_km_baixo]
        WHERE (@DataInicio IS NULL OR [Data] >= @DataInicio)
          AND (@DataFim    IS NULL OR [Data] <= @DataFim)
          AND (@IdTransportadora IS NULL OR [IdTransportadora] = @IdTransportadora);
    END;

    WITH rotas_dedup AS (
        SELECT
            r.IdTransportadora,
            r.Idrota,
            r.data                 AS Data,
            r.Base,
            r.Motorista,
            r.UsuarioDA,
            r.KmApp,
            r.pontosRotasPacotesKm,
            r.FaixaPrimeiroUltimoPacote,
            r.UsouApp,
            r.ColetouGps,
            ROW_NUMBER() OVER (
                PARTITION BY r.Idrota, r.Data
                ORDER BY (SELECT NULL)
            ) AS rn
        FROM dbo.vw_rotas_motoristas_aderencia AS r WITH (NOLOCK)
        WHERE (@DataInicio IS NULL OR r.data >= @DataInicio)
          AND (@DataFim    IS NULL OR r.data <= @DataFim)
          AND (@IdTransportadora IS NULL OR r.IdTransportadora = @IdTransportadora)
    ),
    rotas AS (
        SELECT
            r.IdTransportadora,
            r.Idrota,
            r.Data,
            r.Base,
            r.Motorista,
            r.UsuarioDA,
            r.KmApp,
            r.pontosRotasPacotesKm,
            r.FaixaPrimeiroUltimoPacote,
            r.UsouApp,
            r.ColetouGps
        FROM rotas_dedup AS r
        WHERE r.rn = 1
    ),
    gps AS (
        SELECT
            rgp_cd_usuario                                  AS Usuario,
            CAST(rgp_dh_data_hora AS date)                  AS Data,
            COUNT(*)                                        AS QuantidadeApontamento,
            MIN(DATEADD(HOUR, -3, rgp_dh_data_hora))        AS InicioApp,
            MAX(DATEADD(HOUR, -3, rgp_dh_data_hora))        AS FimApp
        FROM dbo.tb_registro_gps WITH (NOLOCK)
        WHERE rgp_dh_data_hora IS NOT NULL
          AND (@DataInicio IS NULL OR CAST(rgp_dh_data_hora AS date) >= @DataInicio)
          AND (@DataFim    IS NULL OR CAST(rgp_dh_data_hora AS date) <= @DataFim)
        GROUP BY
            rgp_cd_usuario,
            CAST(rgp_dh_data_hora AS date)
    ),
    entregas AS (
        SELECT
            p.IdRota,
            MIN(p.DataHoraEntrega)    AS PrimeiraEntrega,
            MAX(p.DataHoraEntrega)    AS UltimaEntrega,
            COUNT(*)                  AS QtdPacotes
        FROM dbo.tb_ml_pacotes AS p WITH (NOLOCK)
        WHERE p.Excluido = 0
          AND p.IdRota IN (SELECT DISTINCT TRY_CONVERT(INT, Idrota) FROM rotas)
        GROUP BY p.IdRota
    )
    INSERT INTO [dbo].[tb_analise_rotas_km_baixo] (
        [IdTransportadora],
        [Idrota],
        [Data],
        [Base],
        [Motorista],
        [UsuarioDA],
        [KmApp],
        [pontosRotasPacotesKm],
        [QuantidadeApontamento],
        [InicioApp],
        [FimApp],
        [PrimeiraEntrega],
        [UltimaEntrega],
        [QtdPacotes],
        [FaixaQtdApontamentos],
        [MinInicioApp_PrimeiraEntrega],
        [FaixaTempoInicioApp],
        [MinFimApp_UltimaEntrega],
        [FaixaTempoFimApp],
        [PercAtingimentoKmApp],
        [KmApp_Menor_90_Perc],
        [FaixaPrimeiroUltimoPacote],
        [UsouApp],
        [ColetouGps]
    )
    SELECT
        r.IdTransportadora,
        r.Idrota,
        r.Data,
        r.Base,
        r.Motorista,
        r.UsuarioDA,
        r.KmApp,
        r.pontosRotasPacotesKm,
        g.QuantidadeApontamento,
        g.InicioApp,
        g.FimApp,
        p.PrimeiraEntrega,
        p.UltimaEntrega,
        p.QtdPacotes,

        -- Faixa de quantidade de apontamentos
        CASE
            WHEN g.QuantidadeApontamento <= 10                      THEN 'Até 10'
            WHEN g.QuantidadeApontamento <= 50                      THEN '11 a 50'
            WHEN g.QuantidadeApontamento <= 100                     THEN '51 a 100'
            WHEN g.QuantidadeApontamento <= 150                     THEN '101 a 150'
            ELSE                                                         'Maior que 150'
        END AS FaixaQtdApontamentos,

        -- Tempo em que o primeiro apontamento GPS ocorreu em relacao a primeira entrega
        -- Positivo = GPS iniciou depois da primeira entrega
        -- Negativo = GPS iniciou antes da primeira entrega
        DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) AS MinInicioApp_PrimeiraEntrega,
        CASE
            WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) < 0   THEN 'Antes da primeira entrega'
            WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 10 THEN 'Até 10 min depois'
            WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 30 THEN '10 a 30 min depois'
            WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 60 THEN '30 a 60 min depois'
            WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 90 THEN '60 a 90 min depois'
            WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 120 THEN '90 a 120 min depois'
            WHEN DATEDIFF(MINUTE, p.PrimeiraEntrega, g.InicioApp) <= 150 THEN '120 a 150 min depois'
            ELSE 'Maior que 150 min depois'
        END AS FaixaTempoInicioApp,

        -- Tempo em que o ultimo apontamento GPS ocorreu em relacao a ultima entrega
        -- Positivo = GPS terminou antes da ultima entrega
        -- Negativo = GPS terminou depois da ultima entrega
        DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) AS MinFimApp_UltimaEntrega,
        CASE
            WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) < 0   THEN 'Depois da ultima entrega'
            WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 10 THEN 'Até 10 min antes'
            WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 30 THEN '10 a 30 min antes'
            WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 60 THEN '30 a 60 min antes'
            WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 90 THEN '60 a 90 min antes'
            WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 120 THEN '90 a 120 min antes'
            WHEN DATEDIFF(MINUTE, g.FimApp, p.UltimaEntrega) <= 150 THEN '120 a 150 min antes'
            ELSE 'Maior que 150 min antes'
        END AS FaixaTempoFimApp,

        -- Percentual de atingimento do km pacote
        CASE
            WHEN NULLIF(r.pontosRotasPacotesKm, 0) IS NOT NULL
            THEN CAST((r.KmApp / NULLIF(r.pontosRotasPacotesKm, 0)) * 100.0 AS DECIMAL(10, 2))
            ELSE NULL
        END AS PercAtingimentoKmApp,

        CASE
            WHEN NULLIF(r.pontosRotasPacotesKm, 0) IS NOT NULL
             AND r.KmApp < 0.9 * r.pontosRotasPacotesKm
            THEN 'Sim'
            ELSE 'Não'
        END AS KmApp_Menor_90_Perc,

        -- Flags originais da base
        r.FaixaPrimeiroUltimoPacote,
        r.UsouApp,
        r.ColetouGps

    FROM rotas AS r
    LEFT JOIN gps AS g
        ON g.Usuario = r.UsuarioDA
       AND g.Data    = r.Data
    LEFT JOIN entregas AS p
        ON p.IdRota = TRY_CONVERT(INT, r.Idrota);

    SELECT @@ROWCOUNT AS LinhasInseridas;

END;
GO
