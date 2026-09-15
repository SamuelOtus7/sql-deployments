-- ============================================================
-- BASELINE: dbo.UspLoadDraHistoricoRotasLH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadDraHistoricoRotasLH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspLoadDraHistoricoRotasLH]
(
    @cd_lote    UNIQUEIDENTIFIER,
    @cd_cliente INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @dh_agora       DATETIME2(3) = SYSDATETIME();
    DECLARE @qt_stage       INT = 0;
    DECLARE @qt_stage_del   INT = 0;
    DECLARE @qt_insert      INT = 0;
    DECLARE @qt_update      INT = 0;

    SELECT @qt_stage = COUNT(*)
    FROM dbo.tb_stg_dra_historico_rotas_lh WITH (NOLOCK)
    WHERE stg_cd_lote = @cd_lote
      AND stg_cd_cliente = @cd_cliente;

    IF @qt_stage = 0
    BEGIN
        DECLARE @ds_erro NVARCHAR(500) =
            N'Nenhum registro encontrado em tb_stg_dra_historico_rotas_lh para o lote '
            + CAST(@cd_lote AS NVARCHAR(36))
            + N' e cliente '
            + CAST(@cd_cliente AS NVARCHAR(20))
            + N'.';

        THROW 51000, @ds_erro, 1;
    END;

    DECLARE @MergeOutput TABLE
    (
        acao NVARCHAR(10) NOT NULL
    );

    BEGIN TRANSACTION;

    ;WITH cte_stage_dedup AS
    (
        SELECT
            s.stg_cd_cliente,
            s.dhl_nr_route_id,
            s.dhl_nr_rostering_id,
            s.dhl_ds_servico,
            s.dhl_dt_servico,
            s.dhl_ds_parceiro,
            s.dhl_ds_tipo_veiculo,
            s.dhl_nr_motorista_1,
            s.dhl_ds_nome_motorista_1,
            s.dhl_nr_motorista_2,
            s.dhl_ds_nome_motorista_2,
            s.dhl_ds_placa_trator,
            s.dhl_ds_placa_carga_1,
            s.dhl_ds_placa_carga_2,
            s.dhl_nr_trecho,
            s.dhl_ds_origem,
            s.dhl_dh_origem_eta,
            s.dhl_dh_origem_ata,
            s.dhl_ds_fonte_ata_origem,
            s.dhl_dh_origem_etd,
            s.dhl_dh_origem_atd,
            s.dhl_ds_fonte_atd_origem,
            s.dhl_ds_pre_checkin_origem,
            s.dhl_ds_timezone_origem,
            s.dhl_ds_destino,
            s.dhl_dh_destino_eta,
            s.dhl_dh_destino_ata,
            s.dhl_dh_destino_atd,
            s.dhl_dh_destino_etd,
            s.dhl_ds_fonte_ata_destino,
            s.dhl_dh_previsao_chegada,
            s.dhl_dh_ultima_atualizacao,
            s.dhl_ds_pre_checkin_destino,
            s.dhl_ds_timezone_destino,
            s.dhl_ds_tempo_transito_estimado,
            s.dhl_ds_tempo_transito_real,
            s.dhl_nr_hus,
            s.dhl_nr_pacotes,
            s.dhl_ds_occupation,
            s.dhl_ds_estado,
            s.dhl_ds_substatus,
            s.dhl_ds_nota,
            s.dhl_ds_motivo_cancelamento,
            s.dhl_ds_causa_raiz_incidente,
            s.dhl_ds_ots,
            s.dhl_ds_otd,
            s.dhl_ds_ota,
            s.dhl_ds_otr,
            s.dhl_ds_fonte_atd_destino,
            ROW_NUMBER() OVER (
                PARTITION BY s.dhl_nr_route_id, s.stg_cd_cliente
                ORDER BY
                    s.dhl_dh_ultima_atualizacao DESC,
                    s.dhl_nr_trecho DESC,
                    s.stg_cd_seq DESC
            ) AS nr_ordem
        FROM dbo.tb_stg_dra_historico_rotas_lh AS s
        WHERE s.stg_cd_lote = @cd_lote
          AND s.stg_cd_cliente = @cd_cliente
    )
    MERGE dbo.tb_dra_historico_rotas_lh WITH (HOLDLOCK) AS tgt
    USING (
        SELECT
            stg_cd_cliente,
            dhl_nr_route_id,
            dhl_nr_rostering_id,
            dhl_ds_servico,
            dhl_dt_servico,
            dhl_ds_parceiro,
            dhl_ds_tipo_veiculo,
            dhl_nr_motorista_1,
            dhl_ds_nome_motorista_1,
            dhl_nr_motorista_2,
            dhl_ds_nome_motorista_2,
            dhl_ds_placa_trator,
            dhl_ds_placa_carga_1,
            dhl_ds_placa_carga_2,
            dhl_nr_trecho,
            dhl_ds_origem,
            dhl_dh_origem_eta,
            dhl_dh_origem_ata,
            dhl_ds_fonte_ata_origem,
            dhl_dh_origem_etd,
            dhl_dh_origem_atd,
            dhl_ds_fonte_atd_origem,
            dhl_ds_pre_checkin_origem,
            dhl_ds_timezone_origem,
            dhl_ds_destino,
            dhl_dh_destino_eta,
            dhl_dh_destino_ata,
            dhl_dh_destino_atd,
            dhl_dh_destino_etd,
            dhl_ds_fonte_ata_destino,
            dhl_dh_previsao_chegada,
            dhl_dh_ultima_atualizacao,
            dhl_ds_pre_checkin_destino,
            dhl_ds_timezone_destino,
            dhl_ds_tempo_transito_estimado,
            dhl_ds_tempo_transito_real,
            dhl_nr_hus,
            dhl_nr_pacotes,
            dhl_ds_occupation,
            dhl_ds_estado,
            dhl_ds_substatus,
            dhl_ds_nota,
            dhl_ds_motivo_cancelamento,
            dhl_ds_causa_raiz_incidente,
            dhl_ds_ots,
            dhl_ds_otd,
            dhl_ds_ota,
            dhl_ds_otr,
            dhl_ds_fonte_atd_destino
        FROM cte_stage_dedup
        WHERE nr_ordem = 1
    ) AS src
        ON tgt.dhl_nr_route_id = src.dhl_nr_route_id
       AND tgt.dhl_cd_cliente = src.stg_cd_cliente

    WHEN MATCHED THEN
        UPDATE SET
            tgt.dhl_dh_coleta                  = @dh_agora,
            tgt.dhl_dh_atualizacao             = @dh_agora,
            tgt.dhl_nr_rostering_id            = src.dhl_nr_rostering_id,
            tgt.dhl_ds_servico                 = src.dhl_ds_servico,
            tgt.dhl_dt_servico                 = src.dhl_dt_servico,
            tgt.dhl_ds_parceiro                = src.dhl_ds_parceiro,
            tgt.dhl_ds_tipo_veiculo            = src.dhl_ds_tipo_veiculo,
            tgt.dhl_nr_motorista_1             = src.dhl_nr_motorista_1,
            tgt.dhl_ds_nome_motorista_1        = src.dhl_ds_nome_motorista_1,
            tgt.dhl_nr_motorista_2             = src.dhl_nr_motorista_2,
            tgt.dhl_ds_nome_motorista_2        = src.dhl_ds_nome_motorista_2,
            tgt.dhl_ds_placa_trator            = src.dhl_ds_placa_trator,
            tgt.dhl_ds_placa_carga_1           = src.dhl_ds_placa_carga_1,
            tgt.dhl_ds_placa_carga_2           = src.dhl_ds_placa_carga_2,
            tgt.dhl_nr_trecho                  = src.dhl_nr_trecho,
            tgt.dhl_ds_origem                  = src.dhl_ds_origem,
            tgt.dhl_dh_origem_eta              = src.dhl_dh_origem_eta,
            tgt.dhl_dh_origem_ata              = src.dhl_dh_origem_ata,
            tgt.dhl_ds_fonte_ata_origem        = src.dhl_ds_fonte_ata_origem,
            tgt.dhl_dh_origem_etd              = src.dhl_dh_origem_etd,
            tgt.dhl_dh_origem_atd              = src.dhl_dh_origem_atd,
            tgt.dhl_ds_fonte_atd_origem        = src.dhl_ds_fonte_atd_origem,
            tgt.dhl_ds_pre_checkin_origem      = src.dhl_ds_pre_checkin_origem,
            tgt.dhl_ds_timezone_origem         = src.dhl_ds_timezone_origem,
            tgt.dhl_ds_destino                 = src.dhl_ds_destino,
            tgt.dhl_dh_destino_eta             = src.dhl_dh_destino_eta,
            tgt.dhl_dh_destino_ata             = src.dhl_dh_destino_ata,
            tgt.dhl_dh_destino_atd             = src.dhl_dh_destino_atd,
            tgt.dhl_dh_destino_etd             = src.dhl_dh_destino_etd,
            tgt.dhl_ds_fonte_ata_destino       = src.dhl_ds_fonte_ata_destino,
            tgt.dhl_dh_previsao_chegada        = src.dhl_dh_previsao_chegada,
            tgt.dhl_dh_ultima_atualizacao      = src.dhl_dh_ultima_atualizacao,
            tgt.dhl_ds_pre_checkin_destino     = src.dhl_ds_pre_checkin_destino,
            tgt.dhl_ds_timezone_destino        = src.dhl_ds_timezone_destino,
            tgt.dhl_ds_tempo_transito_estimado = src.dhl_ds_tempo_transito_estimado,
            tgt.dhl_ds_tempo_transito_real     = src.dhl_ds_tempo_transito_real,
            tgt.dhl_nr_hus                     = src.dhl_nr_hus,
            tgt.dhl_nr_pacotes                 = src.dhl_nr_pacotes,
            tgt.dhl_ds_occupation              = src.dhl_ds_occupation,
            tgt.dhl_ds_estado                  = src.dhl_ds_estado,
            tgt.dhl_ds_substatus               = src.dhl_ds_substatus,
            tgt.dhl_ds_nota                    = src.dhl_ds_nota,
            tgt.dhl_ds_motivo_cancelamento     = src.dhl_ds_motivo_cancelamento,
            tgt.dhl_ds_causa_raiz_incidente    = src.dhl_ds_causa_raiz_incidente,
            tgt.dhl_ds_ots                     = src.dhl_ds_ots,
            tgt.dhl_ds_otd                     = src.dhl_ds_otd,
            tgt.dhl_ds_ota                     = src.dhl_ds_ota,
            tgt.dhl_ds_otr                     = src.dhl_ds_otr,
            tgt.dhl_ds_fonte_atd_destino       = src.dhl_ds_fonte_atd_destino

    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            dhl_cd_cliente,
            dhl_dh_coleta,
            dhl_dh_inclusao,
            dhl_dh_atualizacao,
            dhl_nr_route_id,
            dhl_nr_rostering_id,
            dhl_ds_servico,
            dhl_dt_servico,
            dhl_ds_parceiro,
            dhl_ds_tipo_veiculo,
            dhl_nr_motorista_1,
            dhl_ds_nome_motorista_1,
            dhl_nr_motorista_2,
            dhl_ds_nome_motorista_2,
            dhl_ds_placa_trator,
            dhl_ds_placa_carga_1,
            dhl_ds_placa_carga_2,
            dhl_nr_trecho,
            dhl_ds_origem,
            dhl_dh_origem_eta,
            dhl_dh_origem_ata,
            dhl_ds_fonte_ata_origem,
            dhl_dh_origem_etd,
            dhl_dh_origem_atd,
            dhl_ds_fonte_atd_origem,
            dhl_ds_pre_checkin_origem,
            dhl_ds_timezone_origem,
            dhl_ds_destino,
            dhl_dh_destino_eta,
            dhl_dh_destino_ata,
            dhl_dh_destino_atd,
            dhl_dh_destino_etd,
            dhl_ds_fonte_ata_destino,
            dhl_dh_previsao_chegada,
            dhl_dh_ultima_atualizacao,
            dhl_ds_pre_checkin_destino,
            dhl_ds_timezone_destino,
            dhl_ds_tempo_transito_estimado,
            dhl_ds_tempo_transito_real,
            dhl_nr_hus,
            dhl_nr_pacotes,
            dhl_ds_occupation,
            dhl_ds_estado,
            dhl_ds_substatus,
            dhl_ds_nota,
            dhl_ds_motivo_cancelamento,
            dhl_ds_causa_raiz_incidente,
            dhl_ds_ots,
            dhl_ds_otd,
            dhl_ds_ota,
            dhl_ds_otr,
            dhl_ds_fonte_atd_destino
        )
        VALUES
        (
            src.stg_cd_cliente,
            @dh_agora,
            @dh_agora,
            @dh_agora,
            src.dhl_nr_route_id,
            src.dhl_nr_rostering_id,
            src.dhl_ds_servico,
            src.dhl_dt_servico,
            src.dhl_ds_parceiro,
            src.dhl_ds_tipo_veiculo,
            src.dhl_nr_motorista_1,
            src.dhl_ds_nome_motorista_1,
            src.dhl_nr_motorista_2,
            src.dhl_ds_nome_motorista_2,
            src.dhl_ds_placa_trator,
            src.dhl_ds_placa_carga_1,
            src.dhl_ds_placa_carga_2,
            src.dhl_nr_trecho,
            src.dhl_ds_origem,
            src.dhl_dh_origem_eta,
            src.dhl_dh_origem_ata,
            src.dhl_ds_fonte_ata_origem,
            src.dhl_dh_origem_etd,
            src.dhl_dh_origem_atd,
            src.dhl_ds_fonte_atd_origem,
            src.dhl_ds_pre_checkin_origem,
            src.dhl_ds_timezone_origem,
            src.dhl_ds_destino,
            src.dhl_dh_destino_eta,
            src.dhl_dh_destino_ata,
            src.dhl_dh_destino_atd,
            src.dhl_dh_destino_etd,
            src.dhl_ds_fonte_ata_destino,
            src.dhl_dh_previsao_chegada,
            src.dhl_dh_ultima_atualizacao,
            src.dhl_ds_pre_checkin_destino,
            src.dhl_ds_timezone_destino,
            src.dhl_ds_tempo_transito_estimado,
            src.dhl_ds_tempo_transito_real,
            src.dhl_nr_hus,
            src.dhl_nr_pacotes,
            src.dhl_ds_occupation,
            src.dhl_ds_estado,
            src.dhl_ds_substatus,
            src.dhl_ds_nota,
            src.dhl_ds_motivo_cancelamento,
            src.dhl_ds_causa_raiz_incidente,
            src.dhl_ds_ots,
            src.dhl_ds_otd,
            src.dhl_ds_ota,
            src.dhl_ds_otr,
            src.dhl_ds_fonte_atd_destino
        )

    OUTPUT $action INTO @MergeOutput (acao);

    SELECT
        @qt_insert = SUM(CASE WHEN acao = N'INSERT' THEN 1 ELSE 0 END),
        @qt_update = SUM(CASE WHEN acao = N'UPDATE' THEN 1 ELSE 0 END)
    FROM @MergeOutput;

    DELETE FROM dbo.tb_stg_dra_historico_rotas_lh
    WHERE stg_cd_lote = @cd_lote
      AND stg_cd_cliente = @cd_cliente;

    SET @qt_stage_del = @@ROWCOUNT;

    COMMIT TRANSACTION;

    SELECT
        @cd_lote AS cd_lote,
        @cd_cliente AS cd_cliente,
        @qt_stage AS qt_stage_lido,
        ISNULL(@qt_insert, 0) AS qt_inseridos,
        ISNULL(@qt_update, 0) AS qt_atualizados,
        @qt_stage_del AS qt_removidos_stage,
        @dh_agora AS dh_processamento;
END;
GO
