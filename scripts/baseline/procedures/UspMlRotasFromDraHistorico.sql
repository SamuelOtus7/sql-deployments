-- ============================================================
-- BASELINE: dbo.UspMlRotasFromDraHistorico
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMlRotasFromDraHistorico]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[UspMlRotasFromDraHistorico]
(
    @cd_cliente INT = NULL,
    @dt_inicio  DATE = NULL,
    @dt_fim     DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Defaults de data: ultimos 10 dias ate hoje (mesmo padrao de UspMLReprocessarRotas).
    IF @dt_inicio IS NULL SET @dt_inicio = DATEADD(DAY, -10, CAST(GETDATE() AS DATE));
    IF @dt_fim    IS NULL SET @dt_fim    = CAST(GETDATE() AS DATE);

    DECLARE @dh_agora DATETIME = GETDATE();
    DECLARE @qt_inseridos INT = 0;
    DECLARE @qt_atualizados INT = 0;

    -- Fonte deduplicada: 1 linha por (dhr_nr_rota, dhr_cd_cliente) pela coleta mais recente.
    -- dhr_cd_cliente ja e IdTransportadora (nao precisa de tb_clientes).
    SELECT
        CAST(d.dhr_nr_rota AS INT)                                AS nr_rota,
        d.dhr_cd_cliente                                          AS id_transportadora,
        d.dhr_dt_data                                             AS dt_referencia,
        d.dhr_dh_coleta                                           AS dh_coleta,
        d.dhr_ds_service_center                                   AS service_center,
        d.dhr_ds_veiculo                                          AS tipo_veiculo,
        LEFT(LTRIM(RTRIM(d.dhr_ds_placa)), 11)                    AS placa,
        LEFT(LTRIM(RTRIM(d.dhr_ds_nome_motorista)), 100)          AS nome_motorista,
        d.dhr_nr_motorista                                        AS id_motorista,
        CAST(d.dhr_vl_quilometros_percorridos AS DECIMAL(10, 4))  AS km_total,
        CAST(d.dhr_nr_envios_expedidos AS SMALLINT)               AS total_pacotes,
        CAST(d.dhr_nr_envios_entregues AS SMALLINT)               AS pacotes_entregues,
        CAST(ISNULL(d.dhr_nr_nao_visitado, 0) AS SMALLINT)        AS pacotes_nao_entregues
    INTO #fonte
    FROM (
        SELECT
            d.*,
            ROW_NUMBER() OVER (
                PARTITION BY d.dhr_nr_rota, d.dhr_cd_cliente
                ORDER BY d.dhr_dh_coleta DESC
            ) AS nr_ordem
        FROM dbo.tb_dra_historico_rotas AS d
        WHERE (@cd_cliente IS NULL OR d.dhr_cd_cliente = @cd_cliente)
          AND d.dhr_dt_data BETWEEN @dt_inicio AND @dt_fim
          AND d.dhr_nr_rota BETWEEN -2147483648 AND 2147483647
    ) AS d
    WHERE d.nr_ordem = 1;

    CREATE CLUSTERED INDEX IX_fonte ON #fonte (nr_rota, id_transportadora);

    BEGIN TRANSACTION;

    -- UPDATE: rotas existentes, nao excluidas e nao planned.
    UPDATE r
    SET
        DataReferencia       = f.dt_referencia,
        DataHoraColeta       = f.dh_coleta,
        ServiceCenter        = f.service_center,
        TipoVeiculo          = f.tipo_veiculo,
        Placa                = f.placa,
        NomeMotorista        = ISNULL(NULLIF(LTRIM(RTRIM(f.nome_motorista)), N''), r.NomeMotorista),
        KmTotal              = f.km_total,
        TotalPacotes         = f.total_pacotes,
        PacotesEntregues     = f.pacotes_entregues,
        PacotesNaoEntregue   = f.pacotes_nao_entregues,
        DataAtualizacao      = @dh_agora
    FROM dbo.tb_ml_rotas AS r
    INNER JOIN #fonte AS f
        ON r.IdRota = f.nr_rota
       AND r.IdTransportadora = f.id_transportadora
    WHERE r.Excluido = 0
      AND r.StatusRota <> N'planned';

    SET @qt_atualizados = @@ROWCOUNT;

    -- INSERT: rotas inexistentes em tb_ml_rotas (UNIQUE IdRota + IdTransportadora).
    -- Defaults seguem UspMLInsereRotasReprocessadas.
    INSERT INTO dbo.tb_ml_rotas
    (
        IdRota,
        IdTransportadora,
        DataReferencia,
        DataHoraColeta,
        ServiceCenter,
        OrigemSaida,
        StatusRota,
        TipoEntrega,
        DataHoraInicio,
        TotalPacotes,
        PacotesEntregues,
        PacotesNaoEntregue,
        PacotesPendentes,
        PacotesEntreguesForaAreaEntrega,
        PacotesTransferidos,
        PacotesRecebidos,
        TotalSacas,
        NomeMotorista,
        MotoristaArriscado,
        PossuiAjudante,
        Placa,
        TipoVeiculo,
        KmTotal,
        TempoEmRota,
        TempoChegadaAreaEntrega,
        TempoAreaEntrega,
        TempoRetornoCentroDistribuicao,
        QuantidadePontos,
        QuantidadeParadas,
        QuantidadeReclamacoes,
        KmColetado,
        DataAtualizacao,
        Excluido,
        TipoRota
    )
    SELECT
        f.nr_rota,
        f.id_transportadora,
        f.dt_referencia,
        f.dh_coleta,
        f.service_center,
        f.service_center,                 -- OrigemSaida = service_center (fallback)
        N'close',                         -- StatusRota
        N'',                              -- TipoEntrega
        f.dh_coleta,                      -- DataHoraInicio (proxy)
        f.total_pacotes,
        f.pacotes_entregues,
        f.pacotes_nao_entregues,
        0,                                -- PacotesPendentes
        0,                                -- PacotesEntreguesForaAreaEntrega
        0,                                -- PacotesTransferidos
        0,                                -- PacotesRecebidos
        0,                                -- TotalSacas
        ISNULL(NULLIF(LTRIM(RTRIM(f.nome_motorista)), N''), N'-'),  -- NomeMotorista (NOT NULL)
        0,                                -- MotoristaArriscado
        0,                                -- PossuiAjudante
        f.placa,
        f.tipo_veiculo,
        f.km_total,
        0,                                -- TempoEmRota
        0,                                -- TempoChegadaAreaEntrega
        0,                                -- TempoAreaEntrega
        0,                                -- TempoRetornoCentroDistribuicao
        0,                                -- QuantidadePontos
        0,                                -- QuantidadeParadas
        0,                                -- QuantidadeReclamacoes
        0,                                -- KmColetado
        @dh_agora,                        -- DataAtualizacao
        0,                                -- Excluido
        N'-'                              -- TipoRota
    FROM #fonte AS f
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tb_ml_rotas AS r
        WHERE r.IdRota = f.nr_rota
          AND r.IdTransportadora = f.id_transportadora
    )
      AND f.id_motorista > 0;

    SET @qt_inseridos = @@ROWCOUNT;

    COMMIT TRANSACTION;

    SELECT
        @qt_atualizados AS qt_atualizados,
        @qt_inseridos   AS qt_inseridos,
        @dh_agora       AS dh_execucao;
END;
GO
