-- ============================================================
-- BASELINE: dbo.UspMlLhRotasFromDraHistoricoLH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMlLhRotasFromDraHistoricoLH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspMlLhRotasFromDraHistoricoLH]
(
    @cd_cliente INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @dh_agora DATETIME2(3) = SYSDATETIME();
    DECLARE @qt_inseridos INT = 0;
    DECLARE @qt_atualizados INT = 0;

    SELECT
        d.dhl_nr_route_id,
        c.cli_id_logistics AS id_transportadora,
        ISNULL(d.dhl_dt_servico, CAST(d.dhl_dh_coleta AS DATE)) AS dt_referencia,
        CAST(ISNULL(d.dhl_nr_rostering_id, 0) AS INT) AS rostering_id,
        COALESCE(
            NULLIF(LTRIM(RTRIM(d.dhl_ds_servico)), N''),
            CAST(d.dhl_nr_route_id AS VARCHAR(100))
        ) AS codigo_rota,
        LEFT(LTRIM(RTRIM(d.dhl_ds_estado)), 60) AS status_geral,
        LEFT(LTRIM(RTRIM(d.dhl_ds_substatus)), 60) AS substatus_geral,
        CAST(d.dhl_nr_trecho AS INT) AS secao_rota,
        CAST(d.dhl_nr_motorista_1 AS INT) AS id_motorista,
        LEFT(LTRIM(RTRIM(d.dhl_ds_nome_motorista_1)), 60) AS nome_motorista,
        LEFT(LTRIM(RTRIM(d.dhl_ds_placa_trator)), 10) AS placa,
        LEFT(LTRIM(RTRIM(d.dhl_ds_tipo_veiculo)), 60) AS tipo_veiculo,
        LEFT(LTRIM(RTRIM(d.dhl_ds_placa_carga_1)), 10) AS placa_veiculo_1,
        LEFT(LTRIM(RTRIM(d.dhl_ds_placa_carga_2)), 10) AS placa_veiculo_2,
        LEFT(LTRIM(RTRIM(d.dhl_ds_origem)), 60) AS service_center_origem,
        LEFT(LTRIM(RTRIM(d.dhl_ds_destino)), 60) AS service_center_destino,
        CAST(d.dhl_dh_origem_eta AS DATETIME) AS eta_origem,
        CAST(d.dhl_dh_origem_ata AS DATETIME) AS ata_origem,
        LEFT(LTRIM(RTRIM(d.dhl_ds_fonte_ata_origem)), 60) AS fonte_inicio_origem,
        CAST(d.dhl_dh_origem_etd AS DATETIME) AS etd_origem,
        CAST(d.dhl_dh_origem_atd AS DATETIME) AS atd_origem,
        LEFT(LTRIM(RTRIM(d.dhl_ds_fonte_atd_origem)), 60) AS fonte_finalizacao_origem,
        CAST(d.dhl_dh_destino_eta AS DATETIME) AS eta_destino,
        CAST(d.dhl_dh_destino_ata AS DATETIME) AS ata_destino,
        CAST(d.dhl_dh_destino_etd AS DATETIME) AS etd_destino,
        CAST(d.dhl_dh_destino_atd AS DATETIME) AS atd_destino,
        LEFT(LTRIM(RTRIM(d.dhl_ds_fonte_ata_destino)), 60) AS fonte_inicio_destino,
        LEFT(LTRIM(RTRIM(d.dhl_ds_fonte_atd_destino)), 60) AS fonte_finalizacao_destino,
        CAST(d.dhl_nr_hus AS INT) AS total_unidades_origem,
        CAST(d.dhl_nr_pacotes AS INT) AS total_pacotes_origem,
        LEFT(LTRIM(RTRIM(d.dhl_ds_ots)), 50) AS indicador_ots,
        LEFT(LTRIM(RTRIM(d.dhl_ds_otd)), 50) AS indicador_otd,
        LEFT(LTRIM(RTRIM(d.dhl_ds_ota)), 50) AS indicador_ota,
        LEFT(LTRIM(RTRIM(d.dhl_ds_otr)), 50) AS indicador_otr,
        d.dhl_ds_nota AS nota_rota,
        CAST(d.dhl_dh_coleta AS DATETIME) AS dh_coleta
    INTO #fonte
    FROM (
        SELECT
            d.*,
            ROW_NUMBER() OVER (
                PARTITION BY d.dhl_nr_route_id, d.dhl_cd_cliente
                ORDER BY
                    d.dhl_dh_ultima_atualizacao DESC,
                    d.dhl_nr_trecho DESC,
                    d.dhl_cd_historico_rota_lh DESC
            ) AS nr_ordem
        FROM dbo.tb_dra_historico_rotas_lh AS d
        WHERE (@cd_cliente IS NULL OR d.dhl_cd_cliente = @cd_cliente)
    ) AS d
    INNER JOIN dbo.tb_clientes AS c
        ON c.cli_cd_codigo_cliente = d.dhl_cd_cliente
    WHERE d.nr_ordem = 1
      AND c.cli_id_logistics IS NOT NULL
      AND c.cli_id_logistics > 0;

    CREATE CLUSTERED INDEX IX_fonte ON #fonte (dhl_nr_route_id, id_transportadora);

    BEGIN TRANSACTION;

    UPDATE lh
    SET
        DataReferencia                = f.dt_referencia,
        RosteringId                   = f.rostering_id,
        CodigoRota                    = f.codigo_rota,
        Status                        = f.status_geral,
        SubStatus                     = f.substatus_geral,
        StatusGeral                   = f.status_geral,
        SubstatusGeral                = f.substatus_geral,
        SecaoRota                     = f.secao_rota,
        IdMotorista                   = f.id_motorista,
        NomeMotorista                 = f.nome_motorista,
        Placa                         = f.placa,
        TipoVeiculo                   = f.tipo_veiculo,
        PlacaVeiculo1                 = f.placa_veiculo_1,
        PlacaVeiculo2                 = f.placa_veiculo_2,
        ServiceCenterOrigem           = f.service_center_origem,
        FonteInicioOrigem             = f.fonte_inicio_origem,
        FonteFinalizacaoOrigem        = f.fonte_finalizacao_origem,
        EtaOrigem                     = f.eta_origem,
        AtaOrigem                     = f.ata_origem,
        EtdOrigem                     = f.etd_origem,
        AtdOrigem                     = f.atd_origem,
        TotalUnidadesTransporteOrigem = f.total_unidades_origem,
        TotalPacotesOrigem            = f.total_pacotes_origem,
        ServiceCenterDestino          = f.service_center_destino,
        FonteInicioDestino            = f.fonte_inicio_destino,
        FonteFinalizacaoDestino       = f.fonte_finalizacao_destino,
        EtaDestino                    = f.eta_destino,
        AtaDestino                    = f.ata_destino,
        EtdDestino                    = f.etd_destino,
        AtdDestino                    = f.atd_destino,
        IndicadorOts                  = f.indicador_ots,
        IndicadorOtd                  = f.indicador_otd,
        IndicadorOta                  = f.indicador_ota,
        IndicadorOtr                  = f.indicador_otr,
        NotaRota                      = f.nota_rota,
        DataHoraColeta                = f.dh_coleta,
        DataAtualizacao               = @dh_agora
    FROM dbo.tb_ml_lh_rotas AS lh
    INNER JOIN #fonte AS f
        ON lh.IdRota = CAST(f.dhl_nr_route_id AS INT)
       AND lh.IdTransportadora = f.id_transportadora
    WHERE lh.Excluido = 0
      AND lh.Status = N'pending';

    SET @qt_atualizados = @@ROWCOUNT;

    INSERT INTO dbo.tb_ml_lh_rotas
    (
        IdRota,
        IdTransportadora,
        DataReferencia,
        RosteringId,
        CodigoRota,
        Status,
        SubStatus,
        StatusGeral,
        SubstatusGeral,
        SecaoRota,
        IdMotorista,
        NomeMotorista,
        Placa,
        TipoVeiculo,
        PlacaVeiculo1,
        PlacaVeiculo2,
        ServiceCenterOrigem,
        FonteInicioOrigem,
        FonteFinalizacaoOrigem,
        EtaOrigem,
        AtaOrigem,
        EtdOrigem,
        AtdOrigem,
        TotalUnidadesTransporteOrigem,
        TotalPacotesOrigem,
        ServiceCenterDestino,
        FonteInicioDestino,
        FonteFinalizacaoDestino,
        EtaDestino,
        AtaDestino,
        EtdDestino,
        AtdDestino,
        IndicadorOts,
        IndicadorOtd,
        IndicadorOta,
        IndicadorOtr,
        NotaRota,
        DataHoraColeta,
        DataAtualizacao,
        Excluido
    )
    SELECT
        CAST(f.dhl_nr_route_id AS INT),
        f.id_transportadora,
        f.dt_referencia,
        f.rostering_id,
        f.codigo_rota,
        f.status_geral,
        f.substatus_geral,
        f.status_geral,
        f.substatus_geral,
        f.secao_rota,
        f.id_motorista,
        f.nome_motorista,
        f.placa,
        f.tipo_veiculo,
        f.placa_veiculo_1,
        f.placa_veiculo_2,
        f.service_center_origem,
        f.fonte_inicio_origem,
        f.fonte_finalizacao_origem,
        f.eta_origem,
        f.ata_origem,
        f.etd_origem,
        f.atd_origem,
        f.total_unidades_origem,
        f.total_pacotes_origem,
        f.service_center_destino,
        f.fonte_inicio_destino,
        f.fonte_finalizacao_destino,
        f.eta_destino,
        f.ata_destino,
        f.etd_destino,
        f.atd_destino,
        f.indicador_ots,
        f.indicador_otd,
        f.indicador_ota,
        f.indicador_otr,
        f.nota_rota,
        f.dh_coleta,
        @dh_agora,
        0
    FROM #fonte AS f
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tb_ml_lh_rotas AS lh
        WHERE lh.IdRota = CAST(f.dhl_nr_route_id AS INT)
          AND lh.IdTransportadora = f.id_transportadora
          AND lh.Excluido = 0
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
