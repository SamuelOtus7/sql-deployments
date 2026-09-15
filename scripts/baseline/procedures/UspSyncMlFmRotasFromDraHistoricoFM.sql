-- ============================================================
-- BASELINE: dbo.UspSyncMlFmRotasFromDraHistoricoFM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSyncMlFmRotasFromDraHistoricoFM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspSyncMlFmRotasFromDraHistoricoFM]
(
    @id_transportadora INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @dh_agora DATETIME2(3) = SYSDATETIME();
    DECLARE @qt_inseridos INT = 0;
    DECLARE @qt_atualizados INT = 0;

    SELECT
        f.dhr_nr_rota,
        f.idtransportadora,
        f.dhr_dt_data AS dt_referencia,
        CAST(f.dhr_nr_rota AS VARCHAR(60)) AS nome_rota,
        'first_mile' AS tipo_rota,
        'first_mile' AS tipo,
        LEFT(LTRIM(RTRIM(f.dhr_ds_service_center)), 60) AS origem_saida,
        LEFT(LTRIM(RTRIM(f.dhr_ds_service_center)), 60) AS nome_origem_saida,
        0 AS quantidade_paradas,
        0 AS quantidade_paradas_sucesso,
        CAST(ROUND(ISNULL(f.dhr_nr_nao_visitado, 0), 0) AS INT) AS quantidade_paradas_falha,
        0 AS quantidade_paradas_problema,
        0 AS quantidade_paradas_parcial,
        CAST(CAST(f.dhr_vl_delivery_success AS DECIMAL(10, 4)) / 100.00 AS DECIMAL(5, 4)) AS porcentagem_paradas,
        f.dhr_nr_envios_expedidos AS quantidade_pacotes_estimados,
        f.dhr_nr_envios_entregues AS quantidade_pacotes_coletados,
        0 AS quantidade_pacotes_preparados,
        'active' AS status,
        LEFT(LTRIM(RTRIM(f.dhr_ds_placa)), 60) AS nome_veiculo,
        LEFT(LTRIM(RTRIM(f.dhr_ds_veiculo)), 60) AS tipo_veiculo,
        0 AS id_tipo_veiculo,
        LEFT(LTRIM(RTRIM(f.dhr_ds_placa)), 60) AS placa_veiculo,
        0 AS capacidade_veiculo,
        CAST(f.dhr_nr_motorista AS INT) AS id_motorista,
        LEFT(LTRIM(RTRIM(ISNULL(f.dhr_ds_nome_motorista, ''))), 60) AS nome_motorista,
        0 AS dia_atual,
        CASE WHEN ISNULL(f.dhr_nr_nao_visitado, 0) > 0 THEN 1 ELSE 0 END AS coletado_parcialmente,
        CAST(CAST(f.dhr_vl_delivery_success AS DECIMAL(10, 4)) / 100.00 AS DECIMAL(5, 4)) AS performance,
        0 AS chegou_instalacao,
        0 AS iniciou_entrada,
        0 AS caminho_instalacao,
        NULL AS data_conclusao,
        f.dhr_dh_coleta AS data_inicio,
        NULL AS volume_carregado,
        ISNULL(f.dhr_dh_coleta, @dh_agora) AS data_hora_coleta,
        @dh_agora AS data_atualizacao,
        0 AS excluido,
        f.dhr_vl_quilometros_percorridos AS km_percorrido
    INTO #fonte
    FROM (
        SELECT
            d.*,
            ROW_NUMBER() OVER (
                PARTITION BY d.dhr_nr_rota, d.idtransportadora
                ORDER BY d.dhr_cd_historico_rota DESC
            ) AS nr_ordem
        FROM dbo.tb_dra_historico_rotas_fm AS d
        WHERE (@id_transportadora IS NULL OR d.idtransportadora = @id_transportadora)
    ) AS f
    WHERE f.nr_ordem = 1
      AND f.dhr_nr_rota BETWEEN -2147483648 AND 2147483647
      AND f.idtransportadora IS NOT NULL
      AND f.idtransportadora > 0;

    CREATE CLUSTERED INDEX IX_fonte ON #fonte (dhr_nr_rota, idtransportadora);

    BEGIN TRANSACTION;

    UPDATE r
    SET
        DataReferencia = f.dt_referencia,
        NomeRota = f.nome_rota,
        TipoRota = f.tipo_rota,
        Tipo = f.tipo,
        OrigemSaida = f.origem_saida,
        NomeOrigemSaida = f.nome_origem_saida,
        QuantidadeParadas = f.quantidade_paradas,
        QuantidadeParadasComSucesso = f.quantidade_paradas_sucesso,
        QuantidadeParadasComFalha = f.quantidade_paradas_falha,
        QuantidadeParadasComProblema = f.quantidade_paradas_problema,
        QuantidadeParadasParcialmenteColetadas = f.quantidade_paradas_parcial,
        PorcentagemParadas = f.porcentagem_paradas,
        QuantidadePacotesEstimados = f.quantidade_pacotes_estimados,
        QuantidadePacotesColetados = f.quantidade_pacotes_coletados,
        QuantidadePacotesPreparados = f.quantidade_pacotes_preparados,
        Status = f.status,
        NomeVeiculo = f.nome_veiculo,
        TipoVeiculo = f.tipo_veiculo,
        IdTipoVeiculo = f.id_tipo_veiculo,
        PlacaVeiculo = f.placa_veiculo,
        CapacidadeVeiculo = f.capacidade_veiculo,
        IdMotorista = f.id_motorista,
        NomeMotorista = f.nome_motorista,
        DiaAtual = f.dia_atual,
        ColetadoParcialmente = f.coletado_parcialmente,
        Perfomance = f.performance,
        ChegouNaInstalacao = f.chegou_instalacao,
        IniciouEntrada = f.iniciou_entrada,
        CaminhoParaInstalacao = f.caminho_instalacao,
        DataConclusao = f.data_conclusao,
        DataInicio = f.data_inicio,
        VolumeCarregado = f.volume_carregado,
        DataHoraColeta = f.data_hora_coleta,
        DataAtualizacao = f.data_atualizacao,
        KmPercorrido = f.km_percorrido
    FROM dbo.tb_ml_fm_rotas AS r
    INNER JOIN #fonte AS f
        ON r.IdRota = CAST(f.dhr_nr_rota AS INT)
       AND r.IdTransportadora = f.idtransportadora
    WHERE r.Excluido = 0
      AND r.Status = N'pending';

    SET @qt_atualizados = @@ROWCOUNT;

    INSERT INTO dbo.tb_ml_fm_rotas
    (
        IdRota,
        IdTransportadora,
        DataReferencia,
        NomeRota,
        TipoRota,
        Tipo,
        OrigemSaida,
        NomeOrigemSaida,
        QuantidadeParadas,
        QuantidadeParadasComSucesso,
        QuantidadeParadasComFalha,
        QuantidadeParadasComProblema,
        QuantidadeParadasParcialmenteColetadas,
        PorcentagemParadas,
        QuantidadePacotesEstimados,
        QuantidadePacotesColetados,
        QuantidadePacotesPreparados,
        Status,
        NomeVeiculo,
        TipoVeiculo,
        IdTipoVeiculo,
        PlacaVeiculo,
        CapacidadeVeiculo,
        IdMotorista,
        NomeMotorista,
        DiaAtual,
        ColetadoParcialmente,
        Perfomance,
        ChegouNaInstalacao,
        IniciouEntrada,
        CaminhoParaInstalacao,
        DataConclusao,
        DataInicio,
        VolumeCarregado,
        DataHoraColeta,
        DataAtualizacao,
        Excluido,
        KmPercorrido
    )
    SELECT
        CAST(f.dhr_nr_rota AS INT),
        f.idtransportadora,
        f.dt_referencia,
        f.nome_rota,
        f.tipo_rota,
        f.tipo,
        f.origem_saida,
        f.nome_origem_saida,
        f.quantidade_paradas,
        f.quantidade_paradas_sucesso,
        f.quantidade_paradas_falha,
        f.quantidade_paradas_problema,
        f.quantidade_paradas_parcial,
        f.porcentagem_paradas,
        f.quantidade_pacotes_estimados,
        f.quantidade_pacotes_coletados,
        f.quantidade_pacotes_preparados,
        f.status,
        f.nome_veiculo,
        f.tipo_veiculo,
        f.id_tipo_veiculo,
        f.placa_veiculo,
        f.capacidade_veiculo,
        f.id_motorista,
        f.nome_motorista,
        f.dia_atual,
        f.coletado_parcialmente,
        f.performance,
        f.chegou_instalacao,
        f.iniciou_entrada,
        f.caminho_instalacao,
        f.data_conclusao,
        f.data_inicio,
        f.volume_carregado,
        f.data_hora_coleta,
        f.data_atualizacao,
        f.excluido,
        f.km_percorrido
    FROM #fonte AS f
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tb_ml_fm_rotas AS r
        WHERE r.IdRota = CAST(f.dhr_nr_rota AS INT)
          AND r.IdTransportadora = f.idtransportadora
          AND r.Excluido = 0
    )
      AND f.id_motorista IS NOT NULL
      AND f.id_motorista > 0;

    SET @qt_inseridos = @@ROWCOUNT;

    COMMIT TRANSACTION;

    SELECT
        @qt_atualizados AS qt_atualizados,
        @qt_inseridos AS qt_inseridos,
        @dh_agora AS dh_execucao;
END;
GO
